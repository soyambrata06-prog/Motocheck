import 'package:flutter/material.dart';
import '../../../data/models/spec_model.dart';

class SpecCard extends StatelessWidget {
  final SpecModel spec;

  const SpecCard({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(spec.title),
      trailing: Text(
        spec.value,
        style: TextStyle(
          color: spec.isLegal ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
