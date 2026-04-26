import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/providers/user_provider.dart';
import '../../data/models/sound_test_model.dart';
import '../../screens/welcome_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'help_support_screen.dart';
import 'privacy_screen.dart';
import 'about_screen.dart';
import 'widgets/saved_bikes.dart';
import '../sound/sound_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  List<SoundTestModel> _soundHistory = [];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadSoundHistory();
  }

  Future<void> _loadSoundHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyStrings = prefs.getStringList('sound_test_history') ?? [];
    setState(() {
      _soundHistory = historyStrings
          .map((item) => SoundTestModel.fromJson(jsonDecode(item)))
          .toList()
          .reversed
          .toList();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

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
              Navigator.pop(context);
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: RepaintBoundary(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                          ],
                        ),
                        const SizedBox(height: 30),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userProvider.displayName,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildPremiumInfoRow(Icons.mail_outline_rounded, userProvider.email, isDark),
                                    _buildPremiumInfoRow(Icons.phone_outlined, userProvider.phoneNumber, isDark),
                                    _buildPremiumInfoRow(Icons.cake_outlined, userProvider.dob, isDark),
                                    _buildPremiumInfoRow(Icons.location_on_outlined, userProvider.location, isDark),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00C853).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'VERIFIED RIDER',
                                        style: TextStyle(
                                          color: Color(0xFF00C853),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF00C853).withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                                  backgroundImage: NetworkImage(userProvider.profileImageUrl),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 35),
                        const SavedBikes(),
                        
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

                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildPremiumTile(Icons.person_outline_rounded, 'Edit Profile', isDark, () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                              }),
                              _buildPremiumTile(Icons.notifications_none_rounded, 'Notifications', isDark, () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()));
                              }),
                              _buildPremiumTile(Icons.history_rounded, 'Sound Check History', isDark, () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SoundHistoryScreen()));
                              }),
                              _buildPremiumThemeTile(themeProvider, isDark),
                              _buildPremiumTile(Icons.headset_mic_outlined, 'Help & Support', isDark, () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
                              }),
                              _buildPremiumTile(Icons.verified_user_outlined, 'Privacy', isDark, () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyScreen()));
                              }),
                              _buildPremiumTile(Icons.info_outline_rounded, 'About', isDark, () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                              }),
                              _buildPremiumTile(Icons.logout_rounded, 'Log Out', isDark, () => _onSignOut(context), isDestructive: true, isLast: true),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 35),
                        if (_soundHistory.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Sound Tests',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SoundHistoryScreen()),
                                  );
                                },
                                child: Text('View All', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _soundHistory.take(5).length,
                              itemBuilder: (context, index) {
                                final test = _soundHistory[index];
                                return Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: test.isPass ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            test.isPass ? Icons.check_circle_outline : Icons.error_outline,
                                            size: 16,
                                            color: test.isPass ? Colors.green : Colors.red,
                                          ),
                                          Text(
                                            '${test.peakDb.toInt()} dB',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: isDark ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            test.bikeName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? Colors.white70 : Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            test.timestamp.toString().split(' ')[0],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isDark ? Colors.white38 : Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedThemeToggle(ThemeProvider themeProvider, bool isDark) {
    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(!isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutBack,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white : Colors.black,
                        boxShadow: isDark 
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.4 * _glowController.value + 0.2),
                                blurRadius: 8 + (4 * _glowController.value),
                                spreadRadius: 1 + (2 * _glowController.value),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                      ),
                      child: child,
                    );
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) => RotationTransition(
                      turns: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: Icon(
                      isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                      key: ValueKey(isDark),
                      size: 13,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumThemeTile(ThemeProvider themeProvider, bool isDark) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
            size: 22,
          ),
          title: Text(
            'App Theme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          trailing: _buildAnimatedThemeToggle(themeProvider, isDark),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        ),
        Divider(
          height: 1,
          thickness: 1,
          indent: 70,
          endIndent: 24,
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ],
    );
  }

  Widget _buildPremiumInfoRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white38 : Colors.black38),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTile(IconData icon, String title, bool isDark, VoidCallback onTap, {bool isDestructive = false, bool isLast = false}) {
    final color = isDestructive ? Colors.redAccent : (isDark ? Colors.white : Colors.black);
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: color.withOpacity(isDestructive ? 1 : 0.4), size: 22),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withOpacity(0.2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 70,
            endIndent: 24,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
      ],
    );
  }

}

