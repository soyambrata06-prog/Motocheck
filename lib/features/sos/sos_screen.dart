import 'package:flutter/material.dart';
import '../shared/widgets/skeleton_tile.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

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
                  'SOS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 25),
                // Emergency Button Skeleton
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.05),
                    ),
                    child: const Center(
                      child: SkeletonTile(
                        width: 160,
                        height: 160,
                        borderRadius: 80,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 20,
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
                const SizedBox(height: 30),
                const Text(
                  'Nearby Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      SkeletonTile(width: 140, height: 160),
                      SizedBox(width: 15),
                      SkeletonTile(width: 140, height: 160),
                      SizedBox(width: 15),
                      SkeletonTile(width: 140, height: 160),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
