import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'widgets/bike_card.dart';
import 'widgets/legal_tag.dart';
import 'widgets/spec_card.dart';
import 'widgets/decibel_indicator.dart';
import 'plate_details_screen.dart';
import '../../../data/models/bike_model.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../../data/services/vehicle_service.dart';

class ResultScreen extends StatefulWidget {
  final String plateNumber;
  const ResultScreen({super.key, required this.plateNumber});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final VehicleService _vehicleService = VehicleService();
  BikeModel? _bikeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBikeDetails();
  }

  Future<void> _fetchBikeDetails() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    final data = await _vehicleService.getVehicleDetails(widget.plateNumber);
    if (mounted) {
      setState(() {
        _bikeData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.white38 : Colors.black38;
    final bgColor = isDark ? Colors.black : const Color(0xFFF8F9FA);

    if (_isLoading) {
      return _buildLoadingState(isDark, bgColor);
    }

    if (_bikeData == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: secondaryColor),
              const SizedBox(height: 16),
              Text(
                'Vehicle details not found for ${widget.plateNumber}',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('GO BACK', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF00C853))),
              ),
            ],
          ),
        ),
      );
    }

    final bike = _bikeData!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
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
                        color: primaryColor.withOpacity(0.05),
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
                        'VERIFICATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: secondaryColor,
                        ),
                      ),
                      Text(
                        'RESULT',
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
              child: AnimationLimiter(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 600),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        BikeCard(bike: bike),
                        const SizedBox(height: 32),
                        
                        _buildSectionHeader('LEGALITY STATUS', isDark),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              bike.isLegal ? 'AUTHORIZED' : 'ILLEGAL MODS DETECTED',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                            LegalTag(isLegal: bike.isLegal),
                          ],
                        ),
                        const SizedBox(height: 15),
                        DecibelIndicator(decibel: 92, limit: bike.dbLimit ?? 95),
                        const SizedBox(height: 32),
                        
                        _buildSectionHeader('TECHNICAL SPECIFICATIONS', isDark),
                        const SizedBox(height: 12),
                        GridView.count(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            SpecCard(label: 'ENGINE', value: bike.engineSize ?? 'N/A', icon: FontAwesomeIcons.motorcycle),
                            SpecCard(label: 'POWER', value: bike.power ?? 'N/A', icon: FontAwesomeIcons.bolt),
                            SpecCard(label: 'WEIGHT', value: bike.weight ?? 'N/A', icon: FontAwesomeIcons.weightHanging),
                            SpecCard(label: 'TOP SPEED', value: bike.topSpeed ?? 'N/A', icon: FontAwesomeIcons.gaugeHigh),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        _buildSectionHeader('REGISTRATION RECORD', isDark),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          'View Full Registration Details',
                          Icons.assignment_rounded,
                          isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PlateDetailsScreen(bike: bike)),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            final isSaved = userProvider.savedBikes.any((b) => b.plateNumber == bike.plateNumber);
                            return _buildActionButton(
                              isSaved ? 'Remove from Garage' : 'Save to Digital Garage',
                              isSaved ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
                              isDark,
                              isPrimary: !isSaved,
                              onTap: () {
                                if (isSaved) {
                                  userProvider.removeBike(bike.plateNumber);
                                } else {
                                  userProvider.saveBike(bike);
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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

  Widget _buildActionButton(String title, IconData icon, bool isDark, {bool isPrimary = false, VoidCallback? onTap}) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? primaryColor : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPrimary ? Colors.transparent : primaryColor.withOpacity(0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isPrimary ? (isDark ? Colors.black : Colors.white) : primaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1,
                    color: isPrimary ? (isDark ? Colors.black : Colors.white) : primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark, Color bgColor) {
    final baseColor = isDark ? Colors.grey[900]! : Colors.grey[200]!;
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 60, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
                    const SizedBox(height: 8),
                    Container(width: 120, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
                    const SizedBox(height: 30),
                    Container(width: double.infinity, height: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32))),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 100, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
                        Container(width: 70, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(width: double.infinity, height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32))),
                    const SizedBox(height: 30),
                    Container(width: 150, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
                    const SizedBox(height: 15),
                    GridView.count(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: List.generate(4, (index) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)))),
                    ),
                    const SizedBox(height: 40),
                    Container(width: double.infinity, height: 72, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

