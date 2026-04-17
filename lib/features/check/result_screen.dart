import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    final data = await _vehicleService.getVehicleDetails(widget.plateNumber);
    setState(() {
      _bikeData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD600)),
        ),
      );
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  
                  return Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isSaved ? Colors.grey[800] : const Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isSaved ? [] : [
                        BoxShadow(
                          color: const Color(0xFF00C853).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (isSaved) {
                            userProvider.removeBike(bike.plateNumber);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Removed from Garage')),
                            );
                          } else {
                            userProvider.saveBike(bike);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved to Garage')),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Center(
                          child: Text(
                            isSaved ? 'REMOVE FROM GARAGE' : 'SAVE TO GARAGE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
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
    );
  }
}
