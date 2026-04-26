import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveMapTile extends StatefulWidget {
  const LiveMapTile({super.key});

  @override
  State<LiveMapTile> createState() => _LiveMapTileState();
}

class _LiveMapTileState extends State<LiveMapTile> with TickerProviderStateMixin {
  late final _animatedMapController = AnimatedMapController(vsync: this);
  LocationData? _currentLocation;
  final Location _locationService = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  
  bool _isFollowing = true;
  bool _isSatellite = false;
  double _currentRotation = 0.0;

  final List<LatLng> _rideTrail = [];
  List<LatLng> _routePoints = [];
  LatLng? _destination;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 2000, 
      distanceFilter: 10,
    );

    _currentLocation = await _locationService.getLocation();
    if (mounted && _currentLocation != null) {
      final startPoint = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
      _rideTrail.add(startPoint);
      _animatedMapController.animateTo(dest: startPoint, zoom: 16.5);
    }

    _locationSubscription = _locationService.onLocationChanged.listen((LocationData currentLocation) {
      if (mounted) {
        setState(() {
          _currentLocation = currentLocation;
          if (currentLocation.latitude != null && currentLocation.longitude != null) {
            final point = LatLng(currentLocation.latitude!, currentLocation.longitude!);

            if (_rideTrail.isEmpty || _getDistance(point, _rideTrail.last) > 0.0001) {
              _rideTrail.add(point);
            }
          }
        });
        
        if (_isFollowing && currentLocation.latitude != null && currentLocation.longitude != null) {

          double heading = currentLocation.heading ?? 0;
          _animatedMapController.animateTo(
            dest: LatLng(currentLocation.latitude!, currentLocation.longitude!),
            rotation: -heading,
          );
        }
      }
    });
  }

  double _getDistance(LatLng p1, LatLng p2) {
    return math.sqrt(math.pow(p1.latitude - p2.latitude, 2) + math.pow(p1.longitude - p2.longitude, 2));
  }

  Future<void> _getRoute(LatLng destination) async {
    if (_currentLocation == null) return;
    
    final url = Uri.parse(
      'https:
      '${_currentLocation!.longitude},${_currentLocation!.latitude};'
      '${destination.longitude},${destination.latitude}?overview=full&geometries=geojson'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];
        setState(() {
          _routePoints = coordinates.map((c) => LatLng(c[1], c[0])).toList();
          _destination = destination;
          _isFollowing = true;
        });
      }
    } catch (e) {
      debugPrint('Routing error: $e');
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 3) return;
    
    final url = Uri.parse('https:
    try {

      final response = await http.get(url, headers: {'User-Agent': 'MotoCheck/1.0'});
      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _animatedMapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Container(
      height: 400, 
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _animatedMapController.mapController,
              options: MapOptions(
                initialCenter: const LatLng(20.5937, 78.9629),
                initialZoom: 15,
                minZoom: 3,
                maxZoom: 20,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture && _isFollowing) {
                    setState(() => _isFollowing = false);
                  }
                  setState(() => _currentRotation = position.rotation);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _isSatellite
                      ? 'https:
                      : (isDark 
                          ? 'https:
                          : 'https:
                  subdomains: _isSatellite ? const ['mt0', 'mt1', 'mt2', 'mt3'] : const ['a', 'b', 'c', 'd'],
                ),

                if (_routePoints.isNotEmpty)
                  PolylineLayer<Object>(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 6,
                        color: const Color(0xFF2196F3),
                      ),
                    ],
                  ),

                if (_rideTrail.isNotEmpty)
                  PolylineLayer<Object>(
                    polylines: [
                      Polyline(
                        points: _rideTrail,
                        strokeWidth: 3,
                        color: const Color(0xFF00A37B).withOpacity(0.5),
                      ),
                    ],
                  ),

                MarkerLayer(
                  markers: [
                    if (_destination != null)
                      Marker(
                        point: _destination!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 40),
                      ),
                    if (_currentLocation != null)
                      Marker(
                        point: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                        width: 70,
                        height: 70,
                        child: _buildRiderMarker(),
                      ),
                  ],
                ),
              ],
            ),

            _buildSearchBar(isDark, primaryColor),
            _buildTripHUD(),
            _buildSpeedometer(),
            _buildMapControls(isDark, primaryColor),
            _buildCompass(isDark, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color primaryColor) {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Column(
        children: [
          _GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () => _searchPlaces(val));
              },
              style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Where to, Rider?',
                hintStyle: TextStyle(color: primaryColor.withOpacity(0.3)),
                prefixIcon: Icon(Icons.search_rounded, color: primaryColor.withOpacity(0.5), size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _searchResults.map((place) => ListTile(
                  title: Text(place['display_name'], style: TextStyle(color: primaryColor, fontSize: 12), maxLines: 1),
                  onTap: () {
                    final lat = double.parse(place['lat']);
                    final lon = double.parse(place['lon']);
                    final dest = LatLng(lat, lon);
                    _getRoute(dest);
                    _animatedMapController.animateTo(dest: dest, zoom: 14);
                    setState(() {
                      _searchResults = [];
                      _searchController.text = place['display_name'];
                      FocusScope.of(context).unfocus();
                    });
                  },
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripHUD() {
    if (_currentLocation == null) return const SizedBox.shrink();
    return Positioned(
      top: 75,
      left: 12,
      child: _GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHUDSegment(Icons.straighten_rounded, '${(_rideTrail.length * 0.005).toStringAsFixed(1)}km'),
            const SizedBox(width: 10),
            _buildHUDSegment(Icons.timer_outlined, 'LIVE'),
          ],
        ),
      ),
    );
  }

  Widget _buildHUDSegment(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF00A37B)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSpeedometer() {
    if (_currentLocation == null) return const SizedBox.shrink();
    double speed = (_currentLocation!.speed ?? 0) * 3.6;
    
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF00A37B),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF00A37B).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(speed.toStringAsFixed(0), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, height: 0.9)),
            const Text('KM/H', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls(bool isDark, Color primaryColor) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        children: [
          _MapControlButton(
            icon: _isSatellite ? Icons.map_outlined : Icons.satellite_alt_rounded,
            onPressed: () => setState(() => _isSatellite = !_isSatellite),
            isDark: isDark,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 12),
          _MapControlButton(
            icon: _isFollowing ? Icons.my_location_rounded : Icons.location_searching_rounded,
            onPressed: () {
              setState(() => _isFollowing = true);
              if (_currentLocation != null) {
                _animatedMapController.animateTo(dest: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!), zoom: 16.5);
              }
            },
            isDark: isDark,
            primaryColor: primaryColor,
            isActive: _isFollowing,
          ),
        ],
      ),
    );
  }

  Widget _buildCompass(bool isDark, Color primaryColor) {
    return Positioned(
      top: 130,
      right: 16,
      child: GestureDetector(
        onTap: () => _animatedMapController.animateTo(rotation: 0),
        child: _GlassContainer(
          padding: const EdgeInsets.all(8),
          child: Transform.rotate(
            angle: -(_currentRotation * math.pi / 180),
            child: Column(
              children: [
                const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.red, size: 16),
                Text('N', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRiderMarker() {

    return Stack(
      alignment: Alignment.center,
      children: [
        _PulseCircle(color: const Color(0xFF00A37B)),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF00A37B),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
        ),
      ],
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _GlassContainer({required this.child, this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8)});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;
  final Color primaryColor;
  final bool isActive;

  const _MapControlButton({required this.icon, required this.onPressed, required this.isDark, required this.primaryColor, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF00A37B) : (isDark ? Colors.black : Colors.white).withOpacity(0.75),
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? Colors.transparent : primaryColor.withOpacity(0.1)),
            ),
            child: Icon(icon, color: isActive ? Colors.white : primaryColor, size: 22),
          ),
        ),
      ),
    );
  }
}

class _PulseCircle extends StatefulWidget {
  final Color color;
  const _PulseCircle({required this.color});

  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 80 * _controller.value,
          height: 80 * _controller.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(1 - _controller.value),
            border: Border.all(color: widget.color.withOpacity(0.5 * (1 - _controller.value)), width: 2),
          ),
        );
      },
    );
  }
}

