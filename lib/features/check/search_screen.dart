import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../data/models/bike_model.dart';
import '../../core/providers/bike_provider.dart';
import 'bike_details_screen.dart';
import 'result_screen.dart';
import 'scan_plate_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  List<Bike> _filteredBikes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isPlateFormat(String query) {
    final cleanQuery = query.toUpperCase().replaceAll(' ', '');

    final plateRegex = RegExp(r'^([A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{4})|([0-9]{2}BH[0-9]{4}[A-Z]{1,2})$');
    return plateRegex.hasMatch(cleanQuery);
  }

  void _onSearchChanged(String query) {
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        final q = query.toLowerCase();
        _filteredBikes = bikeProvider.manufacturers
            .expand((m) => m.bikes.map((b) => {'bike': b, 'manufacturer': m.name}))
            .where((item) {
              final bike = item['bike'] as Bike;
              final manufacturer = item['manufacturer'] as String;
              return bike.name.toLowerCase().contains(q) || 
                     manufacturer.toLowerCase().contains(q);
            })
            .map((item) => item['bike'] as Bike)
            .toList();
      }
    });
  }

  void _handleSubmit(String query) {
    if (query.isEmpty) return;
    
    if (_isPlateFormat(query)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(plateNumber: query.toUpperCase().replaceAll(' ', '')),
        ),
      );
    } else {
      if (_filteredBikes.isNotEmpty) {
        final bike = _filteredBikes.first;
        _navigateToDetails(bike, bike.manufacturerId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

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
                        'SMART SEARCH',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      Text(
                        _isSearching ? 'SEARCHING' : 'VERIFICATION',
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
            _buildSearchBar(isDark),
            Expanded(
              child: _isSearching 
                  ? _buildSearchResults(isDark) 
                  : _buildDirectory(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Center(
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            onSubmitted: _handleSubmit,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              color: primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'Plate No, Model or Brand...',
              hintStyle: TextStyle(
                color: primaryColor.withOpacity(0.24),
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(Icons.search, color: primaryColor.withOpacity(0.38), size: 28),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: primaryColor),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.camera, color: primaryColor.withOpacity(0.5), size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScanPlateScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectory(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'MANUFACTURERS',
          style: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildDirectoryContent(isDark),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDirectoryContent(bool isDark) {
    final bikeProvider = Provider.of<BikeProvider>(context);
    return Column(
      children: bikeProvider.manufacturers
          .map((manufacturer) => _buildManufacturerAccordion(isDark, manufacturer))
          .toList(),
    );
  }

  Widget _buildManufacturerAccordion(bool isDark, Manufacturer manufacturer) {
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            iconColor: primaryColor,
            collapsedIconColor: primaryColor.withOpacity(0.5),
            title: Text(
              manufacturer.name.toUpperCase(),
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            children: manufacturer.bikes.map((bike) => _buildBikeTile(isDark, bike, manufacturer.name)).toList(),
          ),
        ),
        Divider(color: primaryColor.withOpacity(0.05), height: 1),
      ],
    );
  }

  Widget _buildBikeTile(bool isDark, Bike bike, String manufacturerName) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetails(bike, manufacturerName),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Row(
              children: [
                Icon(
                  bike.isScooter ? Icons.moped_rounded : Icons.motorcycle_rounded,
                  color: primaryColor.withOpacity(0.3),
                  size: 16,
                ),
                const SizedBox(width: 16),
                Text(
                  bike.name,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, color: primaryColor.withOpacity(0.1), size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    if (_filteredBikes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: primaryColor.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              'NO RESULTS FOUND',
              style: TextStyle(
                color: primaryColor.withOpacity(0.38),
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredBikes.length,
      itemBuilder: (context, index) {
        final bike = _filteredBikes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primaryColor.withOpacity(0.05), width: 1.5),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  bike.isScooter ? Icons.moped_rounded : Icons.motorcycle_rounded,
                  color: primaryColor.withOpacity(0.3),
                  size: 18,
                ),
              ),
              title: Text(
                bike.name,
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                bike.manufacturerId.toUpperCase(),
                style: TextStyle(
                  color: primaryColor.withOpacity(0.38),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded, color: primaryColor.withOpacity(0.2), size: 14),
              onTap: () {
                _navigateToDetails(bike, bike.manufacturerId);
              },
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetails(Bike bikeData, String companyName) {
    final bike = BikeModel(
      id: bikeData.id,
      plateNumber: 'N/A',
      make: companyName,
      model: bikeData.name,
      year: 2023,
      engineSize: '998cc',
      power: '203 HP',
      weight: '207 kg',
      topSpeed: '299 km/h',
      dbLimit: 95.0,
      isLegal: true,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BikeDetailsScreen(
          bike: bike,
          specs: const [
            {'label': 'ENGINE', 'value': '998cc', 'icon': FontAwesomeIcons.motorcycle},
            {'label': 'POWER', 'value': '203 HP', 'icon': FontAwesomeIcons.bolt},
            {'label': 'WEIGHT', 'value': '207 kg', 'icon': FontAwesomeIcons.weightHanging},
            {'label': 'TOP SPEED', 'value': '299 km/h', 'icon': FontAwesomeIcons.gaugeHigh},
          ],
        ),
      ),
    );
  }
}

