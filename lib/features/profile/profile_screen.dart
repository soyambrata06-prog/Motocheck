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

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? theme.scaffoldBackgroundColor : const Color(0xFFF8F9FA),
      body: RepaintBoundary(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 80),
                
                // Profile & QR Card with Dual Overlapping Elements
                RepaintBoundary(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withOpacity(0.05),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(22, 90, 22, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProvider.displayName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildLightInfoRow(
                                context, Icons.phone_outlined, userProvider.phoneNumber, iconColor: const Color(0xFF448AFF)),
                            _buildLightInfoRow(
                                context, Icons.email_outlined, userProvider.email, iconColor: const Color(0xFFFFAB40)),
                            _buildLightInfoRow(context, Icons.location_on_outlined,
                                userProvider.location, iconColor: const Color(0xFFFF5252)),
                            _buildLightInfoRow(
                                context, Icons.verified_user_outlined, 'KYC Verified', isVerified: true, iconColor: const Color(0xFF00C853)),
                          ],
                        ),
                      ),
                      // DP floating out (Left)
                      Positioned(
                        top: -55,
                        left: 22,
                        child: Stack(
                          children: [
                            Container(
                              width: 130,
                              height: 130,
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
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                color: theme.colorScheme.onSurface,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                                    );
                                  },
                                  splashColor: theme.colorScheme.surface.withOpacity(0.1),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1), width: 1.5),
                                    ),
                                    child: Icon(Icons.edit, color: theme.colorScheme.surface, size: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // QR Code floating out (Right)
                      Positioned(
                        top: -55,
                        right: 22,
                        child: Container(
                          width: 130,
                          height: 130,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(30),
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=OR01-202300456789&color=000000',
                              fit: BoxFit.contain,
                              color: theme.colorScheme.onSurface,
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                
                // Settings List
                Material(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        context,
                        Icons.notifications_none_rounded, 
                        'Notifications', 
                        iconColor: const Color(0xFF7C4DFF), // Purple
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
                        iconColor: const Color(0xFF00C853), // Green
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
                        iconColor: const Color(0xFF448AFF), // Blue
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
                        isLast: true,
                        iconColor: const Color(0xFFFFAB40), // Orange
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AboutScreen()),
                          );
                        },
                      ),
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
    ));
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

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, {VoidCallback? onTap, bool isLast = false, required Color iconColor}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          onTap: onTap,
          splashColor: theme.colorScheme.onSurface.withOpacity(0.08),
          hoverColor: theme.colorScheme.onSurface.withOpacity(0.04),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 1, color: theme.colorScheme.onSurface.withOpacity(0.05), indent: 60),
      ],
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final isDarkMode = themeProvider.isDarkMode;
    final Color iconColor = isDarkMode ? const Color(0xFFFFD740) : const Color(0xFFFFAB40);
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          onTap: () => themeProvider.toggleTheme(!isDarkMode),
          splashColor: theme.colorScheme.onSurface.withOpacity(0.08),
          hoverColor: theme.colorScheme.onSurface.withOpacity(0.04),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Icon(
                isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_outlined,
                key: ValueKey(isDarkMode ? 'dark_icon' : 'light_icon'),
                color: iconColor,
                size: 22,
              ),
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
