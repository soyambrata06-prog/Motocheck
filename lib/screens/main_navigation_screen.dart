import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    CheckScreen(),
    SosScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedIndex = index;
      });
    }
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true, // Allows body to go behind the floating nav bar
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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
                  // Sliding Background (Capsule)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack, // Added a slight bounce effect
                    left: _selectedIndex * itemWidth + 6,
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
                  ),
                  // Navigation Items
                  Row(
                    children: List.generate(4, (index) {
                      IconData icon;
                      String label;
                      switch (index) {
                        case 0: icon = Icons.grid_view_rounded; label = 'HOME'; break; // Changed to more modern icon
                        case 1: icon = Icons.search_rounded; label = 'CHECK'; break;
                        case 2: icon = Icons.notifications_active_rounded; label = 'SOS'; break; // Changed icon
                        case 3: icon = Icons.person_rounded; label = 'ME'; break;
                        default: icon = Icons.home_rounded; label = '';
                      }
                      return _buildNavItem(index, icon, label, theme);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, ThemeData theme) {
    bool isSelected = _selectedIndex == index;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected 
                      ? (isDark ? Colors.black : Colors.white) 
                      : (isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4)),
                  size: isSelected ? 24 : 26, // Subtle scale effect
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
