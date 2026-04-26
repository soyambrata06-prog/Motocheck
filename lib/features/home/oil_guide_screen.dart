import 'package:flutter/material.dart';

class OilGuideScreen extends StatefulWidget {
  const OilGuideScreen({super.key});

  @override
  State<OilGuideScreen> createState() => _OilGuideScreenState();
}

class _OilGuideScreenState extends State<OilGuideScreen> {
  String _selectedOil = 'Castrol Power1 Ultimate';

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
                        'MAINTENANCE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: secondaryColor,
                        ),
                      ),
                      Text(
                        'OIL GUIDE',
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
                    _buildSectionHeader('RECOMMENDED OIL', isDark),
                    const SizedBox(height: 12),
                    _buildOilTile(
                      'Castrol Power1 Ultimate', 
                      '10W-40 Full Synthetic', 
                      Icons.water_drop_rounded, 
                      const Color(0xFFFF9100), 
                      isDark
                    ),
                    const SizedBox(height: 10),
                    _buildOilTile(
                      'Motul 7100 4T', 
                      '20W-50 Synthetic', 
                      Icons.water_drop_rounded, 
                      const Color(0xFFFF5252), 
                      isDark
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('CHECK PROCEDURES', isDark),
                    const SizedBox(height: 12),
                    _buildStepTile(1, 'Warm up engine for 5 mins then stop.', isDark),
                    _buildStepTile(2, 'Keep bike upright on level ground.', isDark),
                    _buildStepTile(3, 'Check level window or dipstick.', isDark),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('OIL STATUS', isDark),
                    const SizedBox(height: 12),
                    _buildStatusCard('Healthy', 'Last changed: 2,400 km ago', isDark),
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
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maintenance Log Updated!'),
                  backgroundColor: Color(0xFF00A37B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('LOG OIL CHANGE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
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

  Widget _buildOilTile(String title, String subtitle, IconData icon, Color color, bool isDark) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    bool isSelected = _selectedOil == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedOil = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFF00A37B) : (isDark ? Colors.white : Colors.black).withOpacity(0.05), width: 2),
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
              if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF00A37B)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepTile(int num, String text, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF00A37B),
            child: Text('$num', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status, String lastChange, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00A37B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00A37B).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF00A37B), size: 20),
              const SizedBox(width: 8),
              Text(status, style: const TextStyle(color: Color(0xFF00A37B), fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(lastChange, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

