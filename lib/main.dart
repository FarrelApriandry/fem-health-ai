import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/fem_health_provider.dart';
import 'pin_lock_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'chat_screen.dart';
import 'widgets/symptom_logger_modal.dart';
import 'widgets/hydration_tracker_widget.dart';
import 'widgets/sleep_logger_widget.dart';
import 'widgets/obgyn_report_pdf.dart';
import 'widgets/settings_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mpqteprqsvnjbhfnecoz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1wcXRlcHJxc3ZuamJoZm5lY296Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxMjgzNzEsImV4cCI6MjA5NTcwNDM3MX0.pKj2TiFizgO7VZYmw0nzZECMZ-shpoOAE52ycMMt7nE',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => FemHealthProvider(),
      child: const FemHealthApp(),
    ),
  );
}

class FemHealthApp extends StatelessWidget {
  const FemHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FemHealthProvider>(
      builder: (context, provider, _) {
        final isDark = provider.settings.theme == 'dark';

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
          scaffoldBackgroundColor: isDark
              ? const Color(0xFF121212)
              : const Color(0xFFFAFAFA),
        );

        Widget activeScreen;

        if (!provider.isOnboarded) {
          activeScreen = const OnboardingScreen();
        } else if (provider.isLocked && provider.settings.pinLockEnabled) {
          activeScreen = const PINLockScreen();
        } else {
          activeScreen = const MainFrame();
        }

        return MaterialApp(
          title: 'FemHealth',
          debugShowCheckedModeBanner: false,
          theme: themeData,
          home: activeScreen,
        );
      },
    );
  }
}

class MainFrame extends StatelessWidget {
  const MainFrame({super.key});

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
    final provider = context.watch<FemHealthProvider>();
    final activeTab = provider.activeTab;

    switch (activeTab) {
      case 'home':
        return HomeDashboard(
          onOpenLogger: (type) => _openLogger(context, type),
          onNotifyTrigger: () => provider.setActiveTab('profile'),
          onMenuTrigger: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('FemHealth Info'),
                content: Text(
                  'FemHealth Tracker\nRegistered: ${provider.profile.fullName}',
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
        return const CalendarView();

      case 'chat':
        return const ChatScreen();

      case 'insights':
        return const InsightsView();

      case 'profile':
        return const ProfileView();

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
    final provider = context.read<FemHealthProvider>();
    final active = provider.activeTab == tab;

    return GestureDetector(
      onTap: () {
        provider.setActiveTab(tab);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

  void _openLogger(BuildContext context, String type, {String? customDate}) {
    final provider = context.read<FemHealthProvider>();
    final date = customDate ?? provider.selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (type == 'symptoms') {
          return SymptomLoggerModal(dateStr: date);
        } else if (type == 'hydration') {
          return const HydrationLoggerModal();
        } else {
          return const SleepLoggerModal();
        }
      },
    );
  }
}
