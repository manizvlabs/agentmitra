/// Video slide view widget
import 'package:flutter/material.dart';

class SlideVideoView extends StatelessWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const SlideVideoView({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Note: For video playback, you'd typically use video_player package
    // This is a placeholder implementation
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (thumbnailUrl != null)
            Image.network(
              thumbnailUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          const Icon(
            Icons.play_circle_outline,
            size: 64,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

