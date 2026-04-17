import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/sound_test_model.dart';

class SoundProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<SoundTestModel> _history = [];
  bool _isLoading = false;

  List<SoundTestModel> get history => _history;
  bool get isLoading => _isLoading;

  SoundProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadHistory();
    // Listen to auth changes to reload history when user signs in/out
    _auth.authStateChanges().listen((user) {
      loadHistory();
    });
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    // 1. Load from SharedPreferences first for instant UI
    final prefs = await SharedPreferences.getInstance();
    final localData = prefs.getStringList('sound_test_history') ?? [];
    _history = localData
        .map((item) => SoundTestModel.fromJson(jsonDecode(item)))
        .toList()
        .reversed
        .toList();
    notifyListeners();

    // 2. Sync with Firebase if user is logged in
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot = await _db
            .collection('users')
            .doc(user.uid)
            .collection('sound_tests')
            .orderBy('timestamp', descending: true)
            .get();

        final cloudHistory = snapshot.docs
            .map((doc) => SoundTestModel.fromJson(doc.data()))
            .toList();

        // Merge and migrate local data to cloud if needed
        if (localData.isNotEmpty) {
          await _migrateLocalToCloud(user.uid, _history);
          await prefs.remove('sound_test_history');
        }

        _history = cloudHistory;
      } catch (e) {
        debugPrint('Error syncing sound history: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _migrateLocalToCloud(String userId, List<SoundTestModel> localTests) async {
    final batch = _db.batch();
    for (var test in localTests) {
      final docRef = _db.collection('users').doc(userId).collection('sound_tests').doc(test.id);
      batch.set(docRef, test.toJson());
    }
    await batch.commit();
  }

  Future<void> saveTest(SoundTestModel test) async {
    _history.insert(0, test);
    notifyListeners();

    final user = _auth.currentUser;
    if (user != null) {
      // Save to Firebase
      try {
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('sound_tests')
            .doc(test.id)
            .set(test.toJson());
      } catch (e) {
        debugPrint('Error saving test to Firebase: $e');
        // Fallback to local if Firebase fails?
        await _saveLocally(test);
      }
    } else {
      // Save only locally if not logged in
      await _saveLocally(test);
    }
  }

  Future<void> _saveLocally(SoundTestModel test) async {
    final prefs = await SharedPreferences.getInstance();
    final localData = prefs.getStringList('sound_test_history') ?? [];
    localData.add(jsonEncode(test.toJson()));
    await prefs.setStringList('sound_test_history', localData);
  }

  Future<void> deleteTest(String testId) async {
    _history.removeWhere((t) => t.id == testId);
    notifyListeners();

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('sound_tests')
            .doc(testId)
            .delete();
      } catch (e) {
        debugPrint('Error deleting test from Firebase: $e');
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getStringList('sound_test_history') ?? [];
      localData.removeWhere((item) {
        final test = SoundTestModel.fromJson(jsonDecode(item));
        return test.id == testId;
      });
      await prefs.setStringList('sound_test_history', localData);
    }
  }
}
