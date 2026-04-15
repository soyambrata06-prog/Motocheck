import 'package:flutter/material.dart';
import 'dart:async';
import 'result_screen.dart';

class ScanPlateScreen extends StatefulWidget {
  const ScanPlateScreen({super.key});

  @override
  State<ScanPlateScreen> createState() => _ScanPlateScreenState();
}

class _ScanPlateScreenState extends State<ScanPlateScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isCaptured = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.2, end: 0.8).animate(_controller);

    // Simulate auto-capture after 3 seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isCaptured = true;
        });
        Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ResultScreen()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mock Camera Preview
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1558981403-c5f91cbba527?q=80&w=2070&auto=format&fit=crop'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
          ),
          
          // Scanning Overlay
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'SCAN PLATE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flash_on, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                
                // Scanning Frame
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Animated Scanning Line
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Positioned(
                              top: 120 * _animation.value,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00C853).withOpacity(0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  color: const Color(0xFF00C853),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Corner Borders
                        _buildCorner(0),
                        _buildCorner(1),
                        _buildCorner(2),
                        _buildCorner(3),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                const Text(
                  'Align license plate within the frame',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const Spacer(),
                
                // Bottom UI
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: _isCaptured 
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF00C853), strokeWidth: 3),
                            SizedBox(width: 20),
                            Text('Processing Plate...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : const Text(
                          'AI Scanning Active',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(int index) {
    const double size = 30;
    const double thickness = 4;
    final color = const Color(0xFF00C853);
    
    return Positioned(
      top: (index == 0 || index == 1) ? -2 : null,
      bottom: (index == 2 || index == 3) ? -2 : null,
      left: (index == 0 || index == 2) ? -2 : null,
      right: (index == 1 || index == 3) ? -2 : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(
            top: (index == 0 || index == 1) ? BorderSide(color: color, width: thickness) : BorderSide.none,
            bottom: (index == 2 || index == 3) ? BorderSide(color: color, width: thickness) : BorderSide.none,
            left: (index == 0 || index == 2) ? BorderSide(color: color, width: thickness) : BorderSide.none,
            right: (index == 1 || index == 3) ? BorderSide(color: color, width: thickness) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: index == 0 ? const Radius.circular(15) : Radius.zero,
            topRight: index == 1 ? const Radius.circular(15) : Radius.zero,
            bottomLeft: index == 2 ? const Radius.circular(15) : Radius.zero,
            bottomRight: index == 3 ? const Radius.circular(15) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
