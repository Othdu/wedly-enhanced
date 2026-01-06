import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wedly/data/models/offer_model.dart';
import 'skeleton_image.dart';

/// Widget that displays a carousel of promotional offers from the API
/// Responsive and reusable across different screens
class OffersCarouselWidget extends StatefulWidget {
  final List<OfferModel> offers;
  final Function(OfferModel)? onOfferTap;
  final VoidCallback? onSeeAllTap;
  final double? height;
  final double viewportFraction;
  final bool autoplay;
  final Duration autoplayDuration;
  final bool showIndicators;
  final Color? accentColor;
  final bool showHeader;

  const OffersCarouselWidget({
    super.key,
    required this.offers,
    this.onOfferTap,
    this.onSeeAllTap,
    this.height,
    this.viewportFraction = 0.9,
    this.autoplay = false,
    this.autoplayDuration = const Duration(seconds: 3),
    this.showIndicators = true,
    this.accentColor,
    this.showHeader = true,
  });

  @override
  State<OffersCarouselWidget> createState() => _OffersCarouselWidgetState();
}

class _OffersCarouselWidgetState extends State<OffersCarouselWidget> {
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
    if (widget.autoplay && widget.offers.length > 1) {
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
        int nextPage = (_currentPage + 1) % widget.offers.length;
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
    if (widget.offers.isEmpty) {
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
            // Header with title and "See All" button
            if (widget.showHeader) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // "المزيد" button on the left

                    // "عروض الأسبوع" title on the right
                    const Text(
                      'عروض الأسبوع',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    GestureDetector(
                      onTap: widget.onSeeAllTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'المزيد',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: accentColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Carousel
            SizedBox(
              height: carouselHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.offers.length,
                itemBuilder: (context, index) {
                  final offer = widget.offers[index];
                  return _buildOfferCard(offer, index, accentColor);
                },
              ),
            ),
            if (widget.showIndicators && widget.offers.length > 1) ...[
              const SizedBox(height: 12),
              // Carousel indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.offers.length,
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

  Widget _buildOfferCard(OfferModel offer, int index, Color accentColor) {
    final isActive = _currentPage == index;

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
          onTap: () {
            debugPrint('🎨 OffersCarouselWidget: Offer card tapped: ${offer.titleAr}');
            widget.onOfferTap?.call(offer);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                SkeletonImage(
                  imageUrl: offer.imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(16),
                  errorWidget: const Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                // Content
                Positioned(
                  bottom: 16,
                  right: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (offer.discount != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            offer.discount!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        offer.titleAr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.descriptionAr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'عرض التفاصيل',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
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
}
