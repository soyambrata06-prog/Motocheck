import 'package:flutter/material.dart';
import '../../../data/models/bike_model.dart';

class BikeCard extends StatelessWidget {
  final BikeModel bike;

  const BikeCard({super.key, required this.bike});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(bike.plateNumber, style: Theme.of(context).textTheme.headlineMedium),
            Text('${bike.make} ${bike.model}'),
          ],
        ),
      ),
    );
  }
}
