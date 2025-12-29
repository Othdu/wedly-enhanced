import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wedly/core/utils/app_logger.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  // Stream controller for connectivity changes
  final _connectivityController = StreamController<bool>.broadcast();

  // Current connectivity status
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  // Stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      await _checkConnectivity();

      // Listen to connectivity changes
      _subscription = _connectivity.onConnectivityChanged.listen(
        (results) {
          _handleConnectivityChange(results);
        },
        onError: (error) {
          // Handle plugin errors gracefully - assume connected
          AppLogger.warning('Connectivity stream error, assuming connected', tag: 'Connectivity');
          _isConnected = true;
        },
      );

      AppLogger.info('Connectivity service initialized', tag: 'Connectivity');
    } catch (e) {
      // Plugin not available - assume connected and continue
      AppLogger.warning('Connectivity plugin not available, assuming connected', tag: 'Connectivity');
      _isConnected = true;
    }
  }

  /// Check current connectivity status
  Future<bool> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
      return _isConnected;
    } catch (e) {
      AppLogger.error('Error checking connectivity', tag: 'Connectivity', error: e);
      return false;
    }
  }

  /// Handle connectivity change
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;

    // Check if any connection is available
    _isConnected = results.any((result) =>
      result != ConnectivityResult.none
    );

    // Only notify if status changed
    if (wasConnected != _isConnected) {
      AppLogger.info(
        _isConnected ? 'Network connected' : 'Network disconnected',
        tag: 'Connectivity',
      );
      _connectivityController.add(_isConnected);
    }
  }

  /// Check if currently connected (async check)
  Future<bool> checkConnection() async {
    return await _checkConnectivity();
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
