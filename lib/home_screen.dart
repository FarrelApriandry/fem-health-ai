import 'dart:math' as math;
import 'package:fem_health/app_strings.dart';
import 'package:flutter/material.dart';
import 'models.dart';

class HomeDashboard extends StatelessWidget {
  final UserProfile profile;
  final DailyLog? todayLog;
  final Function(String) onOpenLogger;
  final VoidCallback onNotifyTrigger;
  final VoidCallback onMenuTrigger;
  final AppSettings settings;

  const HomeDashboard({
    super.key,
    required this.profile,
    required this.todayLog,
    required this.onOpenLogger,
    required this.onNotifyTrigger,
    required this.onMenuTrigger,
    required this.settings,
  });
  String tr(String key) {
    return settings.language == AppLanguage.indonesia
        ? AppStrings.id[key] ?? key
        : AppStrings.en[key] ?? key;
  }

  int _calculateCycleDay(UserProfile profile) {
    final lastPeriod = DateTime.tryParse(profile.lastPeriodStart);

    if (lastPeriod == null || profile.cycleLength <= 0) {
      return 0;
    }

    final today = DateTime.now();

    final todayOnly = DateTime(today.year, today.month, today.day);
    final lastPeriodOnly = DateTime(
      lastPeriod.year,
      lastPeriod.month,
      lastPeriod.day,
    );

    final diff = todayOnly.difference(lastPeriodOnly).inDays;

    if (diff < 0) {
      return 0;
    }

    return (diff % profile.cycleLength) + 1;
  }

  String _getCyclePhase(UserProfile profile, int currentCycleDay) {
    if (currentCycleDay <= 0) {
      return 'Cycle data not available';
    }

    if (currentCycleDay <= profile.periodLength) {
      return 'Menstrual Phase';
    }

    final ovulationDay = profile.cycleLength - 14;

    if ((currentCycleDay - ovulationDay).abs() <= 1) {
      return 'Ovulation Phase';
    }

    if (currentCycleDay < ovulationDay) {
      return 'Follicular Phase';
    }

    return 'Luteal Phase';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasCycleData =
        profile.lastPeriodStart.isNotEmpty &&
        profile.cycleLength > 0 &&
        profile.periodLength > 0;

    final currentCycleDay = hasCycleData ? _calculateCycleDay(profile) : 0;

    final daysUntilNextPeriod = hasCycleData && currentCycleDay > 0
        ? profile.cycleLength - currentCycleDay + 1
        : 0;

    final cyclePhase = hasCycleData && currentCycleDay > 0
        ? _getCyclePhase(profile, currentCycleDay)
        : 'Complete your cycle profile';

    final sleepDisplay = todayLog?.sleep != null
        ? '${todayLog!.sleep!.totalMinutes ~/ 60}h ${todayLog!.sleep!.totalMinutes % 60}m'
        : '7h 30m';

    final waterAmount = todayLog?.hydrationLogs != null
        ? todayLog!.hydrationLogs!.fold<int>(
            0,
            (sum, item) => sum + item.amount,
          )
        : 1500;
    final waterDisplay = '${(waterAmount / 1000).toStringAsFixed(1)}L';

    final moodDisplay = todayLog?.mood != null
        ? todayLog!.mood![0].toUpperCase() + todayLog!.mood!.substring(1)
        : 'Happy';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FemHealth',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const Text(
                        'HEALTH ENGINE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: Color(0xFF10B981),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Sync Live',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onMenuTrigger,
                    icon: const Icon(Icons.tune, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onNotifyTrigger,
                    icon: const Icon(Icons.notifications_outlined, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Cycle Intelligence',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Text(
                      'S12 • ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(
                        painter: CycleProgressPainter(
                          progress: hasCycleData && currentCycleDay > 0
                              ? currentCycleDay / profile.cycleLength
                              : 0,
                          primaryColor: colors.primary,
                          trackColor: Colors.grey.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasCycleData ? '$currentCycleDay' : '--',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                            letterSpacing: -2.0,
                            height: 1.0,
                          ),
                        ),
                        const Text(
                          'Active Day',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  cyclePhase,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasCycleData
                      ? 'Next period predicted in $daysUntilNextPeriod days'
                      : 'Add your last period date and cycle length first',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFF10B981),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'HIGH CONCEPTION PROBABILITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            tr('QUICK WORKSPACES'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickWorkspaceItem(
                context,
                'symptoms',
                Colors.purple.withValues(alpha: 0.05),
                colors.primary,
                Icons.favorite_border,
                tr('Symptoms'),
              ),
              _buildQuickWorkspaceItem(
                context,
                'mood',
                Colors.amber.withValues(alpha: 0.05),
                Colors.amber,
                Icons.sentiment_satisfied,
                'Mood',
              ),
              _buildQuickWorkspaceItem(
                context,
                'sleep',
                Colors.indigo.withValues(alpha: 0.05),
                Colors.indigo,
                Icons.bedtime_outlined,
                tr('Sleep Metric'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('WORKSPACE SUMMARY'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                ),
              ),
              GestureDetector(
                onTap: () => onOpenLogger('symptoms'),
                child: Text(
                  tr('MANAGE'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildSummaryCard(
                context,
                type: 'sleep',
                icon: Icons.bedtime,
                iconColor: Colors.indigo,
                title: 'Sleep Metric',
                value: sleepDisplay,
                desc: 'Optimal Rest',
                descColor: const Color(0xFF10B981),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                context,
                type: 'hydration',
                icon: Icons.local_drink,
                iconColor: Colors.blueAccent,
                title: 'Hydration',
                value: waterDisplay,
                customWidget: _buildWaterProgressBars(waterAmount),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                context,
                type: 'symptoms',
                icon: Icons.sentiment_satisfied_alt,
                iconColor: Colors.amber,
                title: 'Mood Status',
                value: moodDisplay,
                desc: 'Logged Today',
                descColor: Colors.grey,
              ),
              const SizedBox(height: 16),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuickWorkspaceItem(
    BuildContext context,
    String type,
    Color bg,
    Color iconColor,
    IconData icon,
    String label,
  ) {
    return GestureDetector(
      onTap: () => onOpenLogger(type),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String type,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? desc,
    Color? descColor,
    Widget? customWidget,
  }) {
    return GestureDetector(
      onTap: () => onOpenLogger(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (desc != null)
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: descColor,
                    ),
                  ),
                if (customWidget != null) ...[
                  const SizedBox(height: 4),
                  customWidget,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterProgressBars(int amount) {
    return Row(
      children: List.generate(5, (index) {
        final threshold = (index + 1) * 500;
        final filled = amount >= threshold;
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: filled
                  ? Colors.blueAccent
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class CycleProgressPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color trackColor;

  CycleProgressPainter({
    required this.progress,
    required this.primaryColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    const startAngle = -math.pi / 2;
    final sweepAngle = -2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
