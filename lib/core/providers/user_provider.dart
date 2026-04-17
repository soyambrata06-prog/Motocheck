import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/bike_model.dart';

class UserProvider extends ChangeNotifier {
  String _displayName = 'Soyambrata Nayak';
  String _phoneNumber = '+91 98765 43210';
  String _email = 'soyamb@example.com';
  String _location = 'Bhubaneswar, Odisha';
  String _dob = '15 June 1998';
  String _profileImageUrl = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop';
  List<BikeModel> _savedBikes = [];

  String get displayName => _displayName;
  String get phoneNumber => _phoneNumber;
  String get email => _email;
  String get location => _location;
  String get dob => _dob;
  String get profileImageUrl => _profileImageUrl;
  List<BikeModel> get savedBikes => _savedBikes;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _displayName = prefs.getString('user_displayName') ?? _displayName;
    _phoneNumber = prefs.getString('user_phoneNumber') ?? _phoneNumber;
    _email = prefs.getString('user_email') ?? _email;
    _location = prefs.getString('user_location') ?? _location;
    _dob = prefs.getString('user_dob') ?? _dob;
    _profileImageUrl = prefs.getString('user_profileImageUrl') ?? _profileImageUrl;
    
    final savedBikesJson = prefs.getStringList('user_savedBikes') ?? [];
    _savedBikes = savedBikesJson
        .map((item) => BikeModel.fromJson(jsonDecode(item)))
        .toList();
        
    notifyListeners();
  }

  Future<void> saveBike(BikeModel bike) async {
    if (_savedBikes.any((b) => b.plateNumber == bike.plateNumber)) return;
    
    _savedBikes.add(bike);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'user_savedBikes',
      _savedBikes.map((b) => jsonEncode(b.toJson())).toList(),
    );
    notifyListeners();
  }

  Future<void> removeBike(String plateNumber) async {
    _savedBikes.removeWhere((b) => b.plateNumber == plateNumber);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'user_savedBikes',
      _savedBikes.map((b) => jsonEncode(b.toJson())).toList(),
    );
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? location,
    String? dob,
    String? imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (name != null) {
      _displayName = name;
      await prefs.setString('user_displayName', name);
    }
    if (phone != null) {
      _phoneNumber = phone;
      await prefs.setString('user_phoneNumber', phone);
    }
    if (email != null) {
      _email = email;
      await prefs.setString('user_email', email);
    }
    if (location != null) {
      _location = location;
      await prefs.setString('user_location', location);
    }
    if (dob != null) {
      _dob = dob;
      await prefs.setString('user_dob', dob);
    }
    if (imageUrl != null) {
      _profileImageUrl = imageUrl;
      await prefs.setString('user_profileImageUrl', imageUrl);
    }
    
    notifyListeners();
  }
}
