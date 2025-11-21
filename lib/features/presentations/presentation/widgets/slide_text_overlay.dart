/// Text overlay widget for slides
import 'package:flutter/material.dart';

class SlideTextOverlay extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Color textColor;
  final String layout; // 'centered', 'top', 'bottom', 'left', 'right'

  const SlideTextOverlay({
    super.key,
    this.title,
    this.subtitle,
    required this.textColor,
    this.layout = 'centered',
  });

  Alignment _getAlignment() {
    switch (layout) {
      case 'top':
        return Alignment.topCenter;
      case 'bottom':
        return Alignment.bottomCenter;
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  EdgeInsets _getPadding() {
    switch (layout) {
      case 'top':
        return const EdgeInsets.only(top: 60);
      case 'bottom':
        return const EdgeInsets.only(bottom: 60);
      case 'left':
        return const EdgeInsets.only(left: 40);
      case 'right':
        return const EdgeInsets.only(right: 40);
      default:
        return const EdgeInsets.all(40);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (title == null && subtitle == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: _getAlignment(),
      child: Padding(
        padding: _getPadding(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title!,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                textAlign: layout == 'centered' ? TextAlign.center : TextAlign.left,
              ),
            if (title != null && subtitle != null) const SizedBox(height: 12),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                textAlign: layout == 'centered' ? TextAlign.center : TextAlign.left,
              ),
          ],
        ),
      ),
    );
  }
}

