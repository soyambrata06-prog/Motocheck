import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupportCard(
              context,
              'Contact Us',
              'Our team is here to help you 24/7',
              Icons.headset_mic_outlined,
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSupportCard(
              context,
              'FAQs',
              'Find answers to common questions',
              Icons.question_answer_outlined,
              isDark,
            ),
            const SizedBox(height: 20),
            _buildSupportCard(
              context,
              'Report an Issue',
              'Let us know if something is not working',
              Icons.report_problem_outlined,
              isDark,
            ),
            const SizedBox(height: 40),
            Text(
              'Quick Contact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            _buildContactRow(Icons.email_outlined, 'support@motocheck.com', isDark),
            _buildContactRow(Icons.phone_outlined, '+1 (555) 123-4567', isDark),
            _buildContactRow(Icons.language_outlined, 'www.motocheck.com', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, String title, String subtitle, IconData icon, bool isDark) {
    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Action for support card
        },
        splashColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF00C853)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.grey[700] : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF00C853)),
          const SizedBox(width: 15),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

