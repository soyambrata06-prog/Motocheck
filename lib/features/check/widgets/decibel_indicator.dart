import 'package:flutter/material.dart';

class DecibelIndicator extends StatelessWidget {
  final double value;
  final double limit;

  const DecibelIndicator({
    super.key,
    required this.value,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverLimit = value > limit;
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)} dB',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isOverLimit ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 120, // Assuming 120 as max
          backgroundColor: Colors.grey[300],
          color: isOverLimit ? Colors.red : Colors.green,
        ),
        Text('Limit: $limit dB'),
      ],
    );
  }
}
