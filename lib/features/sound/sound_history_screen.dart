import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/theme_provider.dart';
import '../../core/providers/sound_provider.dart';
import '../../data/models/sound_test_model.dart';
import 'sound_report_screen.dart';

class SoundHistoryScreen extends StatelessWidget {
  const SoundHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final soundProvider = Provider.of<SoundProvider>(context);
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          if (isDark)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00C853).withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          
          SafeArea(
            child: AnimationAppearance(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, isDark, primaryColor),
                          const SizedBox(height: 35),
                          _buildSectionHeader('MEASUREMENT RECORDS', isDark),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  if (soundProvider.isLoading && soundProvider.history.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (soundProvider.history.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildEmptyState(isDark, primaryColor),
                      ),
                    )
                  else
                    AnimationLimiter(
                      child: SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final test = soundProvider.history[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 400),
                                child: SlideAnimation(
                                  verticalOffset: 30.0,
                                  child: FadeInAnimation(
                                    child: _buildHistoryItem(context, isDark, primaryColor, test),
                                  ),
                                ),
                              );
                            },
                            childCount: soundProvider.history.length,
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color primaryColor) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.05)),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ARCHIVE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: primaryColor.withOpacity(0.38),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SOUND HISTORY',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.38),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, bool isDark, Color primaryColor, SoundTestModel test) {
    final statusColor = test.isPass ? const Color(0xFF00C853) : const Color(0xFFFF5252);
    final dateStr = DateFormat('MMM dd').format(test.timestamp).toUpperCase();
    final yearStr = DateFormat('yyyy').format(test.timestamp);
    final timeStr = DateFormat('hh:mm a').format(test.timestamp);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(test.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFF5252),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 32),
        ),
        onDismissed: (_) {
          Provider.of<SoundProvider>(context, listen: false).deleteTest(test.id);
        },
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SoundReportScreen(testResult: test),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: primaryColor.withOpacity(isDark ? 0.08 : 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      color: statusColor.withOpacity(0.8),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '$dateStr, $yearStr',
                                      style: TextStyle(
                                        color: primaryColor.withOpacity(0.4),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      timeStr,
                                      style: TextStyle(
                                        color: primaryColor.withOpacity(0.4),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                _buildStatusBadge(test.isPass, statusColor),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              test.bikeName.toUpperCase(),
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              test.manufacturer.toUpperCase(),
                              style: TextStyle(
                                color: primaryColor.withOpacity(0.3),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                _buildMetric('PEAK', '${test.peakDb.toInt()}', 'dB', statusColor, primaryColor),
                                const SizedBox(width: 40),
                                _buildMetric('LIMIT', '${test.limitDb.toInt()}', 'dB', primaryColor.withOpacity(0.7), primaryColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPass, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPass ? Icons.check_circle_rounded : Icons.error_rounded,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            isPass ? 'PASS' : 'FAIL',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, String unit, Color valueColor, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: primaryColor.withOpacity(0.3),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                unit,
                style: TextStyle(
                  color: valueColor.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: primaryColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 56, color: primaryColor.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text(
            'NO RECORDS FOUND',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: primaryColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Perform a sound check to start archiving your vehicle performance data.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: primaryColor.withOpacity(0.5),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimationAppearance extends StatelessWidget {
  final Widget child;
  const AnimationAppearance({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 15.0,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}
