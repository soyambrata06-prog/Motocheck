import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/providers/sound_provider.dart';
import '../../data/models/sound_test_model.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final soundProvider = Provider.of<SoundProvider>(context);
    final history = soundProvider.history;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
            color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ANALYTICS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: soundProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
          : history.isEmpty
              ? _buildEmptyState(isDark)
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewSection(isDark, history),
                      const SizedBox(height: 30),
                      _buildChartSection(isDark, history),
                      const SizedBox(height: 30),
                      _buildTopOffenders(isDark, history),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.chartBar, 
            size: 80, color: isDark ? Colors.white10 : Colors.black.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(
            'No data available yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Complete some sound tests to see stats',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(bool isDark, List<SoundTestModel> history) {
    final totalTests = history.length;
    final passedTests = history.where((t) => t.isPass).length;
    final passRate = (passedTests / totalTests * 100).toStringAsFixed(1);
    final avgPeak = (history.map((t) => t.peakDb).reduce((a, b) => a + b) / totalTests).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OVERVIEW',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                isDark, 
                'Total Tests', 
                totalTests.toString(), 
                FontAwesomeIcons.listCheck,
                const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                isDark, 
                'Pass Rate', 
                '$passRate%', 
                FontAwesomeIcons.checkDouble,
                const Color(0xFF00C853),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildStatCard(
          isDark, 
          'Average Peak Volume', 
          '$avgPeak dB', 
          FontAwesomeIcons.volumeHigh,
          const Color(0xFFFF9800),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(bool isDark, String label, String value, IconData icon, Color color, {bool isFullWidth = false}) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.05), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(bool isDark, List<SoundTestModel> history) {
    // Simple bar chart visualization using Containers
    final last7Tests = history.take(7).toList().reversed.toList();
    const maxDb = 120.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT TRENDS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: last7Tests.map((test) {
              final heightFactor = (test.peakDb / maxDb).clamp(0.1, 1.0);
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 25,
                    height: 120 * heightFactor,
                    decoration: BoxDecoration(
                      color: test.isPass ? const Color(0xFF00C853) : const Color(0xFFFF5252),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd/MM').format(test.timestamp),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopOffenders(bool isDark, List<SoundTestModel> history) {
    final failedTests = history.where((t) => !t.isPass).toList();
    failedTests.sort((a, b) => (b.peakDb - b.limitDb).compareTo(a.peakDb - a.limitDb));
    
    final topFailed = failedTests.take(3).toList();

    if (topFailed.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HIGHEST VARIANCE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        const SizedBox(height: 15),
        ...topFailed.map((test) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(FontAwesomeIcons.triangleExclamation, color: Color(0xFFFF5252), size: 14),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.bikeName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      '${(test.peakDb - test.limitDb).toStringAsFixed(1)} dB over limit',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFF5252),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${test.peakDb.toStringAsFixed(0)} dB',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
