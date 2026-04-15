import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/providers/bike_provider.dart';
import 'result_screen.dart';

class CheckScreen extends StatefulWidget {
  const CheckScreen({super.key});

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  bool _showManufacturers = false;
  List<Bike> _filteredBikes = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showManufacturers = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final bikeProvider = Provider.of<BikeProvider>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredBikes = [];
      } else {
        _filteredBikes = bikeProvider.manufacturers
            .expand((c) => c.bikes)
            .where((b) => b.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _handleSearch(String value) {
    if (value.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    // Mock search delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ResultScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: RepaintBoundary(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Search Bar
                  Container(
                    height: 70, 
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121212) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white : Colors.black,
                        width: 4.0, // Bolder outline 4.0
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        onSubmitted: _handleSearch,
                        textAlignVertical: TextAlignVertical.center, // Vertically centered
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search bike model or plate number...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.normal,
                          ),
                          prefixIcon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black, size: 28),
                          suffixIcon: _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00C853)),
                                  ),
                                )
                              : (_searchController.text.isNotEmpty 
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: isDark ? Colors.white : Colors.black),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero, // Zero padding with Center widget handles alignment
                        ),
                      ),
                    ),
                  ),
                  if (_showManufacturers && !_isSearching && isKeyboardVisible) 
                    _buildManufacturerDialog(isDark),
                  const SizedBox(height: 30),
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildQuickAction(isDark, 'Scan Plate', FontAwesomeIcons.camera)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildQuickAction(isDark, 'History', FontAwesomeIcons.clockRotateLeft)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildQuickAction(isDark, 'Stats', FontAwesomeIcons.chartLine)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildRecentSearch(isDark, 'Kawasaki Ninja ZX-10R', 'ABC 1234'),
                  const SizedBox(height: 12),
                  _buildRecentSearch(isDark, 'Yamaha R1M', 'XYZ 9876'),
                  const SizedBox(height: 12),
                  _buildRecentSearch(isDark, 'Ducati Panigale V4', 'BKR 4455'),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManufacturerDialog(bool isDark) {
    final bikeProvider = Provider.of<BikeProvider>(context);

    if (bikeProvider.isLoading) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF00C853))),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 450),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white : Colors.black,
          width: 4.0, // Match search bar outline
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Heading
          if (_searchController.text.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                'Choose Your Model',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _searchController.text.isEmpty 
                ? ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: bikeProvider.manufacturers.length,
                    itemBuilder: (context, index) {
                      final company = bikeProvider.manufacturers[index];
                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: Key('${company.id}_${company.isExpanded}'), // Changing key forces rebuild
                          initiallyExpanded: company.isExpanded,
                          onExpansionChanged: (expanded) {
                            if (expanded) {
                              setState(() {
                                for (var m in bikeProvider.manufacturers) {
                                  m.isExpanded = (m.id == company.id);
                                }
                              });
                            } else {
                              setState(() {
                                company.isExpanded = false;
                              });
                            }
                          },
                          iconColor: isDark ? Colors.white : Colors.black,
                          collapsedIconColor: isDark ? Colors.white54 : Colors.black54,
                          title: Text(
                            company.name,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: company.bikes.map((bike) => ListTile(
                            leading: Icon(
                              bike.isScooter ? Icons.moped_rounded : Icons.motorcycle_rounded,
                              color: isDark ? Colors.white54 : Colors.black54,
                              size: 20,
                            ),
                            title: Text(
                              bike.name,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                            ),
                            onTap: () {
                              _searchController.text = bike.name;
                              _focusNode.unfocus();
                              _handleSearch(bike.name);
                            },
                          )).toList(),
                        ),
                      );
                    },
                  )
                : _filteredBikes.isEmpty 
                  ? const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No bikes found', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _filteredBikes.length,
                      itemBuilder: (context, index) {
                        final bike = _filteredBikes[index];
                        return ListTile(
                          leading: Icon(
                            bike.isScooter ? Icons.moped_rounded : Icons.motorcycle_rounded,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          title: Text(
                            bike.name,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          ),
                          onTap: () {
                            _searchController.text = bike.name;
                            _focusNode.unfocus();
                            _handleSearch(bike.name);
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(bool isDark, String label, IconData icon) {
    Color iconColor;
    if (label == 'History') {
      iconColor = const Color(0xFFFFD740); // Yellow
    } else if (label == 'Stats') {
      iconColor = const Color(0xFF00C853); // Green
    } else {
      iconColor = const Color(0xFF448AFF); // Blue (Scan Plate)
    }
    
    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, color: iconColor, size: 30),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearch(bool isDark, String title, String plate) {
    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResultScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const FaIcon(FontAwesomeIcons.motorcycle, color: Color(0xFF00C853), size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      plate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }
}
