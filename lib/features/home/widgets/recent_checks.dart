import 'package:flutter/material.dart';

class RecentChecks extends StatelessWidget {
  const RecentChecks({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Checks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.motorcycle),
              title: Text('ABC-123$index'),
              subtitle: const Text('Checked 2 days ago'),
              trailing: const Icon(Icons.chevron_right),
            );
          },
        ),
      ],
    );
  }
}
