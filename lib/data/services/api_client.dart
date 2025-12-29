import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:wedly/core/utils/app_logger.dart';
import 'api_constants.dart';
import 'api_exceptions.dart';
import 'token_manager.dart';

/// ApiClient handles all HTTP communication with the backend
/// Features:
/// - Automatic token refresh
/// - Error handling and mapping to custom exceptions
/// - Request/Response logging in debug mode
/// - Support for all HTTP methods
class ApiClient {
  final Dio _dio;
  final TokenManager _tokenManager;

  // Callback for when session truly expires (refresh token invalid)
  void Function()? onSessionExpired;

  // Prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;

  // Queue of pending requests waiting for token refresh
  final List<({DioException error, ErrorInterceptorHandler handler})> _pendingRequests = [];

  ApiClient(this._tokenManager) : _dio = Dio() {
    _configureDio();
    _configureSsl();
    _addInterceptors();
  }

  /// Configure Dio with base settings
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Accept': ApiConstants.accept,
      },
    );
  }

  /// Configure SSL settings for development with IP-based server
  /// WARNING: This bypasses SSL verification for debug builds only
  void _configureSsl() {
    // Only bypass SSL verification in debug mode
    if (kDebugMode) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Allow connections to our API server IP
          if (host == '64.226.96.53') {
            AppLogger.warning('Bypassing SSL certificate check for $host (debug mode)', tag: 'ApiClient');
            return true;
          }
          return false;
        };
        return client;
      };
    }
  }

  /// Add interceptors for logging and token handling
  void _addInterceptors() {
    // Add pretty logger for debugging (disable in production)
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    // Add token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // CRITICAL: Skip adding Authorization header for refresh requests
          // The refresh token is sent in the body, not the header
          if (options.extra['isRefreshRequest'] == true) {
            return handler.next(options);
          }

          // Add access token to headers for all other requests
          final token = await _tokenManager.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // CRITICAL: Never intercept our own refresh requests
          if (error.requestOptions.extra['isRefreshRequest'] == true) {
            return handler.next(error);
          }

          // Handle 401 Unauthorized - attempt token refresh
          if (error.response?.statusCode == 401) {
            // CRITICAL FIX: Don't try to refresh tokens for auth endpoints
            // These endpoints are for logging in, not for authenticated requests
            final path = error.requestOptions.path;
            final isAuthEndpoint = path.contains('/auth/login') ||
                path.contains('/auth/register') ||
                path.contains('/auth/social-login') ||
                path.contains('/auth/verify-otp') ||
                path.contains('/auth/forgot-password') ||
                path.contains('/auth/reset-password');

            if (isAuthEndpoint) {
              // Don't attempt token refresh for auth endpoints
              // Just pass the error through normally
              return handler.next(error);
            }

            // If already refreshing, queue this request
            if (_isRefreshing) {
              _pendingRequests.add((error: error, handler: handler));
              return; // Don't call handler yet
            }

            // Start refresh process
            _isRefreshing = true;
            final refreshed = await _refreshToken();
            _isRefreshing = false;

            if (refreshed) {
              // Retry the original request
              final retryResponse = await _retryRequest(error.requestOptions);
              if (retryResponse != null) {
                handler.resolve(retryResponse);
                // Process queued requests
                await _processQueuedRequests();
                return;
              }
            } else {
              // Refresh failed - session expired
              onSessionExpired?.call();
              // Reject all queued requests
              _rejectQueuedRequests();
              // Return the original error to trigger proper error handling
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Attempt to refresh the access token
  /// Returns true if successful, false if session expired
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      AppLogger.auth('Attempting token refresh...');
      AppLogger.debug('Refresh token available: ${refreshToken != null}', tag: 'ApiClient');

      if (refreshToken == null) {
        AppLogger.error('No refresh token found - session expired', tag: 'ApiClient');
        return false;
      }

      AppLogger.token('Using refresh token', tokenPreview: refreshToken);

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          // CRITICAL FIX: Don't send Authorization header for refresh
          // The refresh_token is in the body, not the header
          headers: {
            'Content-Type': 'application/json',
          },
          // Mark this as a refresh request to skip interceptor
          extra: {'isRefreshRequest': true},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'] ?? refreshToken;

        AppLogger.success('Token refresh successful', tag: 'ApiClient');
        AppLogger.debug('New access token received: ${newAccessToken != null}', tag: 'ApiClient');

        await _tokenManager.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        return true;
      }
      AppLogger.error('Token refresh failed - status code: ${response.statusCode}', tag: 'ApiClient');
      return false;
    } catch (e) {
      AppLogger.error('Token refresh failed', tag: 'ApiClient', error: e);
      if (e is DioException && e.response != null) {
        AppLogger.response('Refresh error response', tag: 'ApiClient', statusCode: e.response?.statusCode);
      }
      return false;
    }
  }

  /// Retry a failed request with new access token
  Future<Response?> _retryRequest(RequestOptions requestOptions) async {
    try {
      final token = await _tokenManager.getAccessToken();
      requestOptions.headers['Authorization'] = 'Bearer $token';
      return await _dio.fetch(requestOptions);
    } catch (e) {
      AppLogger.error('Retry request failed', tag: 'ApiClient', error: e);
      return null;
    }
  }

  /// Process all queued requests after successful refresh
  Future<void> _processQueuedRequests() async {
    final requests = List.from(_pendingRequests);
    _pendingRequests.clear();

    for (final request in requests) {
      final retryResponse = await _retryRequest(request.error.requestOptions);
      if (retryResponse != null) {
        request.handler.resolve(retryResponse);
      } else {
        request.handler.next(request.error);
      }
    }
  }

  /// Reject all queued requests when session expires
  void _rejectQueuedRequests() {
    final requests = List.from(_pendingRequests);
    _pendingRequests.clear();

    for (final request in requests) {
      request.handler.reject(
        DioException(
          requestOptions: request.error.requestOptions,
          error: SessionExpiredException(),
          type: DioExceptionType.badResponse,
        ),
      );
    }
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle and map errors to custom exceptions
  ApiException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException();

        case DioExceptionType.connectionError:
          // Check if it's a TLS/SSL handshake error
          if (_isTlsHandshakeError(error)) {
            return TlsHandshakeException();
          }

          if (error.error is SocketException) {
            return NoInternetException();
          }
          return ConnectionException();

        case DioExceptionType.badResponse:
          return _handleResponseError(error.response);

        case DioExceptionType.cancel:
          return ApiException(message: 'تم إلغاء الطلب\nRequest cancelled');

        case DioExceptionType.badCertificate:
          return SslCertificateException();

        case DioExceptionType.unknown:
          // Check for TLS/SSL handshake errors in unknown type
          if (_isTlsHandshakeError(error)) {
            return TlsHandshakeException();
          }

          // Check for SSL certificate errors
          if (_isSslCertificateError(error)) {
            return SslCertificateException();
          }

          // Try to extract meaningful error from the underlying error
          if (error.error is SocketException) {
            return NoInternetException();
          }

          // Check if there's a response with error details
          if (error.response != null) {
            return _handleResponseError(error.response);
          }

          // Return a more descriptive error
          final errorMsg = error.error?.toString() ?? error.message ?? 'خطأ غير معروف';
          return UnknownException(message: errorMsg);
      }
    }

    return UnknownException(
      message: error.toString(),
    );
  }

  /// Check if the error is a TLS handshake error
  bool _isTlsHandshakeError(DioException error) {
    final errorStr = error.error?.toString().toLowerCase() ?? '';
    final messageStr = error.message?.toLowerCase() ?? '';

    return errorStr.contains('handshake') ||
        errorStr.contains('tlsv1_alert') ||
        errorStr.contains('tls_record') ||
        errorStr.contains('sec_e_illegal_message') ||
        messageStr.contains('handshake');
  }

  /// Check if the error is an SSL certificate error
  bool _isSslCertificateError(DioException error) {
    final errorStr = error.error?.toString().toLowerCase() ?? '';
    final messageStr = error.message?.toLowerCase() ?? '';

    return errorStr.contains('certificate') ||
        errorStr.contains('ssl') ||
        messageStr.contains('certificate') ||
        messageStr.contains('ssl');
  }

  /// Handle HTTP response errors
  ApiException _handleResponseError(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final message = response?.data?['message'] ?? response?.statusMessage;

    switch (statusCode) {
      case 400:
        return ClientException(
          message: message,
          statusCode: statusCode,
          data: response?.data,
        );
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ForbiddenException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 422:
        return ValidationException(
          message: message,
          errors: response?.data?['errors'],
        );
      case 500:
      case 502:
      case 503:
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return ClientException(
            message: message,
            statusCode: statusCode,
          );
        } else if (statusCode >= 500) {
          return ServerException(
            message: message,
            statusCode: statusCode,
          );
        }
        return UnknownException(message: message);
    }
  }
}
