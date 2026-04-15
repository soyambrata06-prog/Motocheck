import 'package:flutter/material.dart';
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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double navBarWidth = screenWidth - 32;
    final double itemWidth = navBarWidth / 4;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true, // This allows the body to draw behind the nav bar
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent, 
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), // Increased bottom padding
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.black,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Sliding Background
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _selectedIndex * itemWidth + 4,
                top: 4,
                bottom: 4,
                width: itemWidth - 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
              // Navigation Items
              Row(
                children: List.generate(4, (index) {
                  IconData icon;
                  String label;
                  switch (index) {
                    case 0: icon = Icons.home_rounded; label = 'Home'; break;
                    case 1: icon = Icons.search_rounded; label = 'Search'; break;
                    case 2: icon = Icons.notification_important_rounded; label = 'SOS'; break;
                    case 3: icon = Icons.person_rounded; label = 'Profile'; break;
                    default: icon = Icons.home_rounded; label = '';
                  }
                  return _buildNavItem(index, icon, label, theme);
                }),
              ),
            ],
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: isSelected
                ? Row(
                    key: ValueKey('sel_$index'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: theme.colorScheme.onSurface, size: 22),
                      const SizedBox(width: 2),
                      Text(
                        label,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : Icon(
                    icon,
                    key: ValueKey('unsel_$index'),
                    color: isDark ? Colors.white38 : Colors.white.withOpacity(0.6),
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }
}
