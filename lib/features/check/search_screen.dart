import 'package:flutter/material.dart';

class Bike {
  final String name;
  final bool isScooter;
  Bike(this.name, {this.isScooter = false});
}

class Company {
  final String name;
  final List<Bike> bikes;
  bool isExpanded;

  Company(this.name, this.bikes, {this.isExpanded = false});
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final List<Company> _companies = [
    Company('KTM', [
      Bike('Duke 200'),
      Bike('Duke 390'),
      Bike('RC 200'),
    ]),
    Company('Royal Enfield', [
      Bike('Classic 350'),
      Bike('Hunter 350'),
      Bike('Meteor 350'),
    ]),
    Company('TVS', [
      Bike('Apache RTR 160'),
      Bike('Apache RTR 200'),
      Bike('Ntorq 125', isScooter: true),
    ]),
    Company('Bajaj', [
      Bike('Pulsar NS200'),
      Bike('Pulsar RS200'),
      Bike('Pulsar N160'),
    ]),
    Company('BMW Motorrad', [
      Bike('S1000RR'),
    ]),
  ];

  List<Bike> _filteredBikes = [];

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredBikes = _companies
            .expand((c) => c.bikes)
            .where((b) => b.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: const Text(
                'Explore Bikes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _buildSearchBar(),
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildDirectory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by bike name...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDirectory() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const Text(
          'MANUFACTURERS',
          style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        const SizedBox(height: 16),
        ..._companies.map((company) => _buildCompanyAccordion(company)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildCompanyAccordion(Company company) {
    bool hasManyBikes = company.bikes.length > 2;
    int visibleCount = (company.isExpanded || !hasManyBikes) ? company.bikes.length : 2;

    return Column(
      children: [
        Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            iconColor: Colors.white,
            collapsedIconColor: Colors.white54,
            title: Text(
              company.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleCount + (hasManyBikes && !company.isExpanded ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == visibleCount && hasManyBikes && !company.isExpanded) {
                    return TextButton(
                      onPressed: () => setState(() => company.isExpanded = true),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                      child: const Text('View More', style: TextStyle(color: Colors.white38, fontSize: 13)),
                    );
                  }
                  final bike = company.bikes[index];
                  return _buildBikeTile(bike);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Divider(color: Colors.white.withOpacity(0.05), height: 1),
      ],
    );
  }

  Widget _buildBikeTile(Bike bike) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(bike.isScooter ? Icons.moped_rounded : Icons.motorcycle_rounded, color: Colors.white38, size: 18),
          const SizedBox(width: 12),
          Text(bike.name, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredBikes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            const Text('No results found', style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _filteredBikes.length,
      separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05)),
      itemBuilder: (context, index) {
        final bike = _filteredBikes[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(bike.isScooter ? Icons.moped_rounded : Icons.motorcycle_rounded, color: Colors.white54),
          title: _buildHighlightedText(bike.name, _searchController.text),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white10, size: 14),
          onTap: () {
            // Logic to select bike
          },
        );
      },
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) return Text(text, style: const TextStyle(color: Colors.white));
    
    final matches = query.toLowerCase();
    final parts = text.split(RegExp(matches, caseSensitive: false));

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white70, fontSize: 16),
        children: [
          for (int i = 0; i < parts.length; i++) ...[
            TextSpan(text: parts[i]),
            if (i < parts.length - 1)
              TextSpan(
                text: text.substring(
                  parts.sublist(0, i + 1).join().length + (i * query.length),
                  parts.sublist(0, i + 1).join().length + (i * query.length) + query.length,
                ),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
          ],
        ],
      ),
    );
  }
}
