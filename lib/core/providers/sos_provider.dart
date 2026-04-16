import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:torch_light/torch_light.dart';
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
    _loadSettings();
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
        // Handle case where file might be missing or other audio errors
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

  @override
  void dispose() {
    _audioPlayer.dispose();
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
