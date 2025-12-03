import 'package:flutter/material.dart';

/// VyaptIX Logo Widget
/// Creates a custom logo matching the VyaptIX brand identity
class VyaptixLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool showPoweredBy;

  const VyaptixLogo({
    super.key,
    this.size = 120,
    this.showTagline = false,
    this.showPoweredBy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon - Stylized square with circuit board design
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00B4DB), // Light cyan-blue
                Color(0xFF0083B0), // Medium blue
                Color(0xFF005C8A), // Darker blue
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0083B0).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _VyaptixLogoPainter(),
            child: Container(),
          ),
        ),

        if (showTagline) ...[
          const SizedBox(height: 16),
          // Brand Name
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFF0083B0), // Blue
                Color(0xFF00B4DB), // Light blue
              ],
            ).createShader(bounds),
            child: const Text(
              'VyaptIX',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Gradient Line
          Container(
            height: 2,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0083B0), // Blue
                  Color(0xFF00D4AA), // Green
                  Color(0xFFFFD700), // Yellow
                  Color(0xFFFF8C00), // Orange
                  Color(0xFFFF4500), // Red
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Tagline with gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFF0083B0), // Blue
                Color(0xFF00D4AA), // Green
                Color(0xFFFFD700), // Yellow
                Color(0xFFFF8C00), // Orange
                Color(0xFFFF4500), // Red
              ],
            ).createShader(bounds),
            child: const Text(
              'Pervasive Intelligence',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],

        if (showPoweredBy) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Powered by ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'VyaptIX',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '®',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Custom painter for VyaptIX logo circuit board design
class _VyaptixLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.white.withOpacity(0.9);

    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final greenNodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF00D4AA); // Green accent

    final nodeRadius = 4.0;

    // Left side nodes (3 nodes)
    final leftNodes = [
      Offset(size.width * 0.25, size.height * 0.3),
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.25, size.height * 0.7),
    ];

    // Right side node (1 green node)
    final rightNode = Offset(size.width * 0.75, size.height * 0.4);

    // Draw circuit paths
    final path = Path();
    
    // Path from left nodes to center curve
    for (var i = 0; i < leftNodes.length; i++) {
      final node = leftNodes[i];
      path.moveTo(node.dx + nodeRadius, node.dy);
      
      // Curved path to center-right
      final controlPoint1 = Offset(size.width * 0.4, node.dy);
      final controlPoint2 = Offset(size.width * 0.6, size.height * 0.4);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        rightNode.dx - nodeRadius,
        rightNode.dy,
      );
    }

    canvas.drawPath(path, paint);

    // Draw nodes
    for (final node in leftNodes) {
      canvas.drawCircle(node, nodeRadius, nodePaint);
    }
    
    // Draw green accent node
    canvas.drawCircle(rightNode, nodeRadius * 1.2, greenNodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
