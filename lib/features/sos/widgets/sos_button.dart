import 'package:flutter/material.dart';

class SosButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SosButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              spreadRadius: 10,
              blurRadius: 20,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'SOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
