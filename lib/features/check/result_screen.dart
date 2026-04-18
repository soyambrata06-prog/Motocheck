import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'widgets/bike_card.dart';
import 'widgets/legal_tag.dart';
import 'widgets/spec_card.dart';
import 'widgets/decibel_indicator.dart';
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
    // Add a minimum delay for the animation to look good
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
    
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_bikeData == null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text('Vehicle details not found for ${widget.plateNumber}'),
        ),
      );
    }

    final bike = _bikeData!;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 500),
          child: FadeInAnimation(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
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
                  const SizedBox(height: 120),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VERIFIED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RESULT',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  BikeCard(bike: bike),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LEGALITY STATUS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38),
                        ),
                      ),
                      LegalTag(isLegal: bike.isLegal),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DecibelIndicator(decibel: 92, limit: bike.dbLimit ?? 95),
                  const SizedBox(height: 30),
                  Text(
                    'TECHNICAL SPECIFICATIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38),
                    ),
                  ),
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 40),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final isSaved = userProvider.savedBikes.any((b) => b.plateNumber == bike.plateNumber);
                      final buttonColor = isSaved ? Colors.grey[900]! : const Color(0xFF00C853);
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        width: double.infinity,
                        height: 72,
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: buttonColor.withOpacity(isSaved ? 0.1 : 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (isSaved) {
                                userProvider.removeBike(bike.plateNumber);
                              } else {
                                userProvider.saveBike(bike);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.2),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                key: ValueKey(isSaved),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isSaved ? 'IN YOUR GARAGE' : 'SAVE TO GARAGE',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
    );
  }

  Widget _buildLoadingState(bool isDark) {
    final baseColor = isDark ? Colors.grey[900]! : Colors.grey[200]!;
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
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
      ),
    );
  }
}
