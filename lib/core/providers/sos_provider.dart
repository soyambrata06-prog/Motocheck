import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:torch_light/torch_light.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/emergency_contact.dart';

class SosProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSirenActive = false;
  bool _isStrobeActive = false;
  
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;
  bool _isCrashDetectionEnabled = false;
  bool _isAutoCallEnabled = true;
  double _crashSensitivity = 0.5;
  String _sosMessage = "I need help! This is an emergency. My location is: ";
  bool _isSharingLocation = false;
  DateTime? _lastLocationShared;

  // Crash detection state
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  static const double _gravity = 9.81;
  static const int _cooldownMs = 5000;
  DateTime? _lastDetectionTime;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  List<EmergencyContact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  bool get isCrashDetectionEnabled => _isCrashDetectionEnabled;
  bool get isAutoCallEnabled => _isAutoCallEnabled;
  double get crashSensitivity => _crashSensitivity;
  String get sosMessage => _sosMessage;
  bool get isSharingLocation => _isSharingLocation;
  DateTime? get lastLocationShared => _lastLocationShared;
  bool get isSirenActive => _isSirenActive;
  bool get isStrobeActive => _isStrobeActive;

  SosProvider() {
    _loadSettings().then((_) {
      if (_isCrashDetectionEnabled) {
        _startCrashDetection();
      }
    });
    _loadContacts();
    _setupAudio();
  }

  bool _isSosActive = false;

  bool get isSosActive => _isSosActive;

  Future<void> triggerSos() async {
    if (_isSosActive) return;
    _isSosActive = true;
    
    // Enable all security controls when SOS is triggered
    await _setSiren(true);
    await _setStrobe(true);
    if (!_isSharingLocation) toggleLocationSharing();
    if (!_isCrashDetectionEnabled) await toggleCrashDetection(true);
    
    notifyListeners();
  }

  Future<void> stopSos() async {
    if (!_isSosActive) return;
    _isSosActive = false;
    
    // Disable all security controls
    await _setSiren(false);
    await _setStrobe(false);
    if (_isSharingLocation) toggleLocationSharing();
    // We might want to keep crash detection enabled if it was enabled before?
    // But stopSos usually means "I'm safe now, stop everything triggered by SOS"
    
    notifyListeners();
  }

  Future<void> _setupAudio() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setSource(AssetSource('audio/siren.mp3'));
    } catch (e) {
      debugPrint("Error setting up audio: $e");
    }
  }

  Future<void> _setSiren(bool active) async {
    if (_isSirenActive == active) return;
    try {
      if (active) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.stop();
      }
      _isSirenActive = active;
    } catch (e) {
      debugPrint("Error setting siren to $active: $e");
      // Force state to false if it fails to start
      if (active) _isSirenActive = false;
    }
  }

  Future<void> toggleSiren() async {
    await _setSiren(!_isSirenActive);
    notifyListeners();
  }

  Future<void> _setStrobe(bool active) async {
    if (_isStrobeActive == active) return;
    try {
      if (active) {
        final available = await TorchLight.isTorchAvailable();
        if (available) {
          await TorchLight.enableTorch();
          _isStrobeActive = true;
        }
      } else {
        await TorchLight.disableTorch();
        _isStrobeActive = false;
      }
    } catch (e) {
      debugPrint("Error setting strobe to $active: $e");
      // Ensure state is false if hardware fails
      _isStrobeActive = false;
    }
  }

  Future<void> toggleStrobe() async {
    await _setStrobe(!_isStrobeActive);
    notifyListeners();
  }


  void _startCrashDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      _processAccelerometerData(event);
    });
  }

  void _stopCrashDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  void _processAccelerometerData(AccelerometerEvent event) {
    // Calculate total G-force
    double gForce = sqrt(event.x * event.x + event.y * event.y + event.z * event.z) / _gravity;

    // Sensitivity logic: 
    // 0.0 sensitivity = 8G threshold (very hard to trigger)
    // 1.0 sensitivity = 3G threshold (easier to trigger)
    double threshold = 8.0 - (_crashSensitivity * 5.0);

    if (gForce > threshold) {
      final now = DateTime.now();
      if (_lastDetectionTime == null || now.difference(_lastDetectionTime!).inMilliseconds > _cooldownMs) {
        _lastDetectionTime = now;
        _onCrashDetected(gForce);
      }
    }
  }

  void _onCrashDetected(double intensity) {
    debugPrint("CRASH DETECTED! Intensity: $intensity G");
    
    // Auto-trigger security features on crash
    _setSiren(true);
    _setStrobe(true);
    
    if (!_isSharingLocation) {
      toggleLocationSharing();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _stopCrashDetection();
    if (_isStrobeActive) {
      TorchLight.disableTorch();
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isCrashDetectionEnabled = prefs.getBool('crash_detection') ?? false;
    _isAutoCallEnabled = prefs.getBool('auto_call') ?? true;
    _crashSensitivity = prefs.getDouble('crash_sensitivity') ?? 0.5;
    _sosMessage = prefs.getString('sos_message') ?? "I need help! This is an emergency. My location is: ";
    notifyListeners();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getStringList('emergency_contacts') ?? [];
    _contacts = contactsJson
        .map((item) => EmergencyContact.fromJson(json.decode(item)))
        .toList();

    // Add test contacts if list is empty
    if (_contacts.isEmpty) {
      final testContacts = [
        EmergencyContact(id: '1', name: 'John Doe', phoneNumber: '+91 98765 43210', relationship: 'Father'),
        EmergencyContact(id: '2', name: 'Jane Smith', phoneNumber: '+91 87654 32109', relationship: 'Mother'),
        EmergencyContact(id: '3', name: 'Mike Ross', phoneNumber: '+91 76543 21098', relationship: 'Brother'),
        EmergencyContact(id: '4', name: 'Rachel Zane', phoneNumber: '+91 65432 10987', relationship: 'Sister'),
        EmergencyContact(id: '5', name: 'Harvey Specter', phoneNumber: '+91 54321 09876', relationship: 'Friend'),
        EmergencyContact(id: '6', name: 'Donna Paulsen', phoneNumber: '+91 43210 98765', relationship: 'Partner'),
        EmergencyContact(id: '7', name: 'Louis Litt', phoneNumber: '+91 32109 87654', relationship: 'Colleague'),
        EmergencyContact(id: '8', name: 'Jessica Pearson', phoneNumber: '+91 21098 76543', relationship: 'Mentor'),
        EmergencyContact(id: '9', name: 'Robert Zane', phoneNumber: '+91 10987 65432', relationship: 'Guardian'),
        EmergencyContact(id: '10', name: 'Katrina Bennett', phoneNumber: '+91 01234 56789', relationship: 'Doctor'),
      ];
      _contacts.addAll(testContacts);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleCrashDetection(bool value) async {
    _isCrashDetectionEnabled = value;
    if (_isCrashDetectionEnabled) {
      _startCrashDetection();
    } else {
      _stopCrashDetection();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('crash_detection', value);
    notifyListeners();
  }

  Future<void> toggleAutoCall(bool value) async {
    _isAutoCallEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_call', value);
    notifyListeners();
  }

  Future<void> updateCrashSensitivity(double value) async {
    _crashSensitivity = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('crash_sensitivity', value);
    notifyListeners();
  }

  Future<void> updateSosMessage(String message) async {
    _sosMessage = message;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sos_message', message);
    notifyListeners();
  }

  void toggleLocationSharing() {
    _isSharingLocation = !_isSharingLocation;
    if (_isSharingLocation) {
      _lastLocationShared = DateTime.now();
    }
    notifyListeners();
  }

  Future<void> addContact(EmergencyContact contact) async {
    _contacts.add(contact);
    await _saveContacts();
    listKey.currentState?.insertItem(_contacts.length - 1);
    notifyListeners();
  }

  Future<void> updateContact(EmergencyContact contact) async {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = contact;
      await _saveContacts();
      notifyListeners();
    }
  }

  Future<void> removeContactAt(int index, Widget Function(EmergencyContact contact, Animation<double> animation) removedItemBuilder) async {
    if (index >= 0 && index < _contacts.length) {
      final removedContact = _contacts[index];
      
      listKey.currentState?.removeItem(
        index,
        (context, animation) => removedItemBuilder(removedContact, animation),
        duration: const Duration(milliseconds: 300),
      );
      
      _contacts.removeAt(index);
      await _saveContacts();
      notifyListeners();
    }
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = _contacts
        .map((contact) => json.encode(contact.toJson()))
        .toList();
    await prefs.setStringList('emergency_contacts', contactsJson);
  }
}
