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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double navBarWidth = screenWidth - 32;
    final double itemWidth = navBarWidth / 4;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // This allows the body to draw behind the nav bar
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent, // Explicitly transparent
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
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
                    color: Colors.white,
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
                  return _buildNavItem(index, icon, label);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;

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
                      Icon(icon, color: Colors.black, size: 22),
                      const SizedBox(width: 2),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : Icon(
                    icon,
                    key: ValueKey('unsel_$index'),
                    color: Colors.white.withOpacity(0.6),
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }
}
