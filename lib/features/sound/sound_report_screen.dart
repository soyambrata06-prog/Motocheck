import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/sound_test_model.dart';

class SoundReportScreen extends StatelessWidget {
  final SoundTestModel testResult;

  const SoundReportScreen({super.key, required this.testResult});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = testResult.isPass ? const Color(0xFF00C853) : const Color(0xFFFF5252);
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detailed Report',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: isDark ? Colors.white : Colors.black),
            onPressed: () => _shareReport(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(primaryColor, isDark),
            const SizedBox(height: 24),
            _buildInfoCard(cardColor, isDark),
            const SizedBox(height: 24),
            _buildAnalyticsSection(cardColor, isDark, primaryColor),
            const SizedBox(height: 24),
            _buildLegalDisclaimer(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(Color color, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(
            testResult.isPass ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: color,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            testResult.isPass ? 'COMPLIANT' : 'NON-COMPLIANT',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            testResult.isPass 
                ? 'This vehicle meets the noise emission standards.' 
                : 'This vehicle exceeds the legal noise limit.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Color cardColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('Vehicle', testResult.bikeName, isDark),
          const Divider(height: 32),
          _buildInfoRow('Manufacturer', testResult.manufacturer, isDark),
          const Divider(height: 32),
          _buildInfoRow('Test Mode', testResult.mode.toUpperCase(), isDark),
          const Divider(height: 32),
          _buildInfoRow('Date', DateFormat('MMM dd, yyyy • hh:mm a').format(testResult.timestamp), isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(Color cardColor, bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'METRICS & ANALYTICS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                'Peak Level',
                testResult.peakDb.toStringAsFixed(1),
                'dB',
                primaryColor,
                cardColor,
                isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricTile(
                'Legal Limit',
                testResult.limitDb.toStringAsFixed(0),
                'dB',
                isDark ? Colors.white30 : Colors.black12,
                cardColor,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Variance',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${(testResult.peakDb - testResult.limitDb).toStringAsFixed(1)} dB',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: testResult.isPass ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (testResult.peakDb / 120).clamp(0.0, 1.0),
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, String unit, Color color, Color cardColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: color == Colors.white30 || color == Colors.black12 
                      ? (isDark ? Colors.white : Colors.black) 
                      : color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegalDisclaimer(bool isDark) {
    return Column(
      children: [
        const Divider(height: 40),
        Text(
          'LEGAL DISCLAIMER',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This report is generated by MotoCheck using mobile hardware. While calibrated to high standards, it is not a substitute for certified laboratory testing. Local law enforcement may use different measurement methodologies.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _shareReport() {
    final report = 'MotoCheck Sound Test Report\n'
        '--------------------------\n'
        'Vehicle: ${testResult.bikeName}\n'
        'Result: ${testResult.isPass ? "PASS" : "FAIL"}\n'
        'Peak Level: ${testResult.peakDb.toStringAsFixed(1)} dB\n'
        'Legal Limit: ${testResult.limitDb.toStringAsFixed(0)} dB\n'
        'Mode: ${testResult.mode}\n'
        'Date: ${DateFormat('MMM dd, yyyy').format(testResult.timestamp)}\n'
        '--------------------------\n'
        'Generated by MotoCheck';
    
    Share.share(report);
  }
}
