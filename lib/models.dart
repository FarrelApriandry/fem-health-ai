class UserProfile {
  String name;
  String fullName;
  String email;
  String dob;
  double height; // cm
  double weight; // kg
  String lastPeriodStart; // YYYY-MM-DD
  int cycleLength; // days
  int periodLength; // days

  UserProfile({
    this.name = '',
    this.fullName = '',
    this.email = '',
    this.dob = '',
    this.height = 0,
    this.weight = 0,
    this.lastPeriodStart = '',
    this.cycleLength = 0,
    this.periodLength = 0,
  });

  UserProfile copyWith({
    String? name,
    String? fullName,
    String? email,
    String? dob,
    double? height,
    double? weight,
    String? lastPeriodStart,
    int? cycleLength,
    int? periodLength,
  }) {
    return UserProfile(
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
    );
  }
}

class HydrationLog {
  final String id;
  final int amount; // ml
  final String time; // e.g. "2:30 PM"
  final String type; // e.g. "Glass of Water"

  HydrationLog({
    required this.id,
    required this.amount,
    required this.time,
    required this.type,
  });
}

class SleepLog {
  final String startTime; // "22:30"
  final String endTime; // "06:45"
  final String quality; // "restless" | "light" | "good" | "deep"
  final int totalMinutes;

  SleepLog({
    required this.startTime,
    required this.endTime,
    required this.quality,
    required this.totalMinutes,
  });
}

class DailyLog {
  final String date; // YYYY-MM-DD
  final String? mood; // 'terrible' | 'bad' | 'okay' | 'good' | 'great'
  final List<String> symptoms;
  final int severity; // 1-5
  final String personalNotes;
  final SleepLog? sleep;
  final List<HydrationLog>? hydrationLogs;
  final int hydrationGoal;

  DailyLog({
    required this.date,
    this.mood,
    this.symptoms = const [],
    this.severity = 3,
    this.personalNotes = '',
    this.sleep,
    this.hydrationLogs,
    this.hydrationGoal = 2500,
  });

  DailyLog copyWith({
    String? mood,
    List<String>? symptoms,
    int? severity,
    String? personalNotes,
    SleepLog? sleep,
    List<HydrationLog>? hydrationLogs,
    int? hydrationGoal,
  }) {
    return DailyLog(
      date: date,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      severity: severity ?? this.severity,
      personalNotes: personalNotes ?? this.personalNotes,
      sleep: sleep ?? this.sleep,
      hydrationLogs: hydrationLogs ?? this.hydrationLogs,
      hydrationGoal: hydrationGoal ?? this.hydrationGoal,
    );
  }
}

class NotificationSettings {
  bool periodReminder;
  int periodDaysBefore;
  String periodTime;
  bool ovulationReminder;
  bool hydrationReminder;
  String hydrationInterval;
  bool sleepReminder;
  String sleepTime;
  bool symptomReminder;

  NotificationSettings({
    this.periodReminder = true,
    this.periodDaysBefore = 2,
    this.periodTime = '09:00',
    this.ovulationReminder = true,
    this.hydrationReminder = true,
    this.hydrationInterval = 'Every 2 hours',
    this.sleepReminder = true,
    this.sleepTime = '21:30',
    this.symptomReminder = true,
  });

  NotificationSettings copy() {
    return NotificationSettings(
      periodReminder: periodReminder,
      periodDaysBefore: periodDaysBefore,
      periodTime: periodTime,
      ovulationReminder: ovulationReminder,
      hydrationReminder: hydrationReminder,
      hydrationInterval: hydrationInterval,
      sleepReminder: sleepReminder,
      sleepTime: sleepTime,
      symptomReminder: symptomReminder,
    );
  }
}

enum AppLanguage { indonesia, english }

class AppSettings {
  AppLanguage language;

  String theme;
  bool pinLockEnabled;
  bool biometricsEnabled;
  String pinCode;

  AppSettings({
    this.language = AppLanguage.indonesia,
    this.theme = 'light',
    this.pinLockEnabled = true,
    this.biometricsEnabled = true,
    this.pinCode = '1234',
  });

  AppSettings copy() {
    return AppSettings(
      language: language,
      theme: theme,
      pinLockEnabled: pinLockEnabled,
      biometricsEnabled: biometricsEnabled,
      pinCode: pinCode,
    );
  }
}

class ChatMessage {
  final String id;
  final String role; // 'user' | 'model'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
}
