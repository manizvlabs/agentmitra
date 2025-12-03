import 'package:flutter/material.dart';

/// Copyright Footer Widget
/// Displays copyright, trademark, and legal information
class CopyrightFooter extends StatelessWidget {
  final bool showFullDetails;
  final TextStyle? textStyle;
  final Color? textColor;

  const CopyrightFooter({
    super.key,
    this.showFullDetails = true,
    this.textStyle,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      fontSize: 10,
      color: textColor ?? Colors.white.withOpacity(0.7),
      fontWeight: FontWeight.w400,
      letterSpacing: 0.3,
    );

    final style = textStyle ?? defaultTextStyle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFullDetails) ...[
          // Copyright notice
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: style,
              children: [
                const TextSpan(text: '© 2025 '),
                TextSpan(
                  text: 'Agent Mitra',
                  style: style.copyWith(fontWeight: FontWeight.w600),
                ),
                const TextSpan(
                  text: '™',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: '. All Rights Reserved.'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Trademark and registered marks
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Agent Mitra',
                style: style.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '™',
                style: style.copyWith(
                  fontSize: style.fontSize! * 0.7,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' is a trademark of ',
                style: style,
              ),
              Text(
                'VyaptIX',
                style: style.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '®',
                style: style.copyWith(
                  fontSize: style.fontSize! * 0.7,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '.',
                style: style,
              ),
            ],
          ),
          const SizedBox(height: 4),
          // VyaptIX registered trademark
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'VyaptIX',
                style: style.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '®',
                style: style.copyWith(
                  fontSize: style.fontSize! * 0.7,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' Pervasive Intelligence - Registered Trademark',
                style: style,
              ),
            ],
          ),
        ] else ...[
          // Compact version
          Text(
            '© 2025 Agent Mitra™ | VyaptIX®',
            style: style,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Simple Copyright Text Widget (for minimal displays)
class SimpleCopyright extends StatelessWidget {
  final Color? textColor;
  final double fontSize;

  const SimpleCopyright({
    super.key,
    this.textColor,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '© 2025 Agent Mitra™ | VyaptIX®',
      style: TextStyle(
        fontSize: fontSize,
        color: textColor ?? Colors.white.withOpacity(0.6),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    );
  }
}
