import 'package:flutter/material.dart';
import 'widgets/bike_card.dart';
import 'widgets/spec_card.dart';
import '../../../data/models/bike_model.dart';

class BikeDetailsScreen extends StatelessWidget {
  final BikeModel bike;
  final List<Map<String, dynamic>> specs;

  const BikeDetailsScreen({
    super.key, 
    required this.bike,
    required this.specs,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
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
                    'DETAILS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SPECIFICATIONS',
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
              BikeCard(bike: bike),
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
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: specs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final spec = specs[index];
                  return SpecCard(
                    label: spec['label'],
                    value: spec['value'],
                    icon: spec['icon'],
                  );
                },
              ),
              const SizedBox(height: 30),
              Text(
                'DESCRIPTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.05),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'This ${bike.year} ${bike.make} ${bike.model} is a high-performance machine designed for precision and speed. It features advanced engineering and a lightweight chassis for superior handling on both street and track.',
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.7),
                    height: 1.6,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(24),
                    child: Center(
                      child: Text(
                        'ADD TO FAVORITES',
                        style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
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
