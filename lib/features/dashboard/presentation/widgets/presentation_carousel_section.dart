import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../presentations/presentation/widgets/presentation_carousel.dart';
import '../../../presentations/presentation/viewmodels/presentation_viewmodel.dart';
import '../../../presentations/data/models/presentation_model.dart';

/// Presentation Carousel Section for Agent Dashboard
/// Includes carousel display with edit button and empty state handling
class PresentationCarouselSection extends StatefulWidget {
  final String agentId;
  final double? height;

  const PresentationCarouselSection({
    super.key,
    required this.agentId,
    this.height,
  });

  @override
  State<PresentationCarouselSection> createState() => _PresentationCarouselSectionState();
}

class _PresentationCarouselSectionState extends State<PresentationCarouselSection> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load presentation once when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _loadPresentation();
      }
    });
  }

  void _loadPresentation() {
    if (_hasLoaded) return;
    _hasLoaded = true;

    final viewModel = Provider.of<PresentationViewModel>(context, listen: false);
    viewModel.loadActivePresentation(widget.agentId);
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<PresentationViewModel>(
      builder: (context, viewModel, child) {
        // Loading state
        if (viewModel.isLoading) {
          return Container(
            height: widget.height ?? 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Error state
        if (viewModel.hasError) {
          return Container(
            height: widget.height ?? 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade300, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Failed to load presentation',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => viewModel.loadActivePresentation(widget.agentId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final presentation = viewModel.activePresentation;

        // Empty state - no active presentation
        if (presentation == null || presentation.slides.isEmpty) {
          return _buildEmptyState(context);
        }

        // Carousel with edit button
        return _buildCarouselWithEdit(context, presentation);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: widget.height ?? 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.slideshow,
            size: 48,
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'No Active Presentation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a presentation to showcase your products',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToEditor(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Presentation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselWithEdit(BuildContext context, PresentationModel presentation) {
    return Container(
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Carousel
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PresentationCarousel(
              agentId: widget.agentId,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              showIndicators: true,
            ),
          ),
          // Edit button overlay
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => _navigateToEditor(context, presentation.presentationId),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditor(BuildContext context, [String? presentationId]) {
    if (presentationId != null) {
      context.push('/presentation-editor', extra: {'presentationId': presentationId});
    } else {
      context.push('/presentation-editor');
    }
  }
}

