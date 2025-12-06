import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wedly/data/models/banner_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'skeleton_image.dart';

/// Widget that displays a carousel of promotional banners
/// Banners are configured by admin and can optionally have links
class BannersCarouselWidget extends StatefulWidget {
  final List<BannerModel> banners;
  final double? height;
  final double viewportFraction;
  final bool autoplay;
  final Duration autoplayDuration;
  final bool showIndicators;
  final Color? accentColor;

  const BannersCarouselWidget({
    super.key,
    required this.banners,
    this.height,
    this.viewportFraction = 0.9,
    this.autoplay = true,
    this.autoplayDuration = const Duration(seconds: 4),
    this.showIndicators = true,
    this.accentColor,
  });

  @override
  State<BannersCarouselWidget> createState() => _BannersCarouselWidgetState();
}

class _BannersCarouselWidgetState extends State<BannersCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoplayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        int next = _pageController.page!.round();
        if (_currentPage != next) {
          setState(() {
            _currentPage = next;
          });
        }
      }
    });

    // Start autoplay if enabled
    if (widget.autoplay && widget.banners.length > 1) {
      _startAutoplay();
    }
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoplay() {
    _autoplayTimer = Timer.periodic(widget.autoplayDuration, (timer) {
      if (_pageController.hasClients && mounted) {
        int nextPage = (_currentPage + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final accentColor = widget.accentColor ?? const Color(0xFFD4AF37);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive height calculation
        final carouselHeight =
            widget.height ?? (constraints.maxWidth > 600 ? 250.0 : 200.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Carousel
            SizedBox(
              height: carouselHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.banners.length,
                itemBuilder: (context, index) {
                  final banner = widget.banners[index];
                  return _buildBannerCard(banner, index, accentColor);
                },
              ),
            ),
            if (widget.showIndicators && widget.banners.length > 1) ...[
              const SizedBox(height: 12),
              // Carousel indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.banners.length,
                  (index) =>
                      _buildIndicator(index == _currentPage, accentColor),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBannerCard(BannerModel banner, int index, Color accentColor) {
    final isActive = _currentPage == index;
    final hasLink = banner.link != null && banner.link!.isNotEmpty;

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
          onTap: hasLink ? () => _handleBannerTap(banner) : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                SkeletonImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(16),
                  errorWidget: Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
                // Gradient overlay (only if there's a title)
                if (banner.titleAr != null || banner.title != null)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                // Title overlay (if exists)
                if (banner.titleAr != null || banner.title != null)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    left: 16,
                    child: Text(
                      banner.titleAr ?? banner.title ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive, Color accentColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? accentColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// Handle banner tap - open link if exists
  Future<void> _handleBannerTap(BannerModel banner) async {
    // If no link, do nothing (silent - no feedback to user)
    if (banner.link == null || banner.link!.isEmpty) {
      return;
    }

    try {
      final uri = Uri.parse(banner.link!);

      // Try to launch the URL
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      // If launch failed, show user-friendly message
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'عذراً، حاول مرة أخرى لاحقاً',
              textDirection: TextDirection.rtl,
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFFD4AF37),
          ),
        );
      }
    } catch (e) {
      // If any error (invalid URL, network issue, etc.), show user-friendly message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'عذراً، حاول مرة أخرى لاحقاً',
              textDirection: TextDirection.rtl,
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFFD4AF37),
          ),
        );
      }
    }
  }
}
