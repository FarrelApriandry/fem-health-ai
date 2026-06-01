import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';

class FemHealthProvider extends ChangeNotifier {
  String _activeTab = 'home';
  bool _isOnboarded = false;
  bool _isLocked = true;
  String _selectedDate = '2023-10-14';

  late UserProfile _profile;
  late AppSettings _settings;
  late NotificationSettings _notifications;
  late Map<String, DailyLog> _dailyLogs;

  String get activeTab => _activeTab;
  bool get isOnboarded => _isOnboarded;
  bool get isLocked => _isLocked;
  String get selectedDate => _selectedDate;
  UserProfile get profile => _profile;
  AppSettings get settings => _settings;
  NotificationSettings get notifications => _notifications;
  Map<String, DailyLog> get dailyLogs => Map.unmodifiable(_dailyLogs);

  FemHealthProvider() {
    _profile = UserProfile();
    _settings = AppSettings();
    _notifications = NotificationSettings();
    _dailyLogs = {};
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboarded = prefs.getBool('is_onboarded') ?? false;

      final profileJson = prefs.getString('profile');
      if (profileJson != null) {
        _profile = UserProfile.fromJson(jsonDecode(profileJson));
      }

      final settingsJson = prefs.getString('settings');
      if (settingsJson != null) {
        _settings = AppSettings.fromJson(jsonDecode(settingsJson));
      }

      final notifJson = prefs.getString('notifications');
      if (notifJson != null) {
        _notifications = NotificationSettings.fromJson(jsonDecode(notifJson));
      }

      final logsJson = prefs.getString('daily_logs');
      if (logsJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(logsJson);
        _dailyLogs = decoded.map((k, v) => MapEntry(k, DailyLog.fromJson(v)));
      }

      _selectedDate = prefs.getString('selected_date') ?? '2023-10-14';
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from storage: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_onboarded', _isOnboarded);
      await prefs.setString('profile', jsonEncode(_profile.toJson()));
      await prefs.setString('settings', jsonEncode(_settings.toJson()));
      await prefs.setString('notifications', jsonEncode(_notifications.toJson()));
      await prefs.setString(
        'daily_logs',
        jsonEncode(_dailyLogs.map((k, v) => MapEntry(k, v.toJson()))),
      );
      await prefs.setString('selected_date', _selectedDate);
    } catch (e) {
      debugPrint('Error saving to storage: $e');
    }
  }

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void onUnlock() {
    _isLocked = false;
    notifyListeners();
  }

  void onOnboardingComplete(UserProfile newProfile) {
    _profile = newProfile;
    _isOnboarded = true;
    _isLocked = false;
    notifyListeners();
    _saveToStorage();
  }

  void resetWizard() {
    _profile = UserProfile();
    _settings = AppSettings(pinLockEnabled: false);
    _notifications = NotificationSettings();
    _dailyLogs = {};
    _isOnboarded = false;
    _isLocked = false;
    _activeTab = 'home';
    notifyListeners();
    _saveToStorage();
  }

  void setSelectedDate(String date) {
    _selectedDate = date;
    notifyListeners();
    _saveToStorage();
  }

  void updateProfile(UserProfile newProfile) {
    _profile = newProfile;
    notifyListeners();
    _saveToStorage();
  }

  void updateSettings(AppSettings appSettings, NotificationSettings notifSettings) {
    _settings = appSettings;
    _notifications = notifSettings;
    notifyListeners();
    _saveToStorage();
  }

  void saveSymptomLog(String date, String mood, List<String> symptoms, int severity, String notes) {
    final existing = _dailyLogs[date];
    if (existing != null) {
      _dailyLogs[date] = existing.copyWith(
        mood: mood,
        symptoms: symptoms,
        severity: severity,
        personalNotes: notes,
      );
    } else {
      _dailyLogs[date] = DailyLog(
        date: date,
        mood: mood,
        symptoms: symptoms,
        severity: severity,
        personalNotes: notes,
      );
    }
    notifyListeners();
    _saveToStorage();
  }

  void saveHydrationLog(String date, List<HydrationLog> logs, int goal) {
    final existing = _dailyLogs[date];
    if (existing != null) {
      _dailyLogs[date] = existing.copyWith(
        hydrationLogs: logs,
        hydrationGoal: goal,
      );
    } else {
      _dailyLogs[date] = DailyLog(
        date: date,
        hydrationLogs: logs,
        hydrationGoal: goal,
      );
    }
    notifyListeners();
    _saveToStorage();
  }

  void saveSleepLog(String date, SleepLog sleep) {
    final existing = _dailyLogs[date];
    if (existing != null) {
      _dailyLogs[date] = existing.copyWith(sleep: sleep);
    } else {
      _dailyLogs[date] = DailyLog(date: date, sleep: sleep);
    }
    notifyListeners();
    _saveToStorage();
  }

  DailyLog getLogForDate(String date) {
    return _dailyLogs[date] ?? DailyLog(date: date);
  }
}
