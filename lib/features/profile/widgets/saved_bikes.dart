import 'package:flutter/material.dart';

class SavedBikes extends StatelessWidget {
  const SavedBikes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Saved Bikes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.motorcycle, size: 40),
                      const SizedBox(height: 8),
                      Text('Bike #$index'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
