import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme_provider.dart';
import '../../screens/welcome_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;

  void _onSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        content: const Text(
          'Are you sure you want to log out from MotoCheck?',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: Color(0xFFE03131), fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 25),
                
                // Profile & QR Card (High-Fidelity Cyber-Emerald)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      // Atmospheric Outer Glow
                      BoxShadow(
                        color: const Color(0xFF20C997).withOpacity(isDark ? 0.18 : 0.08),
                        blurRadius: 35,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        // High-Fidelity Gradient (Brighter Midnight Emerald)
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark 
                            ? [const Color(0xFF162420), const Color(0xFF0D1512), const Color(0xFF1A2B26)]
                            : [Colors.white, const Color(0xFFFAFAFA), Colors.white],
                        ),
                        border: Border.all(
                          color: const Color(0xFF20C997).withOpacity(isDark ? 0.35 : 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Subtle internal light flare
                          if (isDark)
                            Positioned(
                              top: -60,
                              right: -60,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF20C997).withOpacity(0.04),
                                ),
                              ),
                            ),
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                // Left Side: Profile Info
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isDark ? const Color(0xFF20C997).withOpacity(0.2) : Colors.black.withOpacity(0.05),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.person_rounded,
                                              color: isDark ? const Color(0xFF20C997).withOpacity(0.4) : Colors.black26,
                                              size: 40,
                                            ),
                                          ),
                                          Positioned(
                                            top: -2,
                                            right: -2,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: isDark ? const Color(0xFF162420) : Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: const Color(0xFF20C997), width: 1.5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xFF20C997).withOpacity(0.2),
                                                      blurRadius: 8,
                                                    )
                                                  ],
                                                ),
                                                child: const Icon(Icons.edit, color: Color(0xFF20C997), size: 14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Soyambrata Nayak',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white : Colors.black,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      _buildLightInfoRow(Icons.phone_outlined, '+91 98765 43210', isDark),
                                      _buildLightInfoRow(Icons.email_outlined, 'soyamb@example.com', isDark),
                                      _buildLightInfoRow(Icons.location_on_outlined, 'Bhubaneswar, Odisha', isDark),
                                    ],
                                  ),
                                ),
                                
                                // Clean Vertical Divider
                                Container(
                                  width: 1.5,
                                  margin: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(0xFF20C997).withOpacity(0),
                                        const Color(0xFF20C997).withOpacity(isDark ? 0.3 : 0.1),
                                        const Color(0xFF20C997).withOpacity(0),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Right Side: QR Code
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF20C997).withOpacity(0.15),
                                              blurRadius: 15,
                                            )
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=OR01-202300456789&color=000000',
                                            height: 95,
                                            width: 95,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'DL: OR01 20230045678',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Driving Licence',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? const Color(0xFF20C997).withOpacity(0.7) : Colors.black45,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF20C997).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF20C997).withOpacity(0.4),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.verified_user_rounded, color: Color(0xFF20C997), size: 14),
                                            SizedBox(width: 6),
                                            Text(
                                              'VERIFIED',
                                              style: TextStyle(
                                                color: Color(0xFF20C997),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                
                // Settings List
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(Icons.notifications_none_rounded, 'Notifications', isDark),
                      _buildThemeTile(themeProvider),
                      _buildSettingsTile(Icons.headset_mic_outlined, 'Help & Support', isDark),
                      _buildSettingsTile(Icons.verified_user_outlined, 'Privacy', isDark),
                      _buildSettingsTile(Icons.info_outline_rounded, 'About', isDark, isLast: true),
                    ],
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => _onSignOut(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE03131), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout_rounded, color: Color(0xFFE03131)),
                        SizedBox(width: 10),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            color: Color(0xFFE03131),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Padding for nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLightInfoRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white38 : Colors.black38),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF20C997).withOpacity(0.7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, bool isDark, {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(icon, color: isDark ? Colors.white : Colors.black, size: 26),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? Colors.white54 : Colors.black),
          onTap: () {},
        ),
        if (!isLast)
          Divider(height: 1, thickness: 1, color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50], indent: 60),
      ],
    );
  }

  Widget _buildThemeTile(ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
              );
            },
            child: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_outlined,
              key: ValueKey(isDarkMode ? 'dark_icon' : 'light_icon'),
              color: isDarkMode ? Colors.white : Colors.black,
              size: 26,
            ),
          ),
          title: Text(
            'App Theme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          trailing: GestureDetector(
            onTap: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 80,
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDarkMode ? const Color(0xFF1A1B1E) : Colors.black.withOpacity(0.08),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : Colors.black12,
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Background Sun
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 7),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 400),
                        scale: isDarkMode ? 0.7 : 1.0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: isDarkMode ? 0.4 : 1.0,
                          child: Icon(
                            Icons.wb_sunny_rounded,
                            size: 16,
                            color: isDarkMode ? Colors.white24 : Colors.black45,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Background Moon
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 400),
                        scale: isDarkMode ? 1.0 : 0.7,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: isDarkMode ? 1.0 : 0.2,
                          child: Icon(
                            Icons.nightlight_round,
                            size: 16,
                            color: isDarkMode ? Colors.white : Colors.black26,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Sliding Glowing Indicator
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode ? Colors.white : Colors.black,
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, anim) {
                            return RotationTransition(
                              turns: anim,
                              child: ScaleTransition(scale: anim, child: child),
                            );
                          },
                          child: Icon(
                            isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                            key: ValueKey(isDarkMode),
                            size: 16,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(height: 1, thickness: 1, color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[50], indent: 60),
      ],
    );
  }

  Widget _buildThemeOption(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          if (isActive) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}
