import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  void _shareDocuments() {
    Share.share('Check out my vehicle documents on MotoCheck!');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.white38 : Colors.black38;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DIGITAL GARAGE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: secondaryColor,
                        ),
                      ),
                      Text(
                        'DOCUMENTS',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildSectionHeader('VEHICLE DOCUMENTS', isDark),
                    const SizedBox(height: 12),
                    _buildDocumentTile(
                      'Registration (RC)', 
                      'Verified • Valid until 2038', 
                      Icons.card_membership_rounded, 
                      const Color(0xFF2196F3), 
                      isDark
                    ),
                    const SizedBox(height: 10),
                    _buildDocumentTile(
                      'Insurance Policy', 
                      'Active • Expires Jan 2025', 
                      Icons.verified_user_rounded, 
                      const Color(0xFF00A37B), 
                      isDark
                    ),
                    const SizedBox(height: 10),
                    _buildDocumentTile(
                      'PUC Certificate', 
                      'Warning • Expires in 8 days', 
                      Icons.cloud_done_rounded, 
                      const Color(0xFFFF9100), 
                      isDark
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('PERSONAL DOCUMENTS', isDark),
                    const SizedBox(height: 12),
                    _buildDocumentTile(
                      'Driving License', 
                      'Verified • Class: MCWG', 
                      Icons.assignment_ind_rounded, 
                      const Color(0xFF9C27B0), 
                      isDark
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('QUICK ACTIONS', isDark),
                    const SizedBox(height: 12),
                    _buildSimpleTile('Share Documents', Icons.share_rounded, isDark, onTap: _shareDocuments),
                    const SizedBox(height: 10),
                    _buildSimpleTile('Download PDF', Icons.file_download_rounded, isDark, onTap: () {}),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : const Color(0xFFF8F9FA),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            onPressed: () {},
            icon: const Icon(Icons.add_a_photo_rounded),
            label: const Text('SCAN NEW DOCUMENT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: isDark ? Colors.white38 : Colors.black38,
      ),
    );
  }

  Widget _buildDocumentTile(String title, String subtitle, IconData icon, Color color, bool isDark) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
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
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primaryColor),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(Icons.more_vert_rounded, color: isDark ? Colors.white24 : Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTile(String title, IconData icon, bool isDark, {VoidCallback? onTap}) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: primaryColor),
                ),
              ],
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26),
          ],
        ),
      ),
    );
  }
}

