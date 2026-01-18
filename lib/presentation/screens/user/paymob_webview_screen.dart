import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobWebViewScreen extends StatefulWidget {
  final String iframeUrl;
  final void Function(bool success, String? message) onPaymentComplete;

  /// Optional: if you redirect to your own site after payment, put your domain here
  final String? resultHost; // e.g. "api.yourapp.com" or "yourdomain.com"

  const PaymobWebViewScreen({
    super.key,
    required this.iframeUrl,
    required this.onPaymentComplete,
    this.resultHost,
  });

  @override
  State<PaymobWebViewScreen> createState() => _PaymobWebViewScreenState();
}

class _PaymobWebViewScreenState extends State<PaymobWebViewScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;
  String? _errorMessage;

  bool _completed = false; // guard against multiple calls

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _maybeDetectResult(url);
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            _maybeDetectResult(url);
          },
          onNavigationRequest: (request) {
            final url = request.url;

            // Block non-http(s) schemes to avoid crashes / unwanted intents
            final uri = Uri.tryParse(url);
            final scheme = uri?.scheme.toLowerCase();
            if (scheme != 'http' && scheme != 'https') {
              return NavigationDecision.prevent;
            }

            _maybeDetectResult(url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _errorMessage = 'حدث خطأ في تحميل صفحة الدفع';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.iframeUrl));
  }

  void _maybeDetectResult(String url) {
    if (_completed) return;

    // Recommended: only treat redirects to YOUR domain as final status
    // because Paymob URLs and params may vary.
    final uri = Uri.tryParse(url);
    final host = uri?.host;

    final isOurResultPage =
        widget.resultHost != null && host == widget.resultHost;

    if (!isOurResultPage) {
      // If you insist on Paymob param detection, keep it very conservative,
      // or remove this section entirely.
      return;
    }

    // Example patterns on your own hosted result pages:
    if (url.contains('status=success') || url.contains('/payment/success')) {
      _finish(true, 'تم الدفع بنجاح');
    } else if (url.contains('status=fail') ||
        url.contains('status=declined') ||
        url.contains('/payment/fail')) {
      _finish(false, 'فشل الدفع');
    } else if (url.contains('status=cancel') || url.contains('/payment/cancel')) {
      _finish(false, 'تم إلغاء الدفع');
    }
  }

  void _finish(bool success, String? message) {
    if (_completed) return;
    _completed = true;
    widget.onPaymentComplete(success, message);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          _showCancelDialog();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFFD4AF37),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _showCancelDialog,
            ),
            centerTitle: true,
            title: const Text(
              'إتمام الدفع',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Stack(
            children: [
              if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _finish(false, 'تعذر فتح صفحة الدفع'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          child: const Text(
                            'رجوع',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                WebViewWidget(controller: _controller),

              if (_isLoading)
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('جاري تحميل صفحة الدفع...'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إلغاء الدفع',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('هل تريد إلغاء عملية الدفع والعودة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('متابعة الدفع',
                  style: TextStyle(color: Color(0xFFD4AF37))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                _finish(false, 'تم إلغاء الدفع');
              },
              child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
