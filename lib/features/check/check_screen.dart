import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../sound/sound_history_screen.dart';
import '../stats/stats_screen.dart';
import 'result_screen.dart';
import 'scan_plate_screen.dart';
import 'search_screen.dart';
import '../home/book_service_screen.dart';
import '../home/oil_guide_screen.dart';
import '../home/documents_screen.dart';

class CheckScreen extends StatefulWidget {
  const CheckScreen({super.key});

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    if (value.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(plateNumber: value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: RepaintBoundary(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DATABASE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'SEARCH',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.05),
                                width: 1.5,
                              ),
                              boxShadow: [
                                if (!isDark)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                onSubmitted: _handleSearch,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                                  );
                                },
                                readOnly: true,
                                textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search bike model or plate number...',
                                  hintStyle: TextStyle(
                                    color: primaryColor.withOpacity(0.24),
                                    fontWeight: FontWeight.normal,
                                  ),
                                  prefixIcon: Icon(Icons.search_rounded,
                                      color: primaryColor.withOpacity(0.38), size: 28),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear, color: primaryColor),
                                          onPressed: () {
                                            _searchController.clear();
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 35),
                          _buildSectionHeader('SMART MAINTENANCE', isDark),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildMaintenanceButton(
                                'Book Service',
                                Icons.build_rounded,
                                isDark,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const BookServiceScreen()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildMaintenanceButton(
                                'Oil Guide',
                                Icons.oil_barrel_rounded,
                                isDark,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const OilGuideScreen()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildMaintenanceButton(
                                'Documents',
                                Icons.description_rounded,
                                isDark,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DocumentsScreen()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),
                          _buildSectionHeader('QUICK ACTIONS', isDark),
                          const SizedBox(height: 15),
                          _buildQuickActionGrid(isDark),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildMaintenanceButton(String label, IconData icon, bool isDark,
      {VoidCallback? onTap}) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primaryColor.withOpacity(0.05), width: 1.5),
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
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 24, color: primaryColor.withOpacity(0.8)),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionGrid(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildQuickAction(
            isDark, 'Scan Plate', FontAwesomeIcons.camera, const Color(0xFF00C853)),
        _buildQuickAction(
            isDark, 'History', FontAwesomeIcons.clockRotateLeft, const Color(0xFF2196F3)),
        _buildQuickAction(
            isDark, 'Stats', FontAwesomeIcons.chartLine, const Color(0xFFFF9100)),
        _buildQuickAction(isDark, 'Police Mode', Icons.policy_rounded, const Color(0xFFFF5252)),
      ],
    );
  }

  Widget _buildQuickAction(bool isDark, String label, IconData icon, Color color) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.05), width: 1.5),
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
          onTap: () {
            if (label == 'Scan Plate') {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const ScanPlateScreen()));
            } else if (label == 'History') {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const SoundHistoryScreen()));
            } else if (label == 'Stats') {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const StatsScreen()));
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

