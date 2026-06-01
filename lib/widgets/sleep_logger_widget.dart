import 'package:flutter/material.dart';
import '../models.dart';
import '../providers/fem_health_provider.dart';
import 'package:provider/provider.dart';
import 'symptom_logger_modal.dart';

class SleepLoggerModal extends StatefulWidget {
  const SleepLoggerModal({super.key});

  @override
  State<SleepLoggerModal> createState() => _SleepLoggerModalState();
}

class _SleepLoggerModalState extends State<SleepLoggerModal> {
  String _startTime = '22:30';
  String _endTime = '06:45';
  String _quality = 'good';
  int _totalMin = 495;
  late String _date;

  final List<Map<String, String>> _qualities = [
    {'type': 'restless', 'label': 'Restless'},
    {'type': 'light', 'label': 'Light'},
    {'type': 'good', 'label': 'Good'},
    {'type': 'deep', 'label': 'Deep'},
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<FemHealthProvider>();
    _date = provider.selectedDate;
    final existing = provider.getLogForDate(_date).sleep;
    if (existing != null) {
      _startTime = existing.startTime;
      _endTime = existing.endTime;
      _quality = existing.quality;
      _totalMin = existing.totalMinutes;
    } else {
      _calculateDuration();
    }
  }

  void _calculateDuration() {
    final partsStart = _startTime.split(':').map(int.parse).toList();
    final partsEnd = _endTime.split(':').map(int.parse).toList();

    final startMins = partsStart[0] * 60 + partsStart[1];
    final endMins = partsEnd[0] * 60 + partsEnd[1];

    int diff = 0;
    if (endMins >= startMins) {
      diff = endMins - startMins;
    } else {
      diff = (24 * 60 - startMins) + endMins;
    }

    setState(() {
      _totalMin = diff;
    });
  }

  String _formatTimeToAmPm(String timeStr) {
    final parts = timeStr.split(':').map(int.parse).toList();
    final ampm = parts[0] >= 12 ? 'PM' : 'AM';
    final hr = parts[0] % 12 == 0 ? 12 : parts[0] % 12;
    return '${hr.toString().padLeft(2, '0')}:${parts[1].toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.read<FemHealthProvider>();
    final hours = _totalMin ~/ 60;
    final minutes = _totalMin % 60;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const ModalHeader(title: 'Log Sleep'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTimeSelectorColumn('Sleep Time', _startTime, (
                              v,
                            ) {
                              setState(() => _startTime = v);
                              _calculateDuration();
                            }),
                            const Icon(Icons.arrow_forward, color: Colors.grey),
                            _buildTimeSelectorColumn('Wake Time', _endTime, (
                              v,
                            ) {
                              setState(() => _endTime = v);
                              _calculateDuration();
                            }),
                          ],
                        ),
                        const Divider(height: 32, color: Colors.black12),
                        const Text(
                          'TOTAL SLEEP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bed, color: colors.primary, size: 24),
                            const SizedBox(width: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$hours',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: colors.primary,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' hours ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$minutes',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: colors.primary,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' mins',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'How did you sleep?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _qualities.map((q) {
                      final isSelected = _quality == q['type'];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: ChoiceChip(
                            label: Text(q['label']!),
                            selected: isSelected,
                            onSelected: (v) =>
                                setState(() => _quality = q['type']!),
                            selectedColor: colors.secondary,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[750],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'This Week',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Avg: 7h 20m',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildWeeklyBar('Mon', 7.2, false),
                              _buildWeeklyBar('Tue', 7.6, false),
                              _buildWeeklyBar('Wed', 6.8, false),
                              _buildWeeklyBar('Thu', 8.0, false),
                              _buildWeeklyBar('Fri', 7.2, false),
                              _buildWeeklyBar('Sat', 7.8, false),
                              _buildWeeklyBar('Sun', 8.2, true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () {
                provider.saveSleepLog(
                  _date,
                  SleepLog(
                    startTime: _startTime,
                    endTime: _endTime,
                    quality: _quality,
                    totalMinutes: _totalMin,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule),
                  SizedBox(width: 8),
                  Text(
                    'Add Sleep Log',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelectorColumn(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final parts = value.split(':').map(int.parse).toList();
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: parts[0], minute: parts[1]),
            );
            if (time != null) {
              onChanged(
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTimeToAmPm(value),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyBar(String label, double val, bool highlight) {
    final maxH = 80.0;
    final h = (val / 10.0) * maxH;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14,
          height: h,
          decoration: BoxDecoration(
            color: highlight
                ? const Color(0xFFAC2A5D)
                : const Color(0xFFFFB1C5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
