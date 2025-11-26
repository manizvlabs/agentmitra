import 'package:flutter/material.dart';

/// Skeleton Loader Widget
/// Displays animated skeleton loading placeholders
class SkeletonLoader extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const SkeletonLoader({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor ?? Colors.grey.shade300,
                widget.highlightColor ?? Colors.grey.shade100,
                widget.baseColor ?? Colors.grey.shade300,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton Text Widget
class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonText({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// Skeleton Circle Widget
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Skeleton Card Widget
class SkeletonCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? padding;

  const SkeletonCard({
    super.key,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Container(
        height: height,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: height != null
            ? SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonText(width: double.infinity, height: 14),
                    const SizedBox(height: 6),
                    SkeletonText(width: 180, height: 10),
                    const SizedBox(height: 4),
                    SkeletonText(width: 120, height: 10),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonText(width: double.infinity, height: 14),
                  const SizedBox(height: 6),
                  SkeletonText(width: 180, height: 10),
                  const SizedBox(height: 4),
                  Flexible(
                    child: SkeletonText(width: 120, height: 10),
                  ),
                ],
              ),
      ),
    );
  }
}

