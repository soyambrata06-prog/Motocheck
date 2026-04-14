import 'package:flutter/material.dart';

class IllegalTag extends StatelessWidget {
  const IllegalTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red),
      ),
      child: const Text(
        'ILLEGAL',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
