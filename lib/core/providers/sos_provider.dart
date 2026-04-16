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

  Future<void> _setupAudio() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setSource(AssetSource('audio/siren.mp3'));
  }

  Future<void> toggleSiren() async {
    if (_isSirenActive) {
      await _audioPlayer.stop();
    } else {
      try {
        await _audioPlayer.resume();
      } catch (e) {
        debugPrint("Error playing siren: $e");
      }
    }
    _isSirenActive = !_isSirenActive;
    notifyListeners();
  }

  Future<void> toggleStrobe() async {
    if (_isStrobeActive) {
      try {
        await TorchLight.disableTorch();
      } catch (e) {
        debugPrint("Error disabling torch: $e");
      }
    } else {
      try {
        await TorchLight.enableTorch();
      } catch (e) {
        debugPrint("Error enabling torch: $e");
      }
    }
    _isStrobeActive = !_isStrobeActive;
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
    // In a real app, this would trigger a countdown UI
    // For now, we'll activate safety features if enabled
    if (!_isSirenActive) toggleSiren();
    if (!_isStrobeActive) toggleStrobe();
    
    // notifyListeners could be used to show an overlay in the UI
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
    notifyListeners();
  }

  Future<void> removeContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    await _saveContacts();
    notifyListeners();
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = _contacts
        .map((contact) => json.encode(contact.toJson()))
        .toList();
    await prefs.setStringList('emergency_contacts', contactsJson);
  }
}
