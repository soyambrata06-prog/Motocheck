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
            // Background Sliding Image for Page 2 and 3
            AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double scrollOffset = 0.0;
                if (_pageController.hasClients) {
                  scrollOffset = _pageController.page ?? 0.0;
                }

                // We only show the sliding bike when between page 1 (index 1) and page 2 (index 2)
                // If on page 0, it should be hidden or at starting pos.
                // Page 2 (index 1): 20-30% from right -> Offset(0.7, 0)
                // Page 3 (index 2): 70-80% from left -> Offset(-0.7, 0)
                
                double opacity = 0.0;
                double translationX = 0.0;

                if (scrollOffset > 0.5) {
                  // Fade in between page 1 and 2
                  opacity = (scrollOffset - 0.5).clamp(0.0, 1.0);
                  
                  // Map scrollOffset [1.0 -> 2.0] to translationX [0.7 -> -0.7] (relative to center)
                  // When page is 1.0, translation is 0.7 (bike pushed right)
                  // When page is 2.0, translation is -0.7 (bike pushed left)
                  double t = (scrollOffset - 1.0); // 0.0 to 1.0
                  translationX = 0.7 - (t * 1.4); 
                }

                return Positioned.fill(
                  child: Opacity(
                    opacity: opacity,
                    child: FractionalTranslation(
                      translation: Offset(translationX, -0.02),
                      child: Transform.scale(
                        scale: 1.7, // Decreased size as requested
                        filterQuality: FilterQuality.high, // Improve rendering quality
                        child: Image.asset(
                          'assets/images/bike2.png',
                          fit: BoxFit.contain,
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
              children: [
                const _OnboardingPage(
                  title: 'Know your bike.\nRide legal',
                  subtitle: "Easily check your bike's legality\nand ride safe.",
                  imagePath: 'assets/images/bike.png',
                  imageAlignment: Alignment.center,
                  imageScale: 1.8,
                  showImage: true,
                ),
                _OnboardingPage(
                  title: 'Check legality,\navoid fines, stay safe.',
                  subtitle: 'Scan your bike and check its legal status instantly.',
                  imagePath: '',
                  imageAlignment: Alignment.center,
                  isFeaturePage: true,
                  showImage: false,
                ),
                const _OnboardingPage(
                  title: 'Stay connected,\nride with confidence.',
                  subtitle: 'Real-time updates, alerts, and a community\nof riders — all in one place.',
                  imagePath: '',
                  imageAlignment: Alignment.center,
                  showStats: true,
                  showImage: false,
                ),
              ],
            ),

            // Skip button (top-right)
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

            // Bottom controls (Dots + Button)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white,
                    ],
                    stops: const [0.0, 0.3],
                  ),
                ),
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
                    const SizedBox(height: 12),
                    // Home Indicator
                    Container(
                      width: 120,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Alignment imageAlignment;
  final double imageScale;
  final bool showStats;
  final bool isFeaturePage;
  final bool showImage;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.imageAlignment,
    this.imageScale = 1.0,
    this.showStats = false,
    this.isFeaturePage = false,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The Background Image (Zoomed) - Only if showImage is true (Page 1)
        if (showImage)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 100, bottom: 100),
              child: Align(
                alignment: imageAlignment,
                child: Transform.scale(
                  scale: imageScale,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.motorcycle, size: 200, color: Colors.black12),
                  ),
                ),
              ),
            ),
          ),

        // Text Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
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
                const SizedBox(height: 40),
                _smallFeature(Icons.verified_user_rounded, 'Verify Bike Legality'),
                const SizedBox(height: 12),
                _smallFeature(Icons.local_police_rounded, 'Police Verification'),
                const SizedBox(height: 12),
                _smallFeature(Icons.sos_rounded, 'Instant SOS Help'),
              ],
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
                const SizedBox(height: 160), // Space for bottom controls
              ] else ...[
                const SizedBox(height: 120),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _smallFeature(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
