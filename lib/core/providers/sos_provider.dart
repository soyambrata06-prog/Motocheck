import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';

class SosProvider with ChangeNotifier {
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

  SosProvider() {
    _loadSettings();
    _loadContacts();
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
