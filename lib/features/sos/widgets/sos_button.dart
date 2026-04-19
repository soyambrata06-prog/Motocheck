import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../core/providers/sos_provider.dart';

class SosButton extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  const SosButton({super.key, required this.onPressed, required this.onLongPress});

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onLongPress();
        _controller.reset();
        setState(() => _isHolding = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!Provider.of<SosProvider>(context, listen: false).isSosActive) {
      setState(() => _isHolding = true);
      _controller.forward();
      HapticFeedback.mediumImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isHolding) {
      setState(() => _isHolding = false);
      if (_controller.value < 1.0) {
        _controller.reverse();
      }
    }
  }

  void _handleTapCancel() {
    if (_isHolding) {
      setState(() => _isHolding = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosProvider = Provider.of<SosProvider>(context);
    final isSosActive = sosProvider.isSosActive;

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: isSosActive ? null : _handleTapDown,
        onTapUp: isSosActive ? null : _handleTapUp,
        onTapCancel: isSosActive ? null : _handleTapCancel,
        onTap: isSosActive ? () {
          HapticFeedback.heavyImpact();
          sosProvider.stopSos();
        } : widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = 1.0 - (0.06 * _controller.value);
            
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [

                if (_isHolding)
                  ...List.generate(3, (index) {

                    double pulseProgress = (_controller.value * 2.5 - (index * 0.4)).clamp(0.0, 1.0);
                    if (pulseProgress <= 0) return const SizedBox.shrink();
                    
                    return Transform.scale(
                      scale: 1.0 + (0.8 * pulseProgress),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF5252).withOpacity((1 - pulseProgress) * 0.4),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }),

                if (_isHolding)
                  Transform.scale(
                    scale: 1.0 + (0.2 * _controller.value),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF5252).withOpacity(0.08 * _controller.value),
                      ),
                    ),
                  ),

                Transform.scale(
                  scale: _isHolding ? scale : 1.0,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFFFF5252),
                          Color(0xFFD32F2F),
                        ],
                        center: Alignment(-0.2, -0.2),
                        radius: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withOpacity(_isHolding ? 0.4 + (0.2 * _controller.value) : 0.3),
                          blurRadius: _isHolding ? 30 + (20 * _controller.value) : 30,
                          spreadRadius: _isHolding ? 5 + (10 * _controller.value) : 5,
                          offset: const Offset(0, 10),
                        ),
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: -2,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isSosActive ? 'STOP' : 'SOS',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              isSosActive ? 'SAFE NOW?' : 'EMERGENCY',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
