/// Presentation carousel widget
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/presentation_viewmodel.dart';
import 'slide_view.dart';
import '../../data/models/presentation_model.dart';
import '../../data/models/slide_model.dart';

class PresentationCarousel extends StatefulWidget {
  final String agentId;
  final double height;
  final bool autoPlay;
  final Duration? autoPlayInterval;
  final bool showIndicators;
  final Function(SlideModel)? onSlideTap;

  const PresentationCarousel({
    super.key,
    required this.agentId,
    this.height = 220,
    this.autoPlay = true,
    this.autoPlayInterval,
    this.showIndicators = true,
    this.onSlideTap,
  });

  @override
  State<PresentationCarousel> createState() => _PresentationCarouselState();
}

class _PresentationCarouselState extends State<PresentationCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    // Remove automatic loading - parent widget should handle this
  }

  void _refreshPresentation() {
    // Refresh is now handled by parent widget
    final viewModel =
        Provider.of<PresentationViewModel>(context, listen: false);
    viewModel.refreshActivePresentation(widget.agentId);
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay(PresentationModel? presentation) {
    if (!widget.autoPlay || presentation == null) return;

    _autoPlayTimer?.cancel();
    final slides = presentation.slides;
    if (slides.isEmpty) return;

    _autoPlayTimer = Timer.periodic(
      widget.autoPlayInterval ??
          Duration(seconds: slides[_currentIndex].duration),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_currentIndex < slides.length - 1) {
          _currentIndex++;
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _currentIndex = 0;
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  void _onPageChanged(int index, PresentationModel? presentation) {
    setState(() {
      _currentIndex = index;
    });

    if (presentation != null && presentation.slides.isNotEmpty) {
      _autoPlayTimer?.cancel();
      _startAutoPlay(presentation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PresentationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  viewModel.errorMessage ?? 'Failed to load presentation',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshPresentation,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final presentation = viewModel.activePresentation;
        if (presentation == null || presentation.slides.isEmpty) {
          return _buildEmptyState();
        }

        // Start auto-play when presentation is loaded
        if (_autoPlayTimer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startAutoPlay(presentation);
          });
        }

        return RefreshIndicator(
          onRefresh: () async => _refreshPresentation(),
          child: SizedBox(
            height: widget.height,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: presentation.slides.length,
                    onPageChanged: (index) => _onPageChanged(index, presentation),
                    itemBuilder: (context, index) {
                      final slide = presentation.slides[index];
                      return GestureDetector(
                        onTap: widget.onSlideTap != null
                            ? () => widget.onSlideTap!(slide)
                            : null,
                        child: SlideView(slide: slide),
                      );
                    },
                  ),
                ),
                if (widget.showIndicators && presentation.slides.length > 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        presentation.slides.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.slideshow_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No active presentation',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a presentation to display here',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

