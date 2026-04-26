import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _keyPrefix = 'notification_';

  final Map<String, bool> _settings = {
    'crashDetection': true,
    'sosNotifications': true,
    'illegalModAlerts': true,
    'documentReminders': true,
    'trafficRuleUpdates': true,
    'maintenanceReminders': true,
    'performanceTips': true,
    'suspiciousModAlerts': false,
    'quickVerifAlerts': false,
    'safetyTips': true,
    'generalUpdates': true,
  };

  NotificationProvider() {
    _loadSettings();
  }

  bool getSetting(String key) => _settings[key] ?? true;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    for (String key in _settings.keys) {
      _settings[key] = prefs.getBool('$_keyPrefix$key') ?? _settings[key]!;
    }
    notifyListeners();
  }

  Future<void> updateSetting(String key, bool value) async {
    _settings[key] = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$key', value);
  }
}

