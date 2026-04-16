import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../core/providers/sos_provider.dart';

class SosButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  const SosButton({super.key, required this.onPressed, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final sosProvider = Provider.of<SosProvider>(context);
    final isSosActive = sosProvider.isSosActive;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: isSosActive ? () {
          HapticFeedback.heavyImpact();
          sosProvider.stopSos();
        } : onPressed,
        onLongPress: isSosActive ? null : () {
          HapticFeedback.heavyImpact();
          onLongPress();
        },
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFFFF5252), // Bright Red
                Color(0xFFD32F2F), // Darker Red
              ],
              center: Alignment(-0.2, -0.2),
              radius: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5252).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
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
              // Inner Shine
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
              // SOS / Stop Text
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
    );
  }
}
