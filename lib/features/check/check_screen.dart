import 'package:flutter/material.dart';
import '../shared/widgets/skeleton_tile.dart';

class CheckScreen extends StatelessWidget {
  const CheckScreen({super.key});

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
                  'Search',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 25),
                // Search Bar Skeleton
                const SkeletonTile(height: 56, borderRadius: 16),
                const SizedBox(height: 30),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: const [
                    Expanded(child: SkeletonTile(height: 120)),
                    SizedBox(width: 15),
                    Expanded(child: SkeletonTile(height: 120)),
                    SizedBox(width: 15),
                    Expanded(child: SkeletonTile(height: 120)),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Search History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                const SkeletonTile(height: 70),
                const SizedBox(height: 12),
                const SkeletonTile(height: 70),
                const SizedBox(height: 12),
                const SkeletonTile(height: 70),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
