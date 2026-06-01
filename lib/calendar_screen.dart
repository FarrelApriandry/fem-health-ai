import 'package:flutter/material.dart';
import 'models.dart';

class CalendarView extends StatefulWidget {
  final UserProfile profile;
  final Map<String, DailyLog> dailyLogs;
  final String selectedDate;
  final ValueChanged<String> onSelectDate;
  final Function(String) onOpenSymptomLogger;

  const CalendarView({
    super.key,
    required this.profile,
    required this.dailyLogs,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onOpenSymptomLogger,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late int _selectedDay;
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _parseSelectedDate();
  }

  @override
  void didUpdateWidget(CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _parseSelectedDate();
    }
  }

  void _parseSelectedDate() {
    try {
      final parts = widget.selectedDate.split('-');
      if (parts.length == 3) {
        _year = int.parse(parts[0]);
        _month = int.parse(parts[1]);
        _selectedDay = int.parse(parts[2]);
      }
    } catch (_) {
      _year = 2023;
      _month = 10;
      _selectedDay = 14;
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _month += offset;
      if (_month < 1) {
        _month = 12;
        _year -= 1;
      } else if (_month > 12) {
        _month = 1;
        _year += 1;
      }
      final daysInNewMonth = DateUtils.getDaysInMonth(_year, _month);
      if (_selectedDay > daysInNewMonth) {
        _selectedDay = daysInNewMonth;
      }
      final dateStr = '$_year-${_month.toString().padLeft(2, '0')}-${_selectedDay.toString().padLeft(2, '0')}';
      widget.onSelectDate(dateStr);
    });
  }

  String _getMonthName(int month) {
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return 'OCTOBER';
  }

  bool _isPeriodDay(int day) {
    final date = DateTime(_year, _month, day);
    final lastPeriod = DateTime.tryParse(widget.profile.lastPeriodStart) ?? DateTime(2023, 10, 4);
    final difference = date.difference(lastPeriod).inDays;
    int cycleDay = difference % widget.profile.cycleLength;
    if (cycleDay < 0) cycleDay += widget.profile.cycleLength;
    return cycleDay >= 0 && cycleDay < widget.profile.periodLength;
  }

  bool _isOvulationDay(int day) {
    final date = DateTime(_year, _month, day);
    final lastPeriod = DateTime.tryParse(widget.profile.lastPeriodStart) ?? DateTime(2023, 10, 4);
    final difference = date.difference(lastPeriod).inDays;
    int cycleDay = difference % widget.profile.cycleLength;
    if (cycleDay < 0) cycleDay += widget.profile.cycleLength;
    final ovulationDay = widget.profile.cycleLength - 14;
    return cycleDay == ovulationDay;
  }

  bool _isFertilityDay(int day) {
    final date = DateTime(_year, _month, day);
    final lastPeriod = DateTime.tryParse(widget.profile.lastPeriodStart) ?? DateTime(2023, 10, 4);
    final difference = date.difference(lastPeriod).inDays;
    int cycleDay = difference % widget.profile.cycleLength;
    if (cycleDay < 0) cycleDay += widget.profile.cycleLength;
    final ovulationDay = widget.profile.cycleLength - 14;
    return cycleDay >= ovulationDay - 5 && cycleDay < ovulationDay;
  }

  String _getDayStatus(int day) {
    final monthName = _getMonthName(_month);
    final shortMonth = monthName.substring(0, 3);
    final displayMonth = '${shortMonth[0]}${shortMonth.substring(1).toLowerCase()}';
    
    if (day == _selectedDay) {
      if (_isOvulationDay(day)) return '$displayMonth $day - Predicted Ovulation';
      if (_isPeriodDay(day)) {
        final lastPeriod = DateTime.tryParse(widget.profile.lastPeriodStart) ?? DateTime(2023, 10, 4);
        final date = DateTime(_year, _month, day);
        final difference = date.difference(lastPeriod).inDays;
        int cycleDay = difference % widget.profile.cycleLength;
        if (cycleDay < 0) cycleDay += widget.profile.cycleLength;
        return '$displayMonth $day - Day ${cycleDay + 1} of Period';
      }
      if (_isFertilityDay(day)) return '$displayMonth $day - Fertile Window';
      return '$displayMonth $day - Follicular Phase';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final monthStr = _month.toString().padLeft(2, '0');
    final dateStr = '$_year-$monthStr-${_selectedDay.toString().padLeft(2, '0')}';
    final mockLog = widget.dailyLogs[dateStr];
    final daysInMonth = DateUtils.getDaysInMonth(_year, _month);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Text(
                '${_getMonthName(_month)} $_year',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                      .map(
                        (d) => Text(
                          d.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: daysInMonth,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isSelected = _selectedDay == day;
                    final isPeriod = _isPeriodDay(day);
                    final isFertility = _isFertilityDay(day);
                    final isOvulation = _isOvulationDay(day);

                    Color bg = Colors.transparent;
                    Color textCol = colors.onSurface;
                    BoxBorder? border;

                    if (isOvulation) {
                      bg = colors.primary;
                      textCol = Colors.white;
                    } else if (isPeriod) {
                      bg = const Color(0xFFFFDAD6);
                      textCol = const Color(0xFF6E0035);
                    } else if (isFertility) {
                      bg = const Color(0xFFEAD9FE);
                      textCol = const Color(0xFF7E1742);
                    }

                    if (isSelected && !isOvulation) {
                      border = Border.all(color: colors.primary, width: 2);
                    }

                    final hasLog =
                        widget.dailyLogs['$_year-$monthStr-${day.toString().padLeft(2, '0')}'] !=
                        null;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = day;
                        });
                        widget.onSelectDate(
                          '$_year-$monthStr-${day.toString().padLeft(2, '0')}',
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bg,
                          border: border,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    (isOvulation || isPeriod || isSelected)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: textCol,
                              ),
                            ),
                            if (hasLog && !isOvulation)
                              Positioned(
                                bottom: 6,
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: Colors.black12),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem(const Color(0xFFFFDAD6), 'Period'),
                    _buildLegendItem(const Color(0xFFEAD9FE), 'Fertile'),
                    _buildLegendItem(colors.primary, 'Ovulation'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'WORKSPACE CORE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getDayStatus(_selectedDay).isNotEmpty
                                ? _getDayStatus(_selectedDay)
                                : '${_getMonthName(_month)} $_selectedDay, $_year',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => widget.onOpenSymptomLogger(dateStr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(mockLog != null ? 'MODIFY' : '+ DAILY'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  child: _buildDayLogDetails(mockLog, colors),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDayLogDetails(DailyLog? log, ColorScheme colors) {
    if (log != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.sentiment_neutral,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Mood: ${log.mood ?? 'okay'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Severity: ${log.severity}/5',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          if (log.symptoms.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: log.symptoms
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (log.personalNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.black26, width: 2),
                ),
              ),
              child: Text(
                '"${log.personalNotes}"',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      );
    } else if (_isOvulationDay(_selectedDay)) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: Colors.pink, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Today is your predicted ovulation day. You have a significantly high chance of conception. Safe-sex measures are recommended unless seeking conception.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF865136),
              ),
            ),
          ),
        ],
      );
    } else {
      return const Text(
        'No daily logs or health records stored for this slot. Click "+ Daily" above to register custom parameters!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      );
    }
  }
}
