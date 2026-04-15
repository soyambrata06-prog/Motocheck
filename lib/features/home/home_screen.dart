import 'package:flutter/material.dart';
import '../shared/widgets/skeleton_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 25),
                const SkeletonTile(height: 180, borderRadius: 24),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: SkeletonTile(height: 100)),
                    SizedBox(width: 15),
                    Expanded(child: SkeletonTile(height: 100)),
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                const SkeletonTile(height: 80),
                const SizedBox(height: 12),
                const SkeletonTile(height: 80),
                const SizedBox(height: 12),
                const SkeletonTile(height: 80),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
