import 'package:flutter/material.dart';

class LegalTag extends StatelessWidget {
  final bool isLegal;
  const LegalTag({super.key, this.isLegal = true});

  @override
  Widget build(BuildContext context) {
    final color = isLegal ? const Color(0xFF00C853) : const Color(0xFFFF3D00);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLegal ? Icons.check_circle : Icons.warning_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isLegal ? 'LEGAL' : 'ILLEGAL',
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
  }
}
