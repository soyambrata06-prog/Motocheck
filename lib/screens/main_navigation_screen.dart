import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/providers/navigation_provider.dart';
import '../features/home/home_screen.dart';
import '../features/check/check_screen.dart';
import '../features/sos/sos_screen.dart';
import '../features/profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late PageController _pageController;
  late NavigationProvider _navProvider;

  @override
  void initState() {
    super.initState();
    _navProvider = Provider.of<NavigationProvider>(context, listen: false);
    _pageController = PageController(initialPage: _navProvider.selectedIndex);
    _navProvider.addListener(_onProviderIndexChange);
  }

  void _onProviderIndexChange() {
    if (_pageController.hasClients) {
      final providerIndex = _navProvider.selectedIndex;
      final currentPage = _pageController.page?.round() ?? _pageController.initialPage;
      
      if (providerIndex != currentPage) {
        _pageController.animateToPage(
          providerIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _navProvider.removeListener(_onProviderIndexChange);
    _pageController.dispose();
    super.dispose();
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    CheckScreen(),
    SosScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    if (navProvider.selectedIndex != index) {
      HapticFeedback.lightImpact();
      navProvider.setIndex(index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    Provider.of<NavigationProvider>(context, listen: false).setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Floating NavBar dimensions
    const double horizontalPadding = 20;
    final double navBarWidth = screenWidth - (horizontalPadding * 2);
    final double itemWidth = navBarWidth / 4;

    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          backgroundColor: isDark ? Colors.black : theme.scaffoldBackgroundColor,
          extendBody: true, // Allows body to go behind the floating nav bar
          body: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false), // Removes the grey glow
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemCount: _screens.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0.0;
                    if (_pageController.hasClients && _pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                    } else {
                      value = (navProvider.selectedIndex - index).toDouble();
                    }

                    // Normalizing value between -1.0 and 1.0
                    double offset = value.clamp(-1.0, 1.0);
                    
                    // Fade effect: sharpening the curve for a more professional feel
                    double opacity = (1 - offset.abs() * 1.5).clamp(0.0, 1.0);
                    
                    // Scale effect: subtle shrinking to give depth
                    double scale = 1.0 - (offset.abs() * 0.05);
                    
                    // Vertical shift logic: 
                    double yOffset = offset.abs() * 80; 

                    // Counteract PageView's horizontal sliding
                    double xOffset = value * MediaQuery.of(context).size.width;

                    return Transform.translate(
                      offset: Offset(xOffset, yOffset),
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: _screens[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: 24, // Margin from bottom of screen
            ),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1E1E1E) : Colors.white).withOpacity(0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Stack(
                    children: [
                      // Sliding Background (Capsule) - Now following the PageController linearly
                      AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double page = 0;
                          if (_pageController.hasClients && _pageController.position.haveDimensions) {
                            page = _pageController.page!;
                          } else {
                            page = navProvider.selectedIndex.toDouble();
                          }
                          
                          return Positioned(
                            left: page * itemWidth + 6,
                            top: 8,
                            bottom: 8,
                            width: itemWidth - 12,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white : Colors.black,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Navigation Items
                      Row(
                        children: List.generate(4, (index) {
                          IconData icon;
                          String label;
                          switch (index) {
                            case 0: icon = Icons.grid_view_rounded; label = 'HOME'; break; // Changed to more modern icon
                            case 1: icon = Icons.search_rounded; label = 'SEARCH'; break;
                            case 2: icon = Icons.security_rounded; label = 'SECURE'; break;
                            case 3: icon = Icons.person_rounded; label = 'ME'; break;
                            default: icon = Icons.home_rounded; label = '';
                          }
                          return _buildNavItem(index, icon, label, theme, itemWidth, navProvider);
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, ThemeData theme, double itemWidth, NavigationProvider navProvider) {
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double page = 0;
            if (_pageController.hasClients && _pageController.position.haveDimensions) {
              page = _pageController.page!;
            } else {
              page = navProvider.selectedIndex.toDouble();
            }

            // Calculate how "active" this specific tab is (1.0 = fully active, 0.0 = inactive)
            double distance = (page - index).abs();
            
            // To make text show only after capsule reaches/is very close
            // we use a steeper curve or a threshold.
            // Using a threshold or a power function to delay the text appearance
            double activePercent = (1 - distance).clamp(0.0, 1.0);
            
            // Delayed text appearance: only starts showing when capsule is 80% there
            double textOpacity = (activePercent > 0.8) ? (activePercent - 0.8) / 0.2 : 0.0;
            double textWidthFactor = (activePercent > 0.7) ? (activePercent - 0.7) / 0.3 : 0.0;
            
            // Icon color interpolation
            Color iconColor = Color.lerp(
              isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4),
              isDark ? Colors.black : Colors.white,
              activePercent,
            )!;

            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                  // Animated Text (Reveal and Fade)
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: textWidthFactor,
                      child: Opacity(
                        opacity: textOpacity,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              color: isDark ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
