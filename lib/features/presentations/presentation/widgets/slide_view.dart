/// Slide view widget - renders individual slides
import 'package:flutter/material.dart';
import '../../data/models/slide_model.dart';
import 'slide_image_view.dart';
import 'slide_video_view.dart';
import 'slide_text_overlay.dart';

class SlideView extends StatelessWidget {
  final SlideModel slide;

  const SlideView({
    super.key,
    required this.slide,
  });

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _parseColor(slide.backgroundColor),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media content
          if (slide.slideType == 'image' && slide.mediaUrl != null)
            SlideImageView(
              imageUrl: slide.mediaUrl!,
              thumbnailUrl: slide.thumbnailUrl,
            )
          else if (slide.slideType == 'video' && slide.mediaUrl != null)
            SlideVideoView(
              videoUrl: slide.mediaUrl!,
              thumbnailUrl: slide.thumbnailUrl,
            )
          else
            Container(),

          // Overlay with opacity
          Container(
            color: _parseColor(slide.backgroundColor)
                .withOpacity(slide.overlayOpacity),
          ),

          // Text overlay
          if (slide.title != null || slide.subtitle != null)
            SlideTextOverlay(
              title: slide.title,
              subtitle: slide.subtitle,
              textColor: _parseColor(slide.textColor),
              layout: slide.layout,
            ),

          // CTA Button
          if (slide.ctaButton != null && 
              slide.ctaButton!['enabled'] != false)
            _buildCTAButton(context, slide.ctaButton!),

          // Agent Branding
          if (slide.agentBranding != null)
            _buildAgentBranding(context, slide.agentBranding!),
        ],
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context, Map<String, dynamic> ctaButton) {
    final text = ctaButton['text'] ?? 'Click Here';
    final action = ctaButton['action'];
    final position = ctaButton['position'] ?? 'bottom-center';
    final backgroundColor = ctaButton['backgroundColor'] ?? '#C62828';
    final textColor = ctaButton['textColor'] ?? '#FFFFFF';

    return Positioned(
      bottom: 20,
      left: position.contains('left') ? 20 : null,
      right: position.contains('right') ? 20 : null,
      child: Center(
        child: ElevatedButton(
          onPressed: () => _handleCTAAction(context, action),
          style: ElevatedButton.styleFrom(
            backgroundColor: _parseColor(backgroundColor),
            foregroundColor: _parseColor(textColor),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text(text),
        ),
      ),
    );
  }

  void _handleCTAAction(BuildContext context, String? action) {
    if (action == null) return;

    // Handle different action types
    switch (action) {
      case 'navigate_to_quote':
        // Navigate to quote page
        // Navigator.pushNamed(context, '/quote');
        break;
      case 'navigate_to_contact':
        // Navigate to contact page
        // Navigator.pushNamed(context, '/contact');
        break;
      case 'navigate_to_products':
        // Navigate to products page
        // Navigator.pushNamed(context, '/products');
        break;
      default:
        // Handle custom actions or URLs
        if (action.startsWith('http://') || action.startsWith('https://')) {
          // Open URL
          // url_launcher.launchUrl(Uri.parse(action));
        } else if (action.startsWith('/')) {
          // Navigate to route
          // Navigator.pushNamed(context, action);
        }
        break;
    }
  }

  Widget _buildAgentBranding(BuildContext context, Map<String, dynamic> branding) {
    final showLogo = branding['showLogo'] ?? false;
    final logoUrl = branding['logoUrl'];
    final showContact = branding['showContact'] ?? false;
    final contactText = branding['contactText'] ?? 'Talk to me';

    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showLogo && logoUrl != null)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  logoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.business, size: 32);
                  },
                ),
              ),
            ),
          if (showContact) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _handleCTAAction(context, 'navigate_to_contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(contactText),
            ),
          ],
        ],
      ),
    );
  }
}

