import 'package:flutter/material.dart';

import 'models.dart';
import 'pin_lock_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'chat_screen.dart';
import 'widgets.dart';

void main() {
  runApp(const FemHealthApp());
}

class FemHealthApp extends StatefulWidget {
  const FemHealthApp({super.key});

  @override
  State<FemHealthApp> createState() => _FemHealthAppState();
}

class _FemHealthAppState extends State<FemHealthApp> {
  String _activeTab = 'home';
  bool _isOnboarded = false;
  bool _isLocked = true;
  String _selectedDate = '2023-10-14';

  late UserProfile _profile;
  late AppSettings _settings;
  late NotificationSettings _notifications;
  late Map<String, DailyLog> _dailyLogs;

  @override
  void initState() {
    super.initState();

    _profile = UserProfile();
    _settings = AppSettings();
    _notifications = NotificationSettings();

    _dailyLogs = {
      '2023-10-04': DailyLog(
        date: '2023-10-04',
        mood: 'okay',
        symptoms: ['Cramps', 'Fatigue'],
        severity: 4,
        personalNotes:
            'Period started. Felt standard abdominal cramping and overall slowness.',
        sleep: SleepLog(
          startTime: '22:30',
          endTime: '06:45',
          quality: 'good',
          totalMinutes: 495,
        ),
        hydrationLogs: [
          HydrationLog(
            id: '1',
            amount: 500,
            time: '08:00 AM',
            type: 'Water',
          ),
        ],
      ),
    };
  }

  void _onUnlock() {
    setState(() {
      _isLocked = false;
    });
  }

  void _onOnboardingComplete(UserProfile newProfile) {
    setState(() {
      _profile = newProfile;
      _isOnboarded = true;
      _isLocked = false;
    });
  }

  void _onUpdateSettings(
    AppSettings app,
    NotificationSettings notify,
  ) {
    setState(() {
      _settings = app;
      _notifications = notify;
    });
  }

  void _onUpdateProfile(UserProfile newProfile) {
    setState(() {
      _profile = newProfile;
    });
  }

  void _onResetWizard() {
    setState(() {
      _profile = UserProfile();
      _settings = AppSettings(pinLockEnabled: false);
      _notifications = NotificationSettings();
      _dailyLogs = {};
      _isOnboarded = false;
      _isLocked = false;
      _activeTab = 'home';
    });
  }

  void _saveSymptomLog(
    String date,
    String mood,
    List<String> symptoms,
    int severity,
    String notes,
  ) {
    setState(() {
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
    });
  }

  void _saveHydrationLog(
    String date,
    List<HydrationLog> logs,
    int goal,
  ) {
    setState(() {
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
    });
  }

  void _saveSleepLog(String date, SleepLog sleep) {
    setState(() {
      final existing = _dailyLogs[date];

      if (existing != null) {
        _dailyLogs[date] = existing.copyWith(sleep: sleep);
      } else {
        _dailyLogs[date] = DailyLog(
          date: date,
          sleep: sleep,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _settings.theme == 'dark';

    final themeData = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: const Color(0xFFAC2A5D),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFFF6B9D),
        onPrimaryContainer: const Color(0xFF6E0035),
        secondary: const Color(0xFF665978),
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFEAD9FE),
        onSecondaryContainer: const Color(0xFF6A5D7C),
        tertiary: const Color(0xFF865136),
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFCF8F6F),
        onTertiaryContainer: Colors.black,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        onSurface: isDark ? Colors.white : const Color(0xFF09090B),
        shadow: Colors.black.withValues(alpha: 0.08),
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
    );

    Widget activeScreen;

    if (!_isOnboarded) {
      activeScreen = OnboardingScreen(
        onComplete: _onOnboardingComplete,
      );
    } else if (_isLocked && _settings.pinLockEnabled) {
      activeScreen = PINLockScreen(
        correctPin: _settings.pinCode,
        onUnlock: _onUnlock,
        biometricsEnabled: _settings.biometricsEnabled,
      );
    } else {
      activeScreen = MainFrame(
        activeTab: _activeTab,
        onTabChanged: (tab) {
          setState(() {
            _activeTab = tab;
          });
        },
        profile: _profile,
        dailyLogs: _dailyLogs,
        settings: _settings,
        notifications: _notifications,
        selectedDate: _selectedDate,
        onSelectDate: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        onUpdateSettings: _onUpdateSettings,
        onResetWizard: _onResetWizard,
        onSaveSymptomLog: _saveSymptomLog,
        onSaveHydrationLog: _saveHydrationLog,
        onSaveSleepLog: _saveSleepLog,
        onUpdateProfile: _onUpdateProfile,
      );
    }

    return MaterialApp(
      title: 'FemHealth',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: activeScreen,
    );
  }
}

class MainFrame extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  final UserProfile profile;
  final Map<String, DailyLog> dailyLogs;
  final AppSettings settings;
  final NotificationSettings notifications;
  final String selectedDate;
  final ValueChanged<String> onSelectDate;
  final Function(AppSettings, NotificationSettings) onUpdateSettings;
  final VoidCallback onResetWizard;
  final Function(String, String, List<String>, int, String) onSaveSymptomLog;
  final Function(String, List<HydrationLog>, int) onSaveHydrationLog;
  final Function(String, SleepLog) onSaveSleepLog;
  final Function(UserProfile) onUpdateProfile;

  const MainFrame({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.profile,
    required this.dailyLogs,
    required this.settings,
    required this.notifications,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onUpdateSettings,
    required this.onResetWizard,
    required this.onSaveSymptomLog,
    required this.onSaveHydrationLog,
    required this.onSaveSleepLog,
    required this.onUpdateProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: _buildActiveScreen(context),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildBottomNav(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveScreen(BuildContext context) {
    final todayLog = dailyLogs['2023-10-14'];

    switch (activeTab) {
      case 'home':
        return HomeDashboard(
          profile: profile,
          todayLog: todayLog,
          onOpenLogger: (type) => _openLogger(context, type),
          onNotifyTrigger: () => onTabChanged('profile'),
          onMenuTrigger: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('FemHealth Info'),
                content: Text(
                  'FemHealth Tracker\nRegistered: ${profile.fullName}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        );

      case 'calendar':
        return CalendarView(
          profile: profile,
          dailyLogs: dailyLogs,
          selectedDate: selectedDate,
          onSelectDate: onSelectDate,
          onOpenSymptomLogger: (date) {
            _openLogger(
              context,
              'symptoms',
              customDate: date,
            );
          },
        );

      case 'chat':
        return ChatScreen(
          name: profile.name,
        );

      case 'insights':
        return InsightsView(
          profile: profile,
          onOpenReport: () => _openObGynReport(context),
        );

      case 'profile':
        return ProfileView(
          profile: profile,
          settings: settings,
          notifications: notifications,
          onUpdateSettings: onUpdateSettings,
          onResetSetup: onResetWizard,
          onUpdateProfile: onUpdateProfile,
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 'home', Icons.favorite, 'Home'),
          _buildNavItem(context, 'calendar', Icons.calendar_month, 'Calendar'),
          _buildNavItem(context, 'chat', Icons.forum, 'AI'),
          _buildNavItem(context, 'insights', Icons.bar_chart, 'Insights'),
          _buildNavItem(context, 'profile', Icons.person, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String tab,
    IconData icon,
    String label,
  ) {
    final colors = Theme.of(context).colorScheme;
    final active = activeTab == tab;

    return GestureDetector(
      onTap: () {
        onTabChanged(tab);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFFDAD6) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: active ? colors.primary : Colors.grey,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: active ? colors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _openLogger(
    BuildContext context,
    String type, {
    String? customDate,
  }) {
    final date = customDate ?? selectedDate;
    final log = dailyLogs[date] ?? DailyLog(date: date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (type == 'symptoms') {
          return SymptomLoggerModal(
            dateStr: date,
            initialMood: log.mood ?? 'okay',
            initialSymptoms: log.symptoms,
            initialSeverity: log.severity,
            initialNotes: log.personalNotes,
            onSave: (dateStr, mood, symptoms, severity, notes) {
              onSaveSymptomLog(
                dateStr,
                mood,
                symptoms,
                severity,
                notes,
              );
              Navigator.pop(context);
            },
          );
        } else if (type == 'hydration') {
          return HydrationLoggerModal(
            initialLogs: log.hydrationLogs ?? [],
            initialGoal: log.hydrationGoal,
            onSave: (logs, goal) {
              onSaveHydrationLog(
                date,
                logs,
                goal,
              );
              Navigator.pop(context);
            },
          );
        } else {
          return SleepLoggerModal(
            initialSleep: log.sleep,
            onSave: (sleepLog) {
              onSaveSleepLog(date, sleepLog);
              Navigator.pop(context);
            },
          );
        }
      },
    );
  }

  void _openObGynReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ObGynReportModal(
          userProfile: profile,
        );
      },
    );
  }
}
