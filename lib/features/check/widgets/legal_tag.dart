import 'package:flutter/material.dart';

class LegalTag extends StatelessWidget {
  const LegalTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green),
      ),
      child: const Text(
        'LEGAL',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
