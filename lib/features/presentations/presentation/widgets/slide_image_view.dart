/// Image slide view widget
import 'package:flutter/material.dart';

class SlideImageView extends StatelessWidget {
  final String imageUrl;
  final String? thumbnailUrl;

  const SlideImageView({
    super.key,
    required this.imageUrl,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            // Handle error - could show placeholder
          },
        ),
      ),
      child: thumbnailUrl != null
          ? Image.network(
              thumbnailUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return Image.network(imageUrl, fit: BoxFit.cover);
                }
                return const Center(child: CircularProgressIndicator());
              },
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 64),
                );
              },
            ),
    );
  }
}

