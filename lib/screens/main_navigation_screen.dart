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
  
  int? _tapTarget;
  int? _tapSource;

  @override
  void initState() {
    super.initState();
    _navProvider = Provider.of<NavigationProvider>(context, listen: false);
    _pageController = PageController(initialPage: _navProvider.selectedIndex);
    _navProvider.addListener(_onProviderIndexChange);
  }

  void _onProviderIndexChange() {
    if (_pageController.hasClients) {
      final targetIndex = _navProvider.selectedIndex;
      final currentIndex = _pageController.page?.round() ?? _pageController.initialPage;
      
      if (targetIndex != currentIndex && _tapTarget != targetIndex) {
        _handleTabTransition(targetIndex);
      }
    }
  }

  Future<void> _handleTabTransition(int index) async {
    final int source = _pageController.page?.round() ?? _navProvider.selectedIndex;
    
    setState(() {
      _tapSource = source;
      _tapTarget = index;
    });

    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );

    if (mounted) {
      setState(() {
        _tapSource = null;
        _tapTarget = null;
      });
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
    if (_navProvider.selectedIndex != index) {
      HapticFeedback.lightImpact();
      _navProvider.setIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    const double horizontalPadding = 20;
    final double navBarWidth = screenWidth - (horizontalPadding * 2);
    final double itemWidth = navBarWidth / 4;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      extendBody: true,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          if (_tapTarget == null) {
            Provider.of<NavigationProvider>(context, listen: false).setIndex(index);
          }
        },
        physics: const BouncingScrollPhysics(),
        itemCount: _screens.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              final double page = _pageController.hasClients 
                  ? (_pageController.page ?? _navProvider.selectedIndex.toDouble())
                  : _navProvider.selectedIndex.toDouble();
              
              final double xOffset = (page - index) * screenWidth;
              
              double animValue = 0.0;
              
              if (_tapTarget != null && _tapSource != null) {
                if (index != _tapTarget && index != _tapSource) {
                  return const SizedBox.shrink();
                }
                
                final double totalDelta = (_tapTarget! - _tapSource!).toDouble();
                final double progress = ((page - _tapSource!) / totalDelta).clamp(0.0, 1.0);
                
                animValue = (index == _tapSource) ? progress : (1.0 - progress);
              } else {
                animValue = (page - index).abs();
              }

              if (animValue >= 1.0) return const SizedBox.shrink();

              double opacity = (1.0 - animValue).clamp(0.0, 1.0);
              opacity = Curves.easeInQuint.transform(opacity);
              
              final double yOffset = animValue * 80;
              
              final double scale = 1.0 - (animValue * 0.03);

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
      bottomNavigationBar: _buildBottomNavBar(isDark, theme, horizontalPadding, itemWidth),
    );
  }

  Widget _buildBottomNavBar(bool isDark, ThemeData theme, double horizontalPadding, double itemWidth) {
    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 24,
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
                AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    final double page = _pageController.hasClients 
                        ? (_pageController.page ?? _navProvider.selectedIndex.toDouble())
                        : _navProvider.selectedIndex.toDouble();
                    
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
                Row(
                  children: List.generate(4, (index) {
                    IconData icon;
                    String label;
                    switch (index) {
                      case 0: icon = Icons.grid_view_rounded; label = 'HOME'; break;
                      case 1: icon = Icons.search_rounded; label = 'SEARCH'; break;
                      case 2: icon = Icons.security_rounded; label = 'SECURE'; break;
                      case 3: icon = Icons.person_rounded; label = 'ME'; break;
                      default: icon = Icons.home_rounded; label = '';
                    }
                    return _buildNavItem(index, icon, label, theme, itemWidth);
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, ThemeData theme, double itemWidth) {
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            final double page = _pageController.hasClients 
                ? (_pageController.page ?? _navProvider.selectedIndex.toDouble())
                : _navProvider.selectedIndex.toDouble();

            double distance = (page - index).abs();
            double activePercent = (1 - distance).clamp(0.0, 1.0);
            
            double textOpacity = (activePercent > 0.8) ? (activePercent - 0.8) / 0.2 : 0.0;
            double textWidthFactor = (activePercent > 0.7) ? (activePercent - 0.7) / 0.3 : 0.0;
            
            Color iconColor = Color.lerp(
              isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4),
              isDark ? Colors.black : Colors.white,
              activePercent,
            )!;

            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: iconColor, size: 24),
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

