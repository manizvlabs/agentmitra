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

          // Text overlay
          if (slide.title != null || slide.subtitle != null)
            SlideTextOverlay(
              title: slide.title,
              subtitle: slide.subtitle,
              textColor: _parseColor(slide.textColor),
              layout: slide.layout,
            ),

          // CTA Button
          if (slide.ctaButton != null)
            _buildCTAButton(context, slide.ctaButton!),
        ],
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context, Map<String, dynamic> ctaButton) {
    final text = ctaButton['text'] ?? 'Click Here';
    final action = ctaButton['action'];
    final position = ctaButton['position'] ?? 'bottom-center';

    return Positioned(
      bottom: 40,
      left: position.contains('left') ? 20 : null,
      right: position.contains('right') ? 20 : null,
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            // Handle CTA action
            if (action != null) {
              // Navigate or perform action
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}

