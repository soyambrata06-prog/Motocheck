import 'package:flutter/material.dart';
import 'widgets/intro_card.dart';
import '../../routes/route_names.dart';

class IntroScreen2 extends StatelessWidget {
  const IntroScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: IntroCard(
                title: 'Quick SOS Response',
                description: 'Get immediate help during emergencies with our integrated SOS feature.',
                icon: Icons.emergency,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, RouteNames.authChoice);
                },
                child: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
