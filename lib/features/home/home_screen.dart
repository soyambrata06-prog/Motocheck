import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/providers/navigation_provider.dart';
import '../sound/sound_measure_screen.dart';
import '../../core/providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);
    final secondaryColor = isDark ? Colors.white38 : Colors.black38;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            
            // Custom Top App Bar (Secure/Database Style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildTopAppBar(userProvider, isDark),
            ),
            
            const SizedBox(height: 35),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1 & 2. Unified Smart Dashboard
                  _buildSectionHeader('SMART DASHBOARD', isDark),
                  _buildUnifiedDashboard(isDark, secondaryColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildHeroButton('View Full Details', isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildHeroButton('Maintenance Logs', isDark)),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 3. Quick Actions
                  _buildSectionHeader('QUICK ACTIONS', isDark),
                  const SizedBox(height: 12),
                  _buildQuickAction(
                    context, 
                    'Police Mode', 
                    'Verify bike legality instantly', 
                    Icons.policy_rounded, 
                    const Color(0xFF2196F3), 
                    isDark,
                    onTap: () {
                      // Navigate to Police Mode
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildQuickAction(
                    context, 
                    'SOS Emergency', 
                    'Send alert + live location', 
                    Icons.emergency_share_rounded, 
                    const Color(0xFFFF5252), 
                    isDark,
                    onTap: () {
                      Provider.of<NavigationProvider>(context, listen: false).setIndex(2);
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildQuickAction(
                    context, 
                    'Sound Check', 
                    'Measure exhaust dB level', 
                    Icons.graphic_eq_rounded, 
                    const Color(0xFFFF9100), 
                    isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SoundMeasureScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // 4. Ride Stats
                  _buildSectionHeader('RIDE INSIGHTS', isDark),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      children: [
                        _buildStatCard('Distance', '124.8 km', Icons.route_rounded, isDark),
                        _buildStatCard('Avg Speed', '42 km/h', Icons.speed_rounded, isDark),
                        _buildStatCard('Ride Time', '3h 20m', Icons.timer_rounded, isDark),
                        _buildStatCard('Top Speed', '87 km/h', Icons.bolt_rounded, isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 5. Alerts & Warnings
                  _buildSectionHeader('ALERTS & WARNINGS', isDark),
                  const SizedBox(height: 12),
                  _buildAlertTile('Service due in 8 days', Colors.orange, isDark),
                  const SizedBox(height: 8),
                  _buildAlertTile('Insurance expires on 28 April', Colors.orange, isDark),
                  const SizedBox(height: 8),
                  _buildAlertTile('Exhaust sound slightly above normal', Colors.red, isDark),

                  const SizedBox(height: 25),

                  // 6. Smart Insights
                  _buildSectionHeader('SMART INSIGHTS', isDark),
                  const SizedBox(height: 12),
                  _buildInsightCard('Legal dB Range: 90–95 dB', Icons.gavel_rounded, isDark),
                  const SizedBox(height: 8),
                  _buildInsightCard('Avoid high RPM before engine warms up', Icons.tips_and_updates_rounded, isDark),
                  const SizedBox(height: 8),
                  _buildInsightCard('Maintain 40–60 km/h for best mileage', Icons.eco_rounded, isDark),

                  const SizedBox(height: 25),

                  // 7. Quick Maintenance
                  _buildSectionHeader('MAINTENANCE', isDark),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMaintenanceButton('Book Service', Icons.build_rounded, isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildMaintenanceButton('Oil Guide', Icons.oil_barrel_rounded, isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildMaintenanceButton('Documents', Icons.description_rounded, isDark)),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 8. Last Ride Snapshot
                  _buildSectionHeader('LAST RIDE SNAPSHOT', isDark),
                  const SizedBox(height: 12),
                  _buildLastRideCard(isDark),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(UserProvider user, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WELCOME BACK',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: textColor.withOpacity(0.38),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.displayName.split(' ')[0].toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: textColor,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(user.profileImageUrl),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A37B),
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? Colors.black : Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnifiedDashboard(bool isDark, Color secondaryColor) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.grey[100];
    const accentColor = Color(0xFF00A37B);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SYSTEMS OPTIMAL',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hunter 350',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'Royal Enfield • 2023',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    FontAwesomeIcons.motorcycle,
                    size: 60,
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDashboardStat('FUEL', '62%', Icons.local_gas_station_rounded, Colors.orange, isDark),
                _buildDashboardStat('BATTERY', 'GOOD', Icons.battery_charging_full_rounded, Colors.green, isDark),
                _buildDashboardStat('ODOMETER', '12.4k', Icons.speed_rounded, Colors.blue, isDark),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDashboardStat(String label, String value, IconData icon, Color color, bool isDark) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color.withOpacity(0.8)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white24 : Colors.black26,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroButton(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, String subtitle, IconData icon, Color color, bool isDark, {VoidCallback? onTap}) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.grey[100];
    final border = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black45,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.grey[100];
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: isDark ? Colors.white70 : Colors.black87),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isDark ? Colors.white24 : Colors.black26,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active_rounded, size: 16, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? color.withOpacity(0.9) : color.withAlpha(200),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String text, IconData icon, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.grey[100];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white38 : Colors.black38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceButton(String label, IconData icon, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.grey[100];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.white : Colors.black),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? Colors.white70 : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildLastRideCard(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.grey[100];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '16 April',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'City → Beach Road',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                ),
                child: Text(
                  '42 mins',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRideStat('DISTANCE', '22 km', isDark),
                _buildStatDivider(isDark),
                _buildRideStat('AVG SPEED', '32 km/h', isDark),
                _buildStatDivider(isDark),
                _buildRideStat('TOP SPEED', '64 km/h', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      height: 24,
      width: 1,
      color: isDark ? Colors.white10 : Colors.black12,
    );
  }

  Widget _buildRideStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
