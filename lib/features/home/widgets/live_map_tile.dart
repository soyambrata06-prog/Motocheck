import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

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
      interval: 1000,
      distanceFilter: 1,
    );

    _currentLocation = await _locationService.getLocation();
    if (mounted) {
      setState(() {});
      if (_currentLocation != null) {
        _animatedMapController.animateTo(
          dest: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          zoom: 16.5,
        );
      }
    }

    _locationSubscription = _locationService.onLocationChanged.listen((LocationData currentLocation) {
      if (mounted) {
        setState(() {
          _currentLocation = currentLocation;
        });
        if (_isFollowing && currentLocation.latitude != null && currentLocation.longitude != null) {
          _animatedMapController.animateTo(
            dest: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 2,
        ),
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
                      ? 'https://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}'
                      : (isDark 
                          ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                          : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png'),
                  subdomains: _isSatellite ? const ['mt0', 'mt1', 'mt2', 'mt3'] : const ['a', 'b', 'c', 'd'],
                ),
                if (_currentLocation != null)
                  MarkerLayer(
                    markers: [
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
            
            // UI Overlays
            _buildGlassHeader(isDark, primaryColor),
            _buildSpeedometer(),
            _buildTripStats(isDark, primaryColor),
            _buildMapControls(isDark, primaryColor),
            _buildCompass(isDark, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassHeader(bool isDark, Color primaryColor) {
    return Positioned(
      top: 16,
      left: 16,
      child: _GlassContainer(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF00A37B),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'LIVE TRACKING',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedometer() {
    if (_currentLocation == null) return const SizedBox.shrink();
    double speed = (_currentLocation!.speed ?? 0) * 3.6; // m/s to km/h
    
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF00A37B),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00A37B).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              speed.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 0.9,
              ),
            ),
            const Text(
              'KM/H',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripStats(bool isDark, Color primaryColor) {
    if (_currentLocation == null) return const SizedBox.shrink();
    
    return Positioned(
      top: 16,
      right: 16,
      child: _GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildStatRow(Icons.height_rounded, '${_currentLocation!.altitude?.toStringAsFixed(0)}m', primaryColor),
            const SizedBox(height: 4),
            _buildStatRow(Icons.explore_outlined, '${_currentLocation!.heading?.toStringAsFixed(0)}°', primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
        ),
        const SizedBox(width: 4),
        Icon(icon, size: 14, color: color.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildMapControls(bool isDark, Color primaryColor) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                _animatedMapController.animateTo(
                  dest: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                  zoom: 16.5,
                );
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
      top: 80,
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
    double heading = _currentLocation?.heading ?? 0;
    return Transform.rotate(
      angle: (heading * math.pi) / 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _PulseCircle(color: const Color(0xFF00A37B)),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF00A37B),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.navigation_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _GlassContainer({
    required this.child, 
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            ),
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

  const _MapControlButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
    required this.primaryColor,
    this.isActive = false,
  });

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
              color: isActive 
                  ? const Color(0xFF00A37B) 
                  : (isDark ? Colors.black : Colors.white).withOpacity(0.75),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.transparent : primaryColor.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : primaryColor,
              size: 22,
            ),
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
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
          width: 70 * _controller.value,
          height: 70 * _controller.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(1 - _controller.value),
            border: Border.all(
              color: widget.color.withOpacity(0.5 * (1 - _controller.value)),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}
