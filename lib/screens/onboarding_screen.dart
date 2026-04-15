import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToWelcome();
    }
  }

  void _goToWelcome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Shared Background Image for Page 2 & 3
            AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double page = 0;
                if (_pageController.hasClients) {
                  page = _pageController.page ?? 0;
                }

                // Unified linear movement: The bike is pinned to the background
                // and moves 1:1 with the scroll for a perfect "pinned" effect.
                double translationX = 1.56 - page;
                double opacity = 0;

                // Optimizing visibility during Page 1 -> Page 2 transition
                // The bike now fades in faster and slides from the right edge
                if (page < 1.0) {
                  // Fade in quickly so it's visible earlier in the transition
                  opacity = (page * 1.8).clamp(0.0, 1.0);
                } else {
                  opacity = 1.0;
                }

                return Positioned(
                  bottom: 260, 
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: opacity,
                    child: FractionalTranslation(
                      translation: Offset(translationX, 0),
                      child: Center(
                        child: Transform.scale(
                          scale: 2.3, 
                          child: Image.asset(
                            'assets/images/bike2.png',
                            height: 320,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: const [
                _OnboardingPage(
                  title: 'Know your bike.\nRide legal',
                  subtitle: "Easily check your bike's legality\nand ride safe.",
                  imagePath: 'assets/images/bike.png',
                  imageScale: 2.0,
                  imageOffset: Offset(15, 0),
                ),
                _OnboardingPage(
                  title: 'Check legality,\navoid fines, stay safe.',
                  subtitle: 'Scan your bike and check its legal status instantly.',
                  isFeaturePage: true,
                ),
                _OnboardingPage(
                  title: 'Stay connected,\nride with confidence.',
                  subtitle: 'Real-time updates, alerts, and a community\nof riders — all in one place.',
                  showStats: true,
                ),
              ],
            ),

            // UI Controls
            _buildUIControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildUIControls() {
    return Stack(
      children: [
        Positioned(
          top: 12,
          right: 20,
          child: GestureDetector(
            onTap: _goToWelcome,
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _totalPages,
                  effect: const WormEffect(
                    dotColor: Color(0xFFE0E0E0),
                    activeDotColor: Colors.black,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showStats;
  final bool isFeaturePage;
  final String? imagePath;
  final double imageScale;
  final Offset imageOffset;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    this.showStats = false,
    this.isFeaturePage = false,
    this.imagePath,
    this.imageScale = 1.0,
    this.imageOffset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.6),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isFeaturePage) ...[
            const SizedBox(height: 30),
            _buildFeature(Icons.verified_user_rounded, 'Verify Bike Legality'),
            _buildFeature(Icons.local_police_rounded, 'Police Verification'),
            _buildFeature(Icons.notification_important_rounded, 'Instant SOS Help'),
          ],
          
          const Spacer(),
          
          if (imagePath != null)
            Center(
              child: Transform.translate(
                offset: imageOffset,
                child: Transform.scale(
                  scale: imageScale,
                  child: Image.asset(
                    imagePath!,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 320), // Match bike2 height

          const Spacer(),
          
          if (showStats) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatItem(value: '50K+', label: 'Riders'),
                _StatItem(value: '99%', label: 'Accuracy'),
                _StatItem(value: '24/7', label: 'Support'),
              ],
            ),
            const SizedBox(height: 140),
          ] else ...[
            const SizedBox(height: 100),
          ],
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
