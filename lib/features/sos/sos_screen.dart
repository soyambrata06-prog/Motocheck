import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/sos_provider.dart';
import '../../core/models/emergency_contact.dart';
import 'widgets/sos_button.dart';
import '../shared/widgets/skeleton_tile.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length < 4) {
      return const TextEditingValue(
        text: '+91 ',
        selection: TextSelection.collapsed(offset: 4),
      );
    }
    
    final text = newValue.text.substring(4).replaceAll(RegExp(r'\D'), '');
    String formatted = '+91 ';
    for (int i = 0; i < text.length && i < 10; i++) {
      if (i == 5) formatted += ' ';
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class EmojiFilter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1F1E6}-\u{1F1FF}]', unicode: true), '');
    return newValue.copyWith(text: filtered, selection: TextSelection.collapsed(offset: filtered.length));
  }
}

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sosProvider = Provider.of<SosProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: RepaintBoundary(
        child: Stack(
          children: [
            // Ambient background glows for glass effect depth
            if (isDark) ...[
              Positioned(
                top: -150,
                right: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                top: 200,
                left: -150,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.10),
                  ),
                ),
              ),
            ],
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SECURITY HUB',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SECURE',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.settings_rounded, color: isDark ? Colors.white : Colors.black),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _showSettingsDialog(context, sosProvider);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InteractiveTile(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Long press to trigger SOS')),
                        );
                      },
                      onLongPress: () {
                        HapticFeedback.heavyImpact();
                        _showSosConfirmation(context, sosProvider);
                      },
                      borderRadius: BorderRadius.circular(28),
                      splashColor: Colors.red.withOpacity(0.08),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: isDark ? 15 : 0, sigmaY: isDark ? 15 : 0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                SosButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Long press to trigger SOS')),
                                    );
                                  },
                                  onLongPress: () {
                                    HapticFeedback.heavyImpact();
                                    _showSosConfirmation(context, sosProvider);
                                  },
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'PRESS AND HOLD FOR EMERGENCY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: isDark ? Colors.white38 : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Security Controls',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.4,
                      children: [
                        _buildFeatureToggle(
                          context, 
                          'Crash Detection', 
                          sosProvider.isCrashDetectionEnabled, 
                          const Color(0xFFF04770),
                          (v) => sosProvider.toggleCrashDetection(v),
                          isDark,
                          icon: Icons.sensors_rounded,
                        ),
                        _buildFeatureToggle(
                          context, 
                          'Live Location', 
                          sosProvider.isSharingLocation, 
                          const Color(0xFFF78C6A),
                          (_) => sosProvider.toggleLocationSharing(),
                          isDark,
                          icon: Icons.location_on_rounded,
                          subtitle: sosProvider.isSharingLocation ? 'Sharing' : null
                        ),
                        _buildToolCard(
                          context, 
                          'Siren', 
                          sosProvider.isSirenActive ? Icons.volume_off_rounded : Icons.volume_up_rounded, 
                          isDark, 
                          () => sosProvider.toggleSiren(),
                          isActive: sosProvider.isSirenActive,
                          activeColor: const Color(0xFFFFD167),
                        ),
                        _buildToolCard(
                          context, 
                          'Strobe', 
                          sosProvider.isStrobeActive ? Icons.flashlight_off_rounded : Icons.flashlight_on_rounded, 
                          isDark, 
                          () => sosProvider.toggleStrobe(),
                          isActive: sosProvider.isStrobeActive,
                          activeColor: const Color(0xFF06D7A0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showAddContactDialog(context, sosProvider);
                          },
                          icon: Icon(Icons.add, size: 18, color: isDark ? Colors.white : Colors.black),
                          label: Text(
                            'ADD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildContactsList(context, sosProvider, isDark),
                    const SizedBox(height: 16),
                    Text(
                      'Nearby Help',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildServiceCard(context, 'Hospitals', Icons.local_hospital_rounded, isDark, 'hospitals'),
                        const SizedBox(width: 8),
                        _buildServiceCard(context, 'Police', Icons.policy_rounded, isDark, 'police station'),
                        const SizedBox(width: 8),
                        _buildServiceCard(context, 'Fire Station', Icons.local_fire_department_rounded, isDark, 'fire station'),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureToggle(BuildContext context, String title, bool value, Color activeColor, Function(bool) onToggle, bool isDark, {String? subtitle, IconData? icon}) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return _InteractiveTile(
      onTap: () => onToggle(!value),
      borderRadius: BorderRadius.circular(24),
      splashColor: activeColor.withOpacity(0.1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isDark ? 15 : 0, sigmaY: isDark ? 15 : 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: isDark 
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (value ? activeColor : Colors.white).withOpacity(0.15),
                      (value ? activeColor : Colors.white).withOpacity(0.04),
                    ],
                  )
                : null,
              color: !isDark 
                ? (value ? activeColor.withOpacity(0.08) : Colors.black.withOpacity(0.03))
                : null,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark 
                  ? (value ? activeColor.withOpacity(0.4) : Colors.white.withOpacity(0.12))
                  : (value ? activeColor.withOpacity(0.2) : Colors.black.withOpacity(0.05)),
                width: 1
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon ?? Icons.settings_rounded, color: value ? activeColor : (isDark ? Colors.white38 : Colors.black38), size: 22),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle ?? (value ? 'ACTIVE' : 'OFF'),
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: value ? activeColor : (isDark ? Colors.white24 : Colors.black26)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, bool isDark, VoidCallback onTap, {bool isActive = false, Color activeColor = const Color(0xFF00C853)}) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return _InteractiveTile(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      splashColor: (isActive ? activeColor : primaryColor).withOpacity(0.1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isDark ? 15 : 0, sigmaY: isDark ? 15 : 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: isDark 
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isActive ? activeColor : Colors.white).withOpacity(0.15),
                      (isActive ? activeColor : Colors.white).withOpacity(0.04),
                    ],
                  )
                : null,
              color: !isDark 
                ? (isActive ? activeColor.withOpacity(0.08) : Colors.black.withOpacity(0.03))
                : null,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark 
                  ? (isActive ? activeColor.withOpacity(0.4) : Colors.white.withOpacity(0.12))
                  : (isActive ? activeColor.withOpacity(0.2) : Colors.black.withOpacity(0.05)), 
                width: 1
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isActive ? activeColor : (isDark ? Colors.white38 : Colors.black38), size: 22),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800, 
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isActive ? 'RUNNING' : 'STANDBY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isActive ? activeColor : (isDark ? Colors.white24 : Colors.black26)
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactsList(BuildContext context, SosProvider sosProvider, bool isDark) {
    if (sosProvider.isLoading) {
      return Column(
        children: [
          const SkeletonTile(height: 80),
          const SizedBox(height: 10),
          const SkeletonTile(height: 80),
        ],
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: sosProvider.contacts.isEmpty
            ? Padding(
                key: const ValueKey('empty'),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded, color: (isDark ? Colors.white : Colors.black).withOpacity(0.1), size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'No emergency contacts added',
                        style: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.2), fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            : AnimatedList(
                key: sosProvider.listKey,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: sosProvider.contacts.length,
                itemBuilder: (context, index, animation) {
                  if (index >= sosProvider.contacts.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildContactTile(context, sosProvider.contacts[index], isDark, sosProvider, animation: animation),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, EmergencyContact contact, bool isDark, SosProvider provider, {Animation<double>? animation}) {
    Widget tile = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isDark ? 10 : 0, sigmaY: isDark ? 10 : 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            contact.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: 14, 
                              color: isDark ? Colors.white : Colors.black, 
                              height: 1.2
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          contact.relationship.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.w800, 
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                            letterSpacing: 0.4
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.phoneNumber,
                      style: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.4), fontWeight: FontWeight.w700, fontSize: 12, height: 1.2),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.edit_outlined, color: (isDark ? Colors.white : Colors.black).withOpacity(0.3), size: 18),
                onPressed: () => _showAddContactDialog(context, provider, contact: contact),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.call_rounded, color: Color(0xFF00C853), size: 20),
                onPressed: () => _makePhoneCall(contact.phoneNumber),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red[400]?.withOpacity(0.8), size: 20),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final index = provider.contacts.indexOf(contact);
                  if (index != -1) {
                    provider.removeContactAt(index, (c, anim) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildContactTile(context, c, isDark, provider, animation: anim),
                    ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (animation != null) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1.0,
            child: tile,
          ),
        ),
      );
    }
    return tile;
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon, bool isDark, String query) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: _InteractiveTile(
          onTap: () => _launchMaps(query),
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor.withOpacity(0.05),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: isDark ? 10 : 0, sigmaY: isDark ? 10 : 0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: isDark 
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.02),
                        ],
                      )
                    : null,
                  color: !isDark ? Colors.black.withOpacity(0.02) : null,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.04),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: primaryColor.withOpacity(0.5), size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        color: primaryColor.withOpacity(0.8),
                        height: 1.1,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NEARBY',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        color: primaryColor.withOpacity(0.3),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchMaps(String query) async {
    final queryEncoded = Uri.encodeComponent('$query near me');
    
    // Try Google Maps app first via geo intent
    final googleMapsUrl = 'geo:0,0?q=$queryEncoded';
    final httpsUrl = 'https://www.google.com/maps/search/?api=1&query=$queryEncoded';
    
    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } else if (await canLaunchUrl(Uri.parse(httpsUrl))) {
        await launchUrl(
          Uri.parse(httpsUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  void _showSosConfirmation(BuildContext context, SosProvider sosProvider) {
    int countdown = 5;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Future.delayed(const Duration(seconds: 1), () {
            if (countdown > 0 && context.mounted) {
              setModalState(() => countdown--);
            } else if (countdown == 0 && context.mounted) {
              Navigator.pop(context);
              _triggerSosAction(context, sosProvider);
            }
          });

          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$countdown',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.red),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Triggering Security Alert',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This will send your location to all emergency contacts and notify nearby authorities.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    child: const Text('CANCEL (I\'M SAFE)', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _triggerSosAction(BuildContext context, SosProvider provider) {
    provider.triggerSos();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Security Alert Sent! Contacts notified.'),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, SosProvider provider) {
    final messageController = TextEditingController(text: provider.sosMessage);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900]!.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safety Settings',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildStyledField(
                            messageController, 
                            'SOS MESSAGE', 
                            Icons.message_outlined, 
                            isDark, 
                            maxLines: 3,
                            formatters: [EmojiFilter()] // Emojis removed from message
                          ),
                          const SizedBox(height: 20),
                          _buildSettingsToggle('Auto-Call Contacts', provider.isAutoCallEnabled, provider.toggleAutoCall, isDark),
                          const SizedBox(height: 16),
                          Text(
                            'CRASH SENSITIVITY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF00C853),
                              inactiveTrackColor: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                              thumbColor: const Color(0xFF00C853),
                              overlayColor: const Color(0xFF00C853).withOpacity(0.2),
                            ),
                            child: Slider(
                              value: provider.crashSensitivity,
                              onChanged: (v) => provider.updateCrashSensitivity(v),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? Colors.white : Colors.black,
                                    foregroundColor: isDark ? Colors.black : Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    provider.updateSosMessage(messageController.text);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w900)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsToggle(String title, bool value, Function(bool) onChanged, bool isDark) {
    return _InteractiveTile(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch.adaptive(
                value: value,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  onChanged(v);
                },
                activeColor: const Color(0xFF00C853),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showAddContactDialog(BuildContext context, SosProvider provider, {EmergencyContact? contact}) {
    final nameController = TextEditingController(text: contact?.name);
    final phoneController = TextEditingController(
      text: contact?.phoneNumber ?? '+91 ',
    );
    final relationController = TextEditingController(text: contact?.relationship);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddContactDialogContent(
        contact: contact,
        provider: provider,
        isDark: isDark,
        nameController: nameController,
        phoneController: phoneController,
        relationController: relationController,
      ),
    );
  }

  Widget _buildStyledField(TextEditingController controller, String label, IconData icon, bool isDark, {TextInputType? keyboardType, List<TextInputFormatter>? formatters, String? errorText, int maxLines = 1}) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          maxLines: maxLines,
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: primaryColor.withOpacity(0.3),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(icon, color: primaryColor, size: 22),
            filled: true,
            fillColor: primaryColor.withOpacity(0.04),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.05), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: errorText != null ? Colors.redAccent : primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 14),
                const SizedBox(width: 6),
                Text(
                  errorText,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AddContactDialogContent extends StatefulWidget {
  final EmergencyContact? contact;
  final SosProvider provider;
  final bool isDark;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController relationController;

  const _AddContactDialogContent({
    this.contact,
    required this.provider,
    required this.isDark,
    required this.nameController,
    required this.phoneController,
    required this.relationController,
  });

  @override
  State<_AddContactDialogContent> createState() => _AddContactDialogContentState();
}

class _AddContactDialogContentState extends State<_AddContactDialogContent> {
  String? nameError;
  String? phoneError;
  String? relationError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: (widget.isDark ? Colors.white : Colors.black).withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: (widget.isDark ? Colors.white : Colors.black).withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.contact == null ? 'Add Emergency Contact' : 'Edit Contact',
              style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900,
                color: widget.isDark ? Colors.white : Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            const SosScreen()._buildStyledField(
              widget.nameController, 
              'Full Name', 
              Icons.person_outline, 
              widget.isDark, 
              errorText: nameError, 
            ),
            const SizedBox(height: 16),
            const SosScreen()._buildStyledField(
              widget.phoneController, 
              'Phone Number', 
              Icons.phone_outlined, 
              widget.isDark, 
              keyboardType: TextInputType.phone,
              formatters: [PhoneNumberFormatter()],
              errorText: phoneError,
            ),
            const SizedBox(height: 16),
            const SosScreen()._buildStyledField(
              widget.relationController, 
              'Relationship', 
              Icons.favorite_outline, 
              widget.isDark, 
              errorText: relationError,
              formatters: [FilteringTextInputFormatter.deny(RegExp(r'[\u0080-\uffff]'))],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Text('CANCEL', style: TextStyle(color: (widget.isDark ? Colors.white : Colors.black).withOpacity(0.5), fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isDark ? Colors.white : Colors.black,
                      foregroundColor: widget.isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      final name = widget.nameController.text.trim();
                      final phone = widget.phoneController.text.trim();
                      final relation = widget.relationController.text.trim();

                      setState(() {
                        nameError = name.isEmpty ? 'Name is required' : null;
                        phoneError = phone.length < 14 ? 'Valid phone is required' : null;
                        
                        if (relation.isEmpty) {
                          relationError = 'Relationship is required';
                        } else if (RegExp(r'[\u0080-\uffff]').hasMatch(relation)) {
                          relationError = 'Emojis are not allowed in Relationship';
                        } else {
                          relationError = null;
                        }
                      });

                      if (nameError != null || phoneError != null || relationError != null) return;

                      final newContact = EmergencyContact(
                        id: widget.contact?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        phoneNumber: phone,
                        relationship: relation,
                      );
                      
                      if (widget.contact == null) {
                        widget.provider.addContact(newContact);
                      } else {
                        widget.provider.updateContact(newContact);
                      }
                      Navigator.pop(context);
                    },
                    child: Text(widget.contact == null ? 'ADD CONTACT' : 'SAVE CHANGES', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;
  final Color splashColor;

  const _InteractiveTile({
    required this.child,
    required this.onTap,
    this.onLongPress,
    required this.borderRadius,
    required this.splashColor,
  });

  @override
  State<_InteractiveTile> createState() => _InteractiveTileState();
}

class _InteractiveTileState extends State<_InteractiveTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onHighlightChanged: (v) => setState(() => _isPressed = v),
          borderRadius: widget.borderRadius,
          splashFactory: InkRipple.splashFactory,
          splashColor: widget.splashColor,
          highlightColor: Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}
