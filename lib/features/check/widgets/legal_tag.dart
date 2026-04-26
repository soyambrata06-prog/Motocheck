import 'package:flutter/material.dart';

class LegalTag extends StatefulWidget {
  final bool isLegal;
  const LegalTag({super.key, this.isLegal = true});

  @override
  State<LegalTag> createState() => _LegalTagState();
}

class _LegalTagState extends State<LegalTag> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.1, end: 0.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isLegal ? const Color(0xFF00C853) : const Color(0xFFFF3D00);
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(_pulseAnimation.value),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10 * _pulseAnimation.value,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isLegal ? Icons.check_circle : Icons.warning_rounded,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                widget.isLegal ? 'LEGAL' : 'ILLEGAL',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

