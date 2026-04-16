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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _showManufacturers = false;
        });
      },
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DATABASE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
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
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Container(
                    height: 70, 
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        onSubmitted: _handleSearch,
                        onTap: () {
                          setState(() {
                            _showManufacturers = true;
                          });
                        },
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search bike model or plate number...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white24 : Colors.black26,
                            fontWeight: FontWeight.normal,
                          ),
                          prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.black38, size: 28),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    reverseDuration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutQuart,
                    switchOutCurve: Curves.easeInQuad,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1.0,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: ((_showManufacturers || _focusNode.hasFocus) && !_isSearching)
                        ? _buildManufacturerDialog(isDark)
                        : const SizedBox.shrink(key: ValueKey('dialog_hidden')),
                  ),
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
        key: const ValueKey('dialog_loading'),
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white : Colors.black,
            width: 4.0,
          ),
        ),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF00C853))),
      );
    }

    return Container(
      key: const ValueKey('dialog_content'),
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 320, minHeight: 180),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white : Colors.black,
          width: 4.0, // Match search bar outline
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              child: Scrollbar(
                thumbVisibility: true,
                child: _searchController.text.isEmpty 
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: EdgeInsets.zero,
                      itemCount: bikeProvider.manufacturers.length,
                      itemBuilder: (context, index) {
                        final company = bikeProvider.manufacturers[index];
                        return Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            expansionTileTheme: ExpansionTileThemeData(
                              backgroundColor: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                            ),
                          ),
                          child: ExpansionTile(
                            key: Key('${company.id}_${company.isExpanded}'),
                            initiallyExpanded: company.isExpanded,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                for (var m in bikeProvider.manufacturers) {
                                  m.isExpanded = (m.id == company.id) ? expanded : false;
                                }
                              });
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
                                setState(() {
                                  _showManufacturers = false;
                                });
                                _handleSearch(bike.name);
                              },
                            )).toList(),
                          ),
                        );
                      },
                    )
                  : _filteredBikes.isEmpty 
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded, color: Colors.grey[400], size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No bikes found',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                              setState(() {
                                  _showManufacturers = false;
                              });
                              _handleSearch(bike.name);
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(bool isDark, String label, IconData icon) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.05), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(icon, color: primaryColor.withOpacity(0.3), size: 30),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearch(bool isDark, String title, String plate) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.05), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ResultScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FaIcon(FontAwesomeIcons.motorcycle, color: primaryColor.withOpacity(0.3), size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        plate,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primaryColor.withOpacity(0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
