import 'package:flutter/material.dart';
import 'widgets/intro_card.dart';
import '../../routes/route_names.dart';

class IntroScreen1 extends StatelessWidget {
  const IntroScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: IntroCard(
                title: 'Ride with Confidence',
                description: 'Check your bike\'s legal status and exhaust noise levels in seconds.',
                icon: Icons.motorcycle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, RouteNames.authChoice),
                    child: const Text('Skip'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.intro2);
                    },
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
