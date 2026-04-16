import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/models/bike_model.dart';
import 'bike_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Mock data for internal use if provider is not used here
  final List<Map<String, dynamic>> _mockCompanies = [
    {
      'name': 'KAWASAKI',
      'bikes': [
        {'name': 'Ninja ZX-10R', 'isScooter': false, 'year': 2023},
        {'name': 'Z900', 'isScooter': false, 'year': 2022},
      ]
    },
    {
      'name': 'YAMAHA',
      'bikes': [
        {'name': 'R1M', 'isScooter': false, 'year': 2023},
        {'name': 'MT-09', 'isScooter': false, 'year': 2022},
        {'name': 'NMAX 155', 'isScooter': true, 'year': 2023},
      ]
    },
    {
      'name': 'DUCATI',
      'bikes': [
        {'name': 'Panigale V4', 'isScooter': false, 'year': 2023},
        {'name': 'Streetfighter V4', 'isScooter': false, 'year': 2023},
      ]
    },
  ];

  List<Map<String, dynamic>> _filteredBikes = [];

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredBikes = _mockCompanies
            .expand((c) => (c['bikes'] as List).map((b) => {
                  ...Map<String, dynamic>.from(b),
                  'company': c['name'] as String,
                }))
            .where((b) => b['name'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPLORE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.38),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'DATABASE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _buildSearchBar(isDark),
          Expanded(
            child: _isSearching ? _buildSearchResults(isDark) : _buildDirectory(isDark),
          ),
        ],
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
            onChanged: _onSearchChanged,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              color: primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'Search bike model...',
              hintStyle: TextStyle(
                color: primaryColor.withOpacity(0.24),
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(Icons.search, color: primaryColor.withOpacity(0.38), size: 28),
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
        ..._mockCompanies.map((company) => _buildCompanyAccordion(isDark, company)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildCompanyAccordion(bool isDark, Map<String, dynamic> company) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    final bikes = company['bikes'] as List;

    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            iconColor: primaryColor,
            collapsedIconColor: primaryColor.withOpacity(0.5),
            title: Text(
              company['name'],
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            children: bikes.map((bike) => _buildBikeTile(isDark, bike, company['name'])).toList(),
          ),
        ),
        Divider(color: primaryColor.withOpacity(0.05), height: 1),
      ],
    );
  }

  Widget _buildBikeTile(bool isDark, Map<String, dynamic> bike, String companyName) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetails(bike, companyName),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Row(
              children: [
                Icon(
                  bike['isScooter'] ? Icons.moped_rounded : Icons.motorcycle_rounded,
                  color: primaryColor.withOpacity(0.3),
                  size: 16,
                ),
                const SizedBox(width: 16),
                Text(
                  bike['name'],
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
                  bike['isScooter'] ? Icons.moped_rounded : Icons.motorcycle_rounded,
                  color: primaryColor.withOpacity(0.3),
                  size: 18,
                ),
              ),
              title: Text(
                bike['name'],
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                bike['company'],
                style: TextStyle(
                  color: primaryColor.withOpacity(0.38),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded, color: primaryColor.withOpacity(0.2), size: 14),
              onTap: () => _navigateToDetails(bike, bike['company']),
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetails(Map<String, dynamic> bikeData, String companyName) {
    final bike = BikeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      plateNumber: 'N/A',
      make: companyName,
      model: bikeData['name'],
      year: bikeData['year'],
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
