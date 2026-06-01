import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart';

class FemHealthProvider extends ChangeNotifier {
  String _activeTab = 'home';
  bool _isOnboarded = false;
  bool _isLocked = true;
  String _selectedDate = _todayDate();

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

      _selectedDate = prefs.getString('selected_date') ?? _todayDate();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from storage: $e');
    }
  }

  static String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_onboarded', _isOnboarded);
      await prefs.setString('profile', jsonEncode(_profile.toJson()));
      await prefs.setString('settings', jsonEncode(_settings.toJson()));
      await prefs.setString(
        'notifications',
        jsonEncode(_notifications.toJson()),
      );
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

  void updateSettings(
    AppSettings appSettings,
    NotificationSettings notifSettings,
  ) {
    _settings = appSettings;
    _notifications = notifSettings;
    notifyListeners();
    _saveToStorage();
  }

  void saveSymptomLog(
    String date,
    String mood,
    List<String> symptoms,
    int severity,
    String notes,
  ) {
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

  /// Login user via Supabase Auth.
  /// Returns error message string if failed, or null on success.
  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final client = Supabase.instance.client;
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadProfileFromSupabase(response.user!.id);
        _isOnboarded = true;
        _isLocked = false;
        notifyListeners();
        await _saveToStorage();
        return null;
      }
      return 'Login failed. Please check your credentials and try again.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  /// Register new user via Supabase Auth (email + password only).
  /// Returns error message string if failed, or null on success.
  /// Does NOT upsert profile data - that's handled by updateProfileHealthData().
  Future<String?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final client = Supabase.instance.client;
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return null;
      }
      return 'Registration failed. Please try again.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  /// Update profile with health data and upsert to Supabase.
  /// Called after user completes ProfileSetupScreen.
  /// Returns error message string if failed, or null on success.
  Future<String?> updateProfileHealthData({
    required String name,
    required String fullName,
    required String dob,
    required double height,
    required double weight,
    required String lastPeriodStart,
    required int cycleLength,
    required int periodLength,
  }) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        return 'User not authenticated. Please log in again.';
      }

      await client.from('profiles').upsert({
        'id': userId,
        'email': client.auth.currentUser?.email,
        'name': name,
        'full_name': fullName,
        'dob': dob,
        'height': height,
        'weight': weight,
        'last_period_start': lastPeriodStart,
        'cycle_length': cycleLength,
        'period_length': periodLength,
      });

      _profile = UserProfile(
        name: name,
        fullName: fullName,
        email: _profile.email,
        dob: dob,
        height: height,
        weight: weight,
        lastPeriodStart: lastPeriodStart,
        cycleLength: cycleLength,
        periodLength: periodLength,
      );

      notifyListeners();
      await _saveToStorage();
      return null;
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  Future<void> _loadProfileFromSupabase(String userId) async {
    try {
      final client = Supabase.instance.client;
      final data = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return;

      _profile = UserProfile(
        name: data['name'] ?? '',
        fullName: data['full_name'] ?? '',
        email: data['email'] ?? '',
        dob: data['dob'] ?? '',
        height: (data['height'] ?? 0).toDouble(),
        weight: (data['weight'] ?? 0).toDouble(),
        lastPeriodStart: data['last_period_start'] ?? '',
        cycleLength: data['cycle_length'] ?? 0,
        periodLength: data['period_length'] ?? 0,
      );

      await _saveToStorage();
    } catch (e) {
      debugPrint('Error loading profile from Supabase: $e');
    }
  }
}
