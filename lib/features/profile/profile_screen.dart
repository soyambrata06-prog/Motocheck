import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/providers/user_provider.dart';
import '../../screens/welcome_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'help_support_screen.dart';
import 'privacy_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;

  void _onSignOut(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        surfaceTintColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to log out from MotoCheck?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (route) => false,
                );
              }
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
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      body: RepaintBoundary(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Header
              Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PROFILE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              
              // Profile Card with Enhanced Frosted Glass UI
              RepaintBoundary(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : theme.colorScheme.primary.withOpacity(0.1)),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.0,
                            colors: [
                              (isDark ? Colors.white : theme.colorScheme.surface).withOpacity(isDark ? 0.08 : 0.2),
                              (isDark ? Colors.white : theme.colorScheme.surface).withOpacity(isDark ? 0.02 : 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.15),
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Details Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 5), // Align with DP
                                  Text(
                                    userProvider.displayName,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: theme.colorScheme.onSurface,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildLightInfoRow(
                                      context, Icons.phone_outlined, userProvider.phoneNumber, iconColor: isDark ? Colors.white : Colors.grey),
                                  _buildLightInfoRow(
                                      context, Icons.email_outlined, userProvider.email, iconColor: isDark ? Colors.white : Colors.grey),
                                  _buildLightInfoRow(
                                      context, Icons.calendar_today_outlined, userProvider.dob, iconColor: isDark ? Colors.white : Colors.grey),
                                  _buildLightInfoRow(context, Icons.location_on_outlined,
                                      userProvider.location, iconColor: isDark ? Colors.white : Colors.grey),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // DP Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    image: DecorationImage(
                                      image: NetworkImage(userProvider.profileImageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(
                                      color: theme.scaffoldBackgroundColor,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00C853).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF00C853)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                          color: Color(0xFF00C853),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 35),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 15),
              
              // Settings List with Enhanced Frosted Glass UI
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.1,
                          colors: [
                            (isDark ? Colors.white : theme.colorScheme.surface).withOpacity(isDark ? 0.08 : 0.2),
                            (isDark ? Colors.white : theme.colorScheme.surface).withOpacity(isDark ? 0.02 : 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.12),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            context,
                            Icons.person_outline_rounded, 
                            'Edit Profile', 
                            iconColor: isDark ? Colors.white : Colors.grey,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            context,
                            Icons.notifications_none_rounded, 
                            'Notifications', 
                            iconColor: isDark ? Colors.white : Colors.grey,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
                              );
                            },
                          ),
                          _buildThemeTile(context, themeProvider),
                          _buildSettingsTile(
                            context,
                            Icons.headset_mic_outlined, 
                            'Help & Support', 
                            iconColor: isDark ? Colors.white : Colors.grey,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            context,
                            Icons.verified_user_outlined, 
                            'Privacy', 
                            iconColor: isDark ? Colors.white : Colors.grey,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PrivacyScreen()),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            context,
                            Icons.info_outline_rounded, 
                            'About', 
                            iconColor: isDark ? Colors.white : Colors.grey,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AboutScreen()),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            context,
                            Icons.logout_rounded, 
                            'Log Out', 
                            isLast: true,
                            iconColor: const Color(0xFFE03131),
                            textColor: const Color(0xFFE03131),
                            onTap: () => _onSignOut(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
                
                const SizedBox(height: 140), // Extra space for floating nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLightInfoRow(BuildContext context, IconData icon, String text, {bool isVerified = false, required Color iconColor}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isVerified ? iconColor : theme.colorScheme.onSurface.withOpacity(0.54),
                fontWeight: isVerified ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, {VoidCallback? onTap, bool isLast = false, required Color iconColor, Color? textColor}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(icon, color: iconColor, size: 22),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor ?? theme.colorScheme.onSurface,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          onTap: onTap,
          splashColor: (textColor ?? theme.colorScheme.onSurface).withOpacity(0.08),
          hoverColor: (textColor ?? theme.colorScheme.onSurface).withOpacity(0.04),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 1, color: theme.colorScheme.onSurface.withOpacity(0.05), indent: 60),
      ],
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final isDarkMode = themeProvider.isDarkMode;
    final Color iconColor = isDarkMode ? Colors.white : Colors.grey;
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          onTap: () => themeProvider.toggleTheme(!isDarkMode),
          splashColor: theme.colorScheme.onSurface.withOpacity(0.08),
          hoverColor: theme.colorScheme.onSurface.withOpacity(0.04),
          leading: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_outlined,
              key: ValueKey(isDarkMode ? 'dark_icon' : 'light_icon'),
              color: iconColor,
              size: 22,
            ),
          ),
          title: Text(
            'App Theme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          trailing: GestureDetector(
            onTap: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              width: 80,
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDarkMode ? const Color(0xFF1A1B1E) : theme.colorScheme.onSurface.withOpacity(0.08),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
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
                        duration: const Duration(milliseconds: 300),
                        scale: isDarkMode ? 0.7 : 1.0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
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
                        duration: const Duration(milliseconds: 300),
                        scale: isDarkMode ? 1.0 : 0.7,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
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
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.onSurface,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) {
                            return FadeTransition(
                              opacity: anim,
                              child: ScaleTransition(scale: anim, child: child),
                            );
                          },
                          child: Icon(
                            isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                            key: ValueKey(isDarkMode),
                            size: 16,
                            color: theme.colorScheme.surface,
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
        Divider(height: 1, thickness: 1, color: theme.colorScheme.onSurface.withOpacity(0.05), indent: 60),
      ],
    );
  }

  // Removed unused _buildThemeOption
}
