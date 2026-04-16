import 'package:flutter/material.dart';

class DecibelIndicator extends StatelessWidget {
  final double decibel;
  final double limit;

  const DecibelIndicator({
    super.key,
    required this.decibel,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverLimit = decibel > limit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: primaryColor.withOpacity(0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT NOISE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${decibel.toStringAsFixed(1)} dB',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: isOverLimit ? Colors.redAccent : const Color(0xFF00C853),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (isOverLimit ? Colors.redAccent : const Color(0xFF00C853)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isOverLimit ? Colors.redAccent : const Color(0xFF00C853)).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  isOverLimit ? 'ILLEGAL' : 'LEGAL',
                  style: TextStyle(
                    color: isOverLimit ? Colors.redAccent : const Color(0xFF00C853),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (decibel / 120).clamp(0.0, 1.0),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOverLimit ? Colors.redAccent : const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: (isOverLimit ? Colors.redAccent : const Color(0xFF00C853)).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 dB',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ),
              Text(
                'LIMIT: $limit dB',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              Text(
                '120 dB',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
