import 'package:flutter/material.dart';

class SkeletonTile extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonTile({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 16,
  });

  @override
  State<SkeletonTile> createState() => _SkeletonTileState();
}

class _SkeletonTileState extends State<SkeletonTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFF1F1F1),
                Color(0xFFE0E0E0),
                Color(0xFFF1F1F1),
              ],
              stops: [
                0.0,
                (_animation.value + 1) / 2,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
