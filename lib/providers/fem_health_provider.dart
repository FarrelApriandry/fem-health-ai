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

  // ─── Partner-related state ───────────────────────────────────────────────
  List<PartnerConnection> _pendingRequests = [];
  Map<String, String> _pendingRequestSenders = {}; // connectionId → sender name
  PartnerConnection? _activeConnection;
  PartnerLogBundle? _partnerLogs;
  bool _isFetchingPartnerLogs = false;

  // ─── Existing Getters ────────────────────────────────────────────────────
  String get activeTab => _activeTab;
  bool get isOnboarded => _isOnboarded;
  bool get isLocked => _isLocked;
  String get selectedDate => _selectedDate;
  UserProfile get profile => _profile;
  AppSettings get settings => _settings;
  NotificationSettings get notifications => _notifications;
  Map<String, DailyLog> get dailyLogs => Map.unmodifiable(_dailyLogs);

  // ─── New Getters ─────────────────────────────────────────────────────────
  List<PartnerConnection> get pendingRequests =>
      List.unmodifiable(_pendingRequests);
  Map<String, String> get pendingRequestSenders =>
      Map.unmodifiable(_pendingRequestSenders);
  PartnerConnection? get activeConnection => _activeConnection;
  PartnerLogBundle? get partnerLogs => _partnerLogs;
  bool get isFetchingPartnerLogs => _isFetchingPartnerLogs;

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
    _pendingRequests = [];
    _activeConnection = null;
    _partnerLogs = null;
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
        await _loadActiveConnection();
        await checkPendingRequests();
        await fetchPartnerLogs();
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
    String role = 'utama',
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
        'role': role,
      });

      // ── Re-fetch profile to capture auto-generated partner_code ──
      await _loadProfileFromSupabase(userId);

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
        partnerCode: data['partner_code'] ?? '',
        role: data['role'] ?? 'utama',
      );

      await _saveToStorage();
    } catch (e) {
      debugPrint('Error loading profile from Supabase: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  PARTNER FEATURES
  // ═════════════════════════════════════════════════════════════════════════

  /// 1. Send a partner request by target partner_code.
  ///    Looks up the receiver_id from profiles, then inserts into
  ///    partner_connections with status 'pending'.
  Future<String?> sendPartnerRequest(String targetCode) async {
    try {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;

      if (currentUserId == null) {
        return 'You must be logged in to send a partner request.';
      }

      if (targetCode.trim().isEmpty) {
        return 'Partner code cannot be empty.';
      }

      if (targetCode.trim() == _profile.partnerCode) {
        return 'You cannot send a partner request to yourself.';
      }

      // ── Find receiver by partner_code ──
      final receiverData = await client
          .from('profiles')
          .select('id, name, full_name')
          .eq('partner_code', targetCode.trim())
          .maybeSingle();

      if (receiverData == null) {
        return 'No user found with partner code "$targetCode".';
      }

      final receiverId = receiverData['id'] as String;

      // ── Check if connection already exists ──
      final existingConnection = await client
          .from('partner_connections')
          .select()
          .or(
            'and(requester_id.eq.$currentUserId,receiver_id.eq.$receiverId),'
            'and(requester_id.eq.$receiverId,receiver_id.eq.$currentUserId)',
          )
          .maybeSingle();

      if (existingConnection != null) {
        final status = existingConnection['status'] as String;
        if (status == 'accepted') {
          return 'You are already connected with this user.';
        } else if (status == 'pending') {
          return 'A pending request already exists with this user.';
        } else if (status == 'rejected') {
          return 'Your previous request was rejected. Please wait for the user to send a new request.';
        }
      }

      // ── Insert new connection ──
      await client.from('partner_connections').insert({
        'requester_id': currentUserId,
        'receiver_id': receiverId,
        'status': 'pending',
      });

      debugPrint('Partner request sent to user: $receiverId');
      return null;
    } catch (e) {
      debugPrint('Error sending partner request: $e');
      return 'Failed to send partner request: $e';
    }
  }

  /// 2. Check for pending incoming partner requests.
  ///    Uses periodic/manual fetch (Opsi B) — no realtime stream.
  Future<void> checkPendingRequests() async {
    try {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;

      if (currentUserId == null) return;

      final data = await client
          .from('partner_connections')
          .select()
          .eq('receiver_id', currentUserId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      _pendingRequests = (data as List)
          .map((row) => PartnerConnection.fromJson(row))
          .toList();

      // ── Fetch sender names for each pending request ──
      _pendingRequestSenders = {};
      for (final req in _pendingRequests) {
        final senderProfile = await client
            .from('profiles')
            .select('name, full_name')
            .eq('id', req.requesterId)
            .maybeSingle();

        if (senderProfile != null) {
          final name =
              senderProfile['full_name'] ?? senderProfile['name'] ?? 'Unknown';
          _pendingRequestSenders[req.id] = name;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error checking pending requests: $e');
    }
  }

  /// 3. Accept a pending partner request by connection ID.
  ///    Updates the status to 'accepted' and loads the active connection.
  Future<String?> acceptPartnerRequest(String connectionId) async {
    try {
      final client = Supabase.instance.client;

      await client
          .from('partner_connections')
          .update({'status': 'accepted'})
          .eq('id', connectionId);

      await _loadActiveConnection();

      // Remove the accepted request from pending list
      _pendingRequests.removeWhere((r) => r.id == connectionId);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error accepting partner request: $e');
      return 'Failed to accept request: $e';
    }
  }

  /// 4. Reject a pending partner request by connection ID.
  ///    Updates the status to 'rejected'.
  Future<String?> rejectPartnerRequest(String connectionId) async {
    try {
      final client = Supabase.instance.client;

      await client
          .from('partner_connections')
          .update({'status': 'rejected'})
          .eq('id', connectionId);

      _pendingRequests.removeWhere((r) => r.id == connectionId);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error rejecting partner request: $e');
      return 'Failed to reject request: $e';
    }
  }

  /// 5. Fetch health logs (daily_logs + hydration_logs) from the active
  ///    partner when the connection status is 'accepted'.
  Future<void> fetchPartnerLogs() async {
    if (_activeConnection == null || _activeConnection!.status != 'accepted') {
      return;
    }

    _isFetchingPartnerLogs = true;
    notifyListeners();

    try {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) return;

      // Determine the partner's user ID from the active connection
      final partnerUserId = _getPartnerUserId(currentUserId);
      if (partnerUserId == null) return;

      // Fetch partner's profile for the name
      final partnerProfile = await client
          .from('profiles')
          .select('name, full_name')
          .eq('id', partnerUserId)
          .maybeSingle();

      final partnerName =
          partnerProfile?['full_name'] ?? partnerProfile?['name'] ?? 'Partner';

      // ── Query 1: daily_logs for partner ──
      final dailyLogsData = await client
          .from('daily_logs')
          .select('*')
          .eq('user_id', partnerUserId)
          .order('date', ascending: false);

      final parsedDailyLogs = (dailyLogsData as List).map((row) {
        // Map snake_case Supabase columns to DailyLog-friendly structure
        return DailyLog(
          date: row['date'] ?? '',
          mood: row['mood'],
          symptoms: (row['symptoms'] as List?)?.cast<String>() ?? const [],
          severity: row['severity'] ?? 3,
          personalNotes: row['personal_notes'] ?? '',
          sleep: row['sleep'] != null ? SleepLog.fromJson(row['sleep']) : null,
          hydrationLogs: (row['hydration_logs'] as List?)
              ?.map((e) => HydrationLog.fromJson(e))
              .toList(),
          hydrationGoal: row['hydration_goal'] ?? 2500,
        );
      }).toList();

      // ── Query 2: hydration_logs for partner ──
      final hydrationData = await client
          .from('hydration_logs')
          .select('*')
          .eq('user_id', partnerUserId)
          .order('created_at', ascending: false);

      final parsedHydrationLogs = (hydrationData as List).map((row) {
        return HydrationLog(
          id: row['id'] ?? '',
          amount: row['amount'] ?? 0,
          time: row['time'] ?? '',
          type: row['type'] ?? 'Water',
        );
      }).toList();

      _partnerLogs = PartnerLogBundle(
        partnerUserId: partnerUserId,
        partnerName: partnerName,
        dailyLogs: parsedDailyLogs,
        hydrationLogs: parsedHydrationLogs,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching partner logs: $e');
    } finally {
      _isFetchingPartnerLogs = false;
      notifyListeners();
    }
  }

  /// ─── Helper: Load the current active (accepted) connection ─────────────
  Future<void> _loadActiveConnection() async {
    try {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;

      if (currentUserId == null) {
        _activeConnection = null;
        return;
      }

      final data = await client
          .from('partner_connections')
          .select()
          .or(
            'and(requester_id.eq.$currentUserId,status.eq.accepted),'
            'and(receiver_id.eq.$currentUserId,status.eq.accepted)',
          )
          .maybeSingle();

      if (data != null) {
        _activeConnection = PartnerConnection.fromJson(data);
      } else {
        _activeConnection = null;
      }
    } catch (e) {
      debugPrint('Error loading active connection: $e');
      _activeConnection = null;
    }
  }

  /// ─── Helper: Determine partner's user ID from active connection ────────
  String? _getPartnerUserId(String currentUserId) {
    if (_activeConnection == null) return null;

    if (_activeConnection!.requesterId == currentUserId) {
      return _activeConnection!.receiverId;
    } else if (_activeConnection!.receiverId == currentUserId) {
      return _activeConnection!.requesterId;
    }
    return null;
  }
}
