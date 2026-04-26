import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  String _selectedService = 'General Maintenance';
  String _selectedCenter = 'Authorized RE Center';

  final List<String> _services = [
    'General Maintenance',
    'Oil & Filter Change',
    'Brake & Suspension',
    'Chain Cleaning & Lubing',
    'Electrical Checkup'
  ];

  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Do you want to book a $_selectedService appointment at $_selectedCenter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking Confirmed! Center will contact you.'),
                  backgroundColor: Color(0xFF00A37B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('CONFIRM', style: TextStyle(color: Color(0xFF00A37B), fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
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
                        'MAINTENANCE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: secondaryColor,
                        ),
                      ),
                      Text(
                        'BOOK SERVICE',
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
                    _buildSectionHeader('SERVICE CENTERS', isDark),
                    const SizedBox(height: 12),
                    _buildCenterTile(
                      'Authorized RE Center', 
                      '4.8 km away • Open now', 
                      Icons.location_on_rounded, 
                      const Color(0xFF2196F3), 
                      isDark
                    ),
                    const SizedBox(height: 10),
                    _buildCenterTile(
                      'Moto Experts Hub', 
                      '2.1 km away • Highly Rated', 
                      Icons.star_rounded, 
                      const Color(0xFFFF9100), 
                      isDark
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('SELECT SERVICE', isDark),
                    const SizedBox(height: 12),
                    ..._services.map((service) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildSelectableTile(service, isDark),
                    )),
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
            onPressed: _confirmBooking,
            child: const Text('CONFIRM APPOINTMENT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
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

  Widget _buildCenterTile(String title, String subtitle, IconData icon, Color color, bool isDark) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    bool isSelected = _selectedCenter == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedCenter = title),
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

  Widget _buildSelectableTile(String title, bool isDark) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    bool isSelected = _selectedService == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedService = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFF00A37B) : (isDark ? Colors.white : Colors.black).withOpacity(0.05), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: primaryColor),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, 
              color: isSelected ? const Color(0xFF00A37B) : (isDark ? Colors.white24 : Colors.black26)
            ),
          ],
        ),
      ),
    );
  }
}

