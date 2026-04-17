import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'widgets/bike_card.dart';
import 'widgets/legal_tag.dart';
import 'widgets/spec_card.dart';
import 'widgets/decibel_indicator.dart';
import '../../../data/models/bike_model.dart';

class ResultScreen extends StatelessWidget {
  final String plateNumber;
  const ResultScreen({super.key, required this.plateNumber});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Mock bike data - will be replaced with real API data
    final mockBike = BikeModel(
      id: '1',
      plateNumber: plateNumber.toUpperCase(),
      make: 'Kawasaki',
      model: 'Ninja ZX-10R',
      year: 2023,
      engineSize: '998cc',
      power: '203 HP',
      weight: '207 kg',
      topSpeed: '299 km/h',
      dbLimit: 95,
      isLegal: true,
    );

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
              BikeCard(bike: mockBike),
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
                  LegalTag(isLegal: mockBike.isLegal),
                ],
              ),
              const SizedBox(height: 15),
              DecibelIndicator(decibel: 92, limit: mockBike.dbLimit ?? 95),
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
                  SpecCard(label: 'ENGINE', value: mockBike.engineSize ?? 'N/A', icon: FontAwesomeIcons.motorcycle),
                  SpecCard(label: 'POWER', value: mockBike.power ?? 'N/A', icon: FontAwesomeIcons.bolt),
                  SpecCard(label: 'WEIGHT', value: mockBike.weight ?? 'N/A', icon: FontAwesomeIcons.weightHanging),
                  SpecCard(label: 'TOP SPEED', value: mockBike.topSpeed ?? 'N/A', icon: FontAwesomeIcons.gaugeHigh),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
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
                    onTap: () {},
                    borderRadius: BorderRadius.circular(24),
                    child: const Center(
                      child: Text(
                        'SAVE TO GARAGE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
