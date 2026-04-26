import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme_provider.dart';
import '../../core/providers/notification_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PREFERENCES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NOTIFICATIONS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 35),
              _buildSection(
                title: 'Safety Alerts',
                icon: Icons.security_rounded,
                iconColor: const Color(0xFF00C853),
                info: 'Critical alerts for your safety and emergencies.',
                isDark: isDark,
                children: [
                  _buildToggleTile(
                    'Crash Detection Alerts',
                    'Auto-detect accidents and trigger SECURE',
                    notificationProvider.getSetting('crashDetection'),
                    (v) => notificationProvider.updateSetting('crashDetection', v),
                    isDark,
                  ),
                  _buildToggleTile(
                    'Security Notifications',
                    'Notify emergency contacts with your live location',
                    notificationProvider.getSetting('sosNotifications'),
                    (v) => notificationProvider.updateSetting('sosNotifications', v),
                    isDark,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildSection(
                title: 'Legal & Compliance',
                icon: Icons.gavel_rounded,
                iconColor: isDark ? Colors.white70 : Colors.black54,
                info: 'Stay updated with traffic rules and legal limits.',
                isDark: isDark,
                children: [
                  _buildToggleTile(
                    'Illegal Modification Alerts',
                    'Detect exhaust, lights, or illegal changes',
                    notificationProvider.getSetting('illegalModAlerts'),
                    (v) => notificationProvider.updateSetting('illegalModAlerts', v),
                    isDark,
                  ),
                  _buildToggleTile(
                    'Document Reminders',
                    'Insurance, PUC, RC expiry alerts',
                    notificationProvider.getSetting('documentReminders'),
                    (v) => notificationProvider.updateSetting('documentReminders', v),
                    isDark,
                  ),
                  _buildToggleTile(
                    'Traffic Rule Updates',
                    'Get notified about new rules and fines',
                    notificationProvider.getSetting('trafficRuleUpdates'),
                    (v) => notificationProvider.updateSetting('trafficRuleUpdates', v),
                    isDark,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildSection(
                title: 'Bike Insights',
                icon: Icons.insights_rounded,
                iconColor: isDark ? Colors.white70 : Colors.black54,
                info: 'Smart tips and maintenance suggestions.',
                isDark: isDark,
                children: [
                  _buildToggleTile(
                    'Maintenance Reminders',
                    'Oil check, service alerts, chain cleaning',
                    notificationProvider.getSetting('maintenanceReminders'),
                    (v) => notificationProvider.updateSetting('maintenanceReminders', v),
                    isDark,
                  ),
                  _buildToggleTile(
                    'Performance Tips',
                    'Improve mileage and bike health',
                    notificationProvider.getSetting('performanceTips'),
                    (v) => notificationProvider.updateSetting('performanceTips', v),
                    isDark,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildSection(
                title: 'Police Mode',
                icon: Icons.local_police_rounded,
                iconColor: isDark ? Colors.white70 : Colors.black54,
                info: 'Alerts for enforcement and verification.',
                isDark: isDark,
                children: [
                  _buildToggleTile(
                    'Suspicious Modification Alerts',
                    'Flag potentially illegal bikes',
                    notificationProvider.getSetting('suspiciousModAlerts'),
                    (v) => notificationProvider.updateSetting('suspiciousModAlerts', v),
                    isDark,
                  ),
                  _buildToggleTile(
                    'Quick Verification Alerts',
                    'Notify when scan results are ready',
                    notificationProvider.getSetting('quickVerifAlerts'),
                    (v) => notificationProvider.updateSetting('quickVerifAlerts', v),
                    isDark,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildSection(
                title: 'Awareness',
                icon: Icons.lightbulb_outline_rounded,
                iconColor: isDark ? Colors.white70 : Colors.black54,
                info: 'Educational and safety awareness content.',
                isDark: isDark,
                children: [
                  _buildToggleTile(
                    'Safety Tips',
                    'Helmet, riding habits, precautions',
                    notificationProvider.getSetting('safetyTips'),
                    (v) => notificationProvider.updateSetting('safetyTips', v),
                    isDark,
                  ),
                  _buildToggleTile(
                    'General Updates',
                    'App updates and new features',
                    notificationProvider.getSetting('generalUpdates'),
                    (v) => notificationProvider.updateSetting('generalUpdates', v),
                    isDark,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );

  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String info,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          onTap: () => onChanged(!value),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00C853),
            activeTrackColor: const Color(0xFF00C853).withOpacity(0.2),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}

