import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildAction(Icons.history, 'History'),
        _buildAction(Icons.star, 'Favorites'),
        _buildAction(Icons.help_outline, 'Help'),
      ],
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
