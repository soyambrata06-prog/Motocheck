import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/models/bike_model.dart';
import 'package:intl/intl.dart';

class PlateDetailsScreen extends StatelessWidget {
  final BikeModel bike;

  const PlateDetailsScreen({super.key, required this.bike});

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
                        'VERIFIED RECORD',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: secondaryColor,
                        ),
                      ),
                      Text(
                        bike.plateNumber,
                        style: TextStyle(
                          fontSize: 28,
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
                    _buildSectionHeader('OWNER DETAILS', isDark),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      'Full Name',
                      bike.ownerName ?? 'N/A',
                      Icons.person_rounded,
                      const Color(0xFF2196F3),
                      isDark,
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('VEHICLE STATUS', isDark),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      'Insurance',
                      bike.insuranceStatus ?? 'Active',
                      Icons.verified_user_rounded,
                      const Color(0xFF00A37B),
                      isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoTile(
                      'PUC Status',
                      bike.pucStatus ?? 'Valid',
                      Icons.cloud_done_rounded,
                      const Color(0xFFFF9100),
                      isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoTile(
                      'Fitness',
                      bike.fitnessStatus ?? 'Active',
                      Icons.settings_suggest_rounded,
                      const Color(0xFFFF5252),
                      isDark,
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('VEHICLE INFORMATION', isDark),
                    const SizedBox(height: 12),
                    _buildDetailExpansionTile(
                      'Technical Specs',
                      'Model: ${bike.make} ${bike.model}\n'
                      'Engine: ${bike.engineSize}\n'
                      'Power: ${bike.power}\n'
                      'Year: ${bike.year}\n'
                      'Fuel: ${bike.fuelType}',
                      isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildDetailExpansionTile(
                      'Registration Info',
                      'Reg Date: ${bike.regDate}\n'
                      'Class: ${bike.vehicleClass}\n'
                      'Plate: ${bike.plateNumber}\n'
                      'Chassis: **********${bike.id.substring(bike.id.length - 4)}',
                      isDark,
                    ),
                    
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
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Record shared successfully'),
                  backgroundColor: Color(0xFF00A37B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('SHARE RECORD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
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

  Widget _buildInfoTile(String label, String value, IconData icon, Color color, bool isDark) {
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
                    label,
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    value,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primaryColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.verified_rounded, size: 20, color: const Color(0xFF00A37B).withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailExpansionTile(String title, String content, bool isDark) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: primaryColor),
          ),
          iconColor: primaryColor.withOpacity(0.3),
          collapsedIconColor: primaryColor.withOpacity(0.3),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

