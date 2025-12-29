import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wedly/core/services/connectivity_service.dart';

/// Banner widget that shows when the device is offline
/// Automatically hides when connection is restored
class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late bool _isOffline;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isOffline = !_connectivityService.isConnected;

    // Listen to connectivity changes
    _subscription = _connectivityService.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isOffline = !isConnected;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Offline banner
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isOffline ? 40 : 0,
          color: Colors.red.shade700,
          child: _isOffline
              ? const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'لا يوجد اتصال بالإنترنت',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                )
              : null,
        ),
        // Main content
        Expanded(child: widget.child),
      ],
    );
  }
}

/// A simpler offline indicator that can be used anywhere
class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late bool _isOffline;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isOffline = !_connectivityService.isConnected;

    _subscription = _connectivityService.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isOffline = !isConnected;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, color: Colors.red.shade700, size: 16),
          const SizedBox(width: 6),
          Text(
            'غير متصل',
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
