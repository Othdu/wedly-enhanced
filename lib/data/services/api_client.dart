import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
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

    // DEVELOPMENT ONLY: Disable SSL certificate verification for IP addresses
    // WARNING: Remove this in production!
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
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
          // Add access token to headers
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
      if (refreshToken == null) {
        // No refresh token = session expired
        return false;
      }

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
        // API doesn't return new refresh_token, keep existing one
        final newRefreshToken = data['refresh_token'] ?? refreshToken;

        await _tokenManager.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      // Any error during refresh = session expired
      print('Token refresh failed: $e');
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
      print('Retry request failed: $e');
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
