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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
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
                    'Current Noise',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  Text(
                    '${decibel.toStringAsFixed(1)} dB',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isOverLimit ? Colors.red : const Color(0xFF00C853),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isOverLimit ? Colors.red : const Color(0xFF00C853)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOverLimit ? 'ILLEGAL' : 'LEGAL',
                  style: TextStyle(
                    color: isOverLimit ? Colors.red : const Color(0xFF00C853),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: decibel / 120,
              minHeight: 12,
              backgroundColor: isDark ? Colors.black : Colors.grey[300],
              color: isOverLimit ? Colors.red : const Color(0xFF00C853),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 dB', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              Text('Limit: $limit dB', style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
              Text('120 dB', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

