import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/sos_provider.dart';
import '../../core/models/emergency_contact.dart';
import '../shared/widgets/skeleton_tile.dart';
import 'widgets/sos_button.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sosProvider = Provider.of<SosProvider>(context);

    return Scaffold(
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
                        onPressed: () => _showSettingsDialog(context, sosProvider),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Center(
                  child: SosButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Long press to trigger SOS')),
                      );
                    },
                    onLongPress: () {
                      _showSosConfirmation(context);
                    },
                  ),
                ),
                const SizedBox(height: 40),
                
                // Crash Detection & Location Sharing
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureToggle(
                        context, 
                        'Crash Detection', 
                        sosProvider.isCrashDetectionEnabled, 
                        const Color(0xFF00C853),
                        (v) => sosProvider.toggleCrashDetection(v),
                        isDark
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildFeatureToggle(
                        context, 
                        'Live Location', 
                        sosProvider.isSharingLocation, 
                        const Color(0xFF00C853),
                        (_) => sosProvider.toggleLocationSharing(),
                        isDark,
                        subtitle: sosProvider.isSharingLocation ? 'Sharing...' : 'Off'
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => _showAddContactDialog(context, sosProvider),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildContactsList(context, sosProvider, isDark),
                
                const SizedBox(height: 30),
                Text(
                  'Alert Tools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildToolCard(
                        context, 
                        'Siren', 
                        sosProvider.isSirenActive ? Icons.volume_off_rounded : Icons.volume_up_rounded, 
                        isDark, 
                        () => sosProvider.toggleSiren(),
                        isActive: sosProvider.isSirenActive,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildToolCard(
                        context, 
                        'Strobe', 
                        sosProvider.isStrobeActive ? Icons.flashlight_off_rounded : Icons.flashlight_on_rounded, 
                        isDark, 
                        () => sosProvider.toggleStrobe(),
                        isActive: sosProvider.isStrobeActive,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                Text(
                  'Nearby Help',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      _buildServiceCard(context, 'Hospitals', Icons.local_hospital_outlined, isDark),
                      const SizedBox(width: 15),
                      _buildServiceCard(context, 'Police', Icons.policy_outlined, isDark),
                      const SizedBox(width: 15),
                      _buildServiceCard(context, 'Ambulance', Icons.emergency_share_outlined, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureToggle(BuildContext context, String title, bool value, Color activeColor, Function(bool) onToggle, bool isDark, {String? subtitle}) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: value 
          ? activeColor.withOpacity(0.08) 
          : (isDark ? Colors.white : Colors.black).withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: value ? activeColor.withOpacity(0.2) : primaryColor.withOpacity(0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 24,
                width: 44,
                child: Switch.adaptive(
                  value: value,
                  onChanged: onToggle,
                  activeColor: activeColor,
                  activeTrackColor: activeColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: value ? activeColor : (isDark ? Colors.white24 : Colors.black.withOpacity(0.24)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subtitle ?? (value ? 'ACTIVE' : 'DISABLED'),
                  style: TextStyle(
                    fontSize: 11, 
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: value ? activeColor : (isDark ? Colors.white38 : Colors.black38)
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, bool isDark, VoidCallback onTap, {bool isActive = false}) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    final activeColor = const Color(0xFF00C853);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.1) : primaryColor.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive ? activeColor.withOpacity(0.3) : primaryColor.withOpacity(0.06), 
              width: 1.5
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? activeColor : primaryColor, size: 30),
              const SizedBox(height: 12),
              Text(
                title.toUpperCase(), 
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1,
                  color: isActive ? activeColor : primaryColor
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactsList(BuildContext context, SosProvider sosProvider, bool isDark) {
    if (sosProvider.isLoading) {
      return const Column(
        children: [
          SkeletonTile(height: 80),
          SizedBox(height: 12),
          SkeletonTile(height: 80),
        ],
      );
    }
    
    if (sosProvider.contacts.isEmpty) {
      return _buildEmptyState(isDark, 'No emergency contacts added.');
    }

    return Column(
      children: sosProvider.contacts.map((contact) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _buildContactTile(context, contact, isDark, sosProvider),
      )).toList(),
    );
  }

  Widget _buildContactTile(BuildContext context, EmergencyContact contact, bool isDark, SosProvider provider) {
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF00C853), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact.relationship.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.call_rounded, color: Color(0xFF00C853)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () => provider.removeContact(contact.id),
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

  Widget _buildServiceCard(BuildContext context, String title, IconData icon, bool isDark) {
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Container(
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: primaryColor.withOpacity(0.03),
        border: Border.all(color: primaryColor.withOpacity(0.06), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: primaryColor),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
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

  Widget _buildEmptyState(bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          message,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      ),
    );
  }

  void _showSosConfirmation(BuildContext context) {
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
              _triggerSosAction(context);
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
                    onPressed: () => Navigator.pop(context),
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

  void _triggerSosAction(BuildContext context) {
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
                        Text(
                          'SOS MESSAGE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: messageController,
                          maxLines: 3,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.all(16),
                          ),
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
        );
      },
    );
  }

  Widget _buildSettingsToggle(String title, bool value, Function(bool) onChanged, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF00C853),
        ),
      ],
    );
  }

  void _showAddContactDialog(BuildContext context, SosProvider provider) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add Contact',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildStyledField(nameController, 'Full Name', Icons.person_outline, isDark),
                        const SizedBox(height: 16),
                        _buildStyledField(phoneController, 'Phone Number', Icons.phone_outlined, isDark),
                        const SizedBox(height: 16),
                        _buildStyledField(relationController, 'Relationship', Icons.favorite_outline, isDark),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                                    provider.addContact(EmergencyContact(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      name: nameController.text,
                                      phoneNumber: phoneController.text,
                                      relationship: relationController.text,
                                    ));
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
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
        );
      },
    );
  }

  Widget _buildStyledField(TextEditingController controller, String label, IconData icon, bool isDark) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFF00C853), size: 20),
        filled: true,
        fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
