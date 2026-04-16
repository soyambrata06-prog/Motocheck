import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme_provider.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final primaryColor = isDark ? Colors.white : Colors.black;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background Gradient for depth (True Black style)
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
                      const Color(0xFF448AFF).withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          
          SafeArea(
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
                        
                        _buildSectionHeader('GET IN TOUCH', isDark),
                        const SizedBox(height: 16),
                        
                        _buildSupportAction(
                          isDark,
                          'Call Support',
                          Icons.phone_in_talk_rounded,
                          '+1 (800) 123-4567',
                          color: const Color(0xFF448AFF), // Blue
                        ),
                        const SizedBox(height: 12),
                        _buildSupportAction(
                          isDark,
                          'Email Support',
                          Icons.alternate_email_rounded,
                          'support@motocheck.app',
                          color: const Color(0xFFFF5252), // Red
                        ),
                        const SizedBox(height: 12),
                        _buildSupportAction(
                          isDark,
                          'Web Support',
                          Icons.language_rounded,
                          'www.motocheck.app',
                          color: const Color(0xFF00C853), // Green
                        ),
                        
                        const SizedBox(height: 30),
                        _buildSectionHeader('FREQUENTLY ASKED', isDark),
                        const SizedBox(height: 16),
                        
                        _buildFaqItem(
                          isDark,
                          'How does AI scanning work?',
                          'Our ML-powered engine uses real-time OCR to detect and extract plate numbers instantly using your camera.',
                        ),
                        _buildFaqItem(
                          isDark,
                          'Is my data secure?',
                          'Yes, all scans and personal data are encrypted and never shared with third parties without consent.',
                        ),
                        _buildFaqItem(
                          isDark,
                          'What is Safety Score?',
                          'It\'s a metric based on your riding habits, legal compliance, and document validity.',
                        ),
                        _buildFaqItem(
                          isDark,
                          'How to trigger SOS?',
                          'You can use the dedicated SOS button or enable crash detection in settings for auto-trigger.',
                        ),
                        
                        const SizedBox(height: 24),
                        _buildSupportAction(
                          isDark,
                          'Terms of Service',
                          Icons.description_outlined,
                          'Read our legal policies',
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
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
              'ASSISTANCE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: primaryColor.withOpacity(0.38),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'HELP CENTER',
              style: TextStyle(
                fontSize: 28,
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
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.38),
      ),
    );
  }

  Widget _buildFaqItem(bool isDark, String question, String answer) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.05)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          title: Text(
            question,
            style: TextStyle(
              color: primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconColor: primaryColor.withOpacity(0.3),
          collapsedIconColor: primaryColor.withOpacity(0.3),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                answer,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.54),
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportAction(bool isDark, String title, IconData icon, String value, {Color? color}) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    final iconColor = color ?? primaryColor.withOpacity(0.3);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.38),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios_rounded, color: primaryColor.withOpacity(0.1), size: 14),
        ],
      ),
    );
  }
}
