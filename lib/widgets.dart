import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'models.dart';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const Color _emerald = Color(0xFF10B981);

class ModalHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const ModalHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          if (actionText != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionText!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class SymptomLoggerModal extends StatefulWidget {
  final String dateStr;
  final String initialMood;
  final List<String> initialSymptoms;
  final int initialSeverity;
  final String initialNotes;
  final Function(String, String, List<String>, int, String) onSave;

  const SymptomLoggerModal({
    super.key,
    required this.dateStr,
    required this.initialMood,
    required this.initialSymptoms,
    required this.initialSeverity,
    required this.initialNotes,
    required this.onSave,
  });

  @override
  State<SymptomLoggerModal> createState() => _SymptomLoggerModalState();
}

class _SymptomLoggerModalState extends State<SymptomLoggerModal> {
  late String _mood;
  late List<String> _symptoms;
  late double _severity;
  late TextEditingController _notesController;

  final List<Map<String, String>> _moods = [
    {'type': 'terrible', 'emoji': '😫', 'label': 'Terrible'},
    {'type': 'bad', 'emoji': '😞', 'label': 'Bad'},
    {'type': 'okay', 'emoji': '😐', 'label': 'Okay'},
    {'type': 'good', 'emoji': '🙂', 'label': 'Good'},
    {'type': 'great', 'emoji': '🤩', 'label': 'Great'},
  ];

  final List<String> _physicalList = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Acne',
    'Tender Breasts',
    'Backache',
    'Nausea',
  ];
  final List<String> _emotionalList = [
    'Anxious',
    'Mood Swings',
    'Irritable',
    'Sad',
    'Sensitive',
    'Restless',
    'Calm',
  ];
  final List<String> _lifestyleList = [
    'Exercised',
    'High Caffeine',
    'High Stress',
    'Poor Diet',
    'Restful Day',
    'Alcohol',
  ];

  @override
  void initState() {
    super.initState();
    _mood = widget.initialMood;
    _symptoms = List.from(widget.initialSymptoms);
    _severity = widget.initialSeverity.toDouble();
    _notesController = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleSymptom(String val) {
    setState(() {
      if (_symptoms.contains(val)) {
        _symptoms.remove(val);
      } else {
        _symptoms.add(val);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
          const ModalHeader(title: 'Log Symptoms'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'DATE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.dateStr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'How are you feeling?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _moods.map((m) {
                        final isSelected = _mood == m['type'];
                        return GestureDetector(
                          onTap: () => setState(() => _mood = m['type']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary.withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  m['emoji']!,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m['label']!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSymptomCategory(
                    'Physical',
                    Icons.bolt,
                    colors.primary,
                    _physicalList,
                  ),
                  const SizedBox(height: 24),

                  _buildSymptomCategory(
                    'Emotional',
                    Icons.favorite_border,
                    colors.secondary,
                    _emotionalList,
                  ),
                  const SizedBox(height: 24),

                  _buildSymptomCategory(
                    'Lifestyle',
                    Icons.star_border,
                    colors.tertiary,
                    _lifestyleList,
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Overall Severity',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: colors.primaryContainer,
                              child: Text(
                                '${_severity.toInt()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _severity,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          activeColor: colors.primary,
                          onChanged: (v) => setState(() => _severity = v),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mild (1)',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Severe (5)',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Personal Notes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add any extra details here...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () => widget.onSave(
                widget.dateStr,
                _mood,
                _symptoms,
                _severity.toInt(),
                _notesController.text,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Save Log',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomCategory(
    String name,
    IconData icon,
    Color headerCol,
    List<String> list,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: headerCol, size: 18),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((s) {
            final isSelected = _symptoms.contains(s);
            return FilterChip(
              label: Text(s),
              selected: isSelected,
              onSelected: (v) => _toggleSymptom(s),
              selectedColor: headerCol,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? headerCol
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class HydrationLoggerModal extends StatefulWidget {
  final List<HydrationLog> initialLogs;
  final int initialGoal;
  final Function(List<HydrationLog>, int) onSave;

  const HydrationLoggerModal({
    super.key,
    required this.initialLogs,
    required this.initialGoal,
    required this.onSave,
  });

  @override
  State<HydrationLoggerModal> createState() => _HydrationLoggerModalState();
}

class _HydrationLoggerModalState extends State<HydrationLoggerModal> {
  late List<HydrationLog> _logs;
  late int _goal;
  bool _customMode = false;
  final _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _logs = List.from(widget.initialLogs);
    _goal = widget.initialGoal;
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _addWater(int amount, String type) {
    final now = DateTime.now();
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final hr = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final timeStr = '$hr:${now.minute.toString().padLeft(2, '0')} $ampm';

    setState(() {
      _logs.insert(
        0,
        HydrationLog(
          id: DateTime.now().toString(),
          amount: amount,
          time: timeStr,
          type: type,
        ),
      );
    });
  }

  void _deleteLog(String id) {
    setState(() {
      _logs.removeWhere((x) => x.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final total = _logs.fold<int>(0, (sum, i) => sum + i.amount);
    final percent = math.min(1.0, total / _goal);

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
          ModalHeader(
            title: 'Hydration Tracker',
            actionText: 'Edit Goal',
            onAction: () {
              showDialog(
                context: context,
                builder: (context) {
                  final con = TextEditingController(text: '$_goal');
                  return AlertDialog(
                    title: const Text('Set Daily Hydration Goal'),
                    content: TextField(
                      controller: con,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(suffixText: 'ml'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _goal = int.tryParse(con.text) ?? 2500;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TODAY\'S INTAKE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: percent,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey.withValues(
                                  alpha: 0.1,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '$total',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' ml',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Goal: $_goal ml',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          percent >= 1.0
                              ? '✨ Goal Met! Excellent job staying hydrated!'
                              : 'You are ${(percent * 100).toInt()}% there! Keep hydrating to feel your best.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: percent >= 1.0 ? _emerald : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Quick Add',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuickAddBtn(250, 'Glass of Water', 'Glass'),
                      const SizedBox(width: 12),
                      _buildQuickAddBtn(500, 'Water Bottle', 'Bottle'),
                      const SizedBox(width: 12),
                      _buildQuickAddBtn(750, 'Large Carafe', 'Large'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_customMode)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'e.g. 350',
                                suffixText: 'ml',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final amount =
                                  int.tryParse(_customController.text) ?? 0;
                              if (amount > 0) {
                                _addWater(amount, 'Custom Intake');
                                _customController.clear();
                                setState(() => _customMode = false);
                              }
                            },
                            child: const Text('Add'),
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() => _customMode = false),
                            icon: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => setState(() => _customMode = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: Colors.blueAccent),
                        elevation: 0,
                      ),
                      child: const Text(
                        '+ Custom Amount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 24),

                  const Text(
                    'Today\'s History',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_logs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.12),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'No hydration logs recorded today.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_drink_outlined,
                                    color: Colors.blueAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${log.amount} ml',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        log.type,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    log.time,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _deleteLog(log.id),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () => widget.onSave(_logs, _goal),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Save Intake Schedule',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddBtn(int amount, String type, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _addWater(amount, type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_drink,
                  color: Colors.blueAccent,
                  size: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$amount ml',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SleepLoggerModal extends StatefulWidget {
  final SleepLog? initialSleep;
  final Function(SleepLog) onSave;

  const SleepLoggerModal({super.key, this.initialSleep, required this.onSave});

  @override
  State<SleepLoggerModal> createState() => _SleepLoggerModalState();
}

class _SleepLoggerModalState extends State<SleepLoggerModal> {
  String _startTime = '22:30';
  String _endTime = '06:45';
  String _quality = 'good';
  int _totalMin = 495;

  final List<Map<String, String>> _qualities = [
    {'type': 'restless', 'label': 'Restless'},
    {'type': 'light', 'label': 'Light'},
    {'type': 'good', 'label': 'Good'},
    {'type': 'deep', 'label': 'Deep'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialSleep != null) {
      _startTime = widget.initialSleep!.startTime;
      _endTime = widget.initialSleep!.endTime;
      _quality = widget.initialSleep!.quality;
      _totalMin = widget.initialSleep!.totalMinutes;
    }
    _calculateDuration();
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
              onPressed: () => widget.onSave(
                SleepLog(
                  startTime: _startTime,
                  endTime: _endTime,
                  quality: _quality,
                  totalMinutes: _totalMin,
                ),
              ),
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

class ObGynReportModal extends StatefulWidget {
  final UserProfile userProfile;

  const ObGynReportModal({super.key, required this.userProfile});

  @override
  State<ObGynReportModal> createState() => _ObGynReportModalState();
}

class _ObGynReportModalState extends State<ObGynReportModal> {
  String _downloading = 'idle';
  bool _sharing = false;

  Future<void> _exportPdf() async {
    setState(() {
      _downloading = 'exporting';
    });

    try {
      final fileName = _getReportFileName();
      final pdfBytes = await _buildReportPdf();

      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);

      if (!mounted) return;

      setState(() {
        _downloading = 'done';
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Complete'),
          content: Text(
            'PDF report has been generated successfully.\n\nFile name:\n$fileName',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Failed'),
          content: Text('Failed to generate PDF: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloading = 'idle';
        });
      }
    }
  }

  String _getReportFileName() {
    final rawName = widget.userProfile.fullName.trim().isNotEmpty
        ? widget.userProfile.fullName.trim()
        : widget.userProfile.name.trim().isNotEmpty
        ? widget.userProfile.name.trim()
        : 'User';

    final safeName = rawName
        .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return 'FemHealth_Report_$safeName.pdf';
  }

  Future<Uint8List> _buildReportPdf() async {
    final pdf = pw.Document();

    final profile = widget.userProfile;

    final displayName = profile.fullName.trim().isNotEmpty
        ? profile.fullName.trim()
        : profile.name.trim().isNotEmpty
        ? profile.name.trim()
        : 'Not set';

    final dob = profile.dob.trim().isNotEmpty ? profile.dob.trim() : 'Not set';
    final email = profile.email.trim().isNotEmpty
        ? profile.email.trim()
        : 'Not set';

    final height = profile.height > 0
        ? '${profile.height.toInt()} cm'
        : 'Not set';
    final weight = profile.weight > 0
        ? '${profile.weight.toInt()} kg'
        : 'Not set';
    final cycleLength = profile.cycleLength > 0
        ? '${profile.cycleLength} days'
        : 'Not set';
    final periodLength = profile.periodLength > 0
        ? '${profile.periodLength} days'
        : 'Not set';
    final lastPeriod = profile.lastPeriodStart.trim().isNotEmpty
        ? profile.lastPeriodStart.trim()
        : 'Not set';

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FemHealth OB-GYN Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Generated for healthcare consultation.'),
              pw.SizedBox(height: 24),

              pw.Text(
                'Patient Profile',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              _buildPdfRow('Name', displayName),
              _buildPdfRow('Date of Birth', dob),
              _buildPdfRow('Email', email),
              _buildPdfRow('Height', height),
              _buildPdfRow('Weight', weight),
              _buildPdfRow('Last Period Started', lastPeriod),
              _buildPdfRow('Cycle Length', cycleLength),
              _buildPdfRow('Period Length', periodLength),

              pw.SizedBox(height: 24),

              pw.Text(
                'Clinical Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'This report summarizes the user profile and cycle-related information recorded in FemHealth. Additional symptom, mood, hydration, and sleep logs can be included in future report versions.',
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  void _shareReport() {
    setState(() {
      _sharing = true;
    });
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _sharing = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Share Complete'),
          content: const Text(
            'Secure share link generated and copied to clipboard!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
          const ModalHeader(title: 'Generate Report'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Professional Medical Report',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFAC2A5D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Review your clinical summary before exporting for your healthcare provider.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 4,
                          width: double.infinity,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PROFESSIONAL OB-GYN REPORT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.userProfile.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'DOB: ${widget.userProfile.dob} | ID: FH-88392',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'DATE GENERATED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Oct 26, 2023',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 32, color: Colors.black12),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CYCLE AVG',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '28.4',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: colors.primary,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: ' days',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'VARIATION',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: const TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '±1.2',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' days',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'LAST 6 CYCLES SUMMARY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildReportBar('May', 27),
                              _buildReportBar('Jun', 29),
                              _buildReportBar('Jul', 28),
                              _buildReportBar('Aug', 30),
                              _buildReportBar('Sep', 28),
                              _buildReportBar('Oct', 29),
                            ],
                          ),
                        ),
                        const Divider(height: 32, color: Colors.black12),

                        const Text(
                          'CLINICAL HIGHLIGHTS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildHighlightRow(
                          'Frequent reports of Mild Cramps and Fatigue during cycle days 1-2.',
                        ),
                        const SizedBox(height: 8),
                        _buildHighlightRow(
                          'Mood trends indicate elevated Anxiety during the late luteal phase.',
                        ),
                        const SizedBox(height: 8),
                        _buildHighlightRow(
                          'Average sleep recorded: 6.8 hours/night. Hydration goals met 70% of days.',
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: colors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Health Verification',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'This summary is dynamically compiled from patient logs. Share it directly with regular physicians to foster personalized healthcare.',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: Colors.grey,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _downloading == 'idle' ? _exportPdf : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _buildDownloadBtnContent(),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _sharing ? null : _shareReport,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(color: colors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_sharing) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                      ] else ...[
                        const Icon(Icons.share, size: 18),
                        const SizedBox(width: 8),
                      ],
                      const Text(
                        'Share Report Securely',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadBtnContent() {
    if (_downloading == 'exporting') {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Text('Compiling Clinical PDF...'),
        ],
      );
    } else if (_downloading == 'done') {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check),
          SizedBox(width: 8),
          Text('Saved to Device'),
        ],
      );
    } else {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download),
          SizedBox(width: 8),
          Text('Export as PDF', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
    }
  }

  Widget _buildHighlightRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, color: _emerald, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportBar(String month, int len) {
    final maxH = 70.0;
    final h = (len / 35) * maxH;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14,
          height: h,
          decoration: const BoxDecoration(
            color: Color(0xFFFBCFE8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          month,
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

class NotificationSettingsModal extends StatefulWidget {
  final NotificationSettings initialSettings;
  final Function(NotificationSettings) onSave;

  const NotificationSettingsModal({
    super.key,
    required this.initialSettings,
    required this.onSave,
  });

  @override
  State<NotificationSettingsModal> createState() =>
      _NotificationSettingsModalState();
}

class _NotificationSettingsModalState extends State<NotificationSettingsModal> {
  late NotificationSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings.copy();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
          const ModalHeader(title: 'Notification Settings'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Period reminders',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Get alerts before your bleeding phase',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Switch(
                      value: _settings.periodReminder,
                      activeThumbColor: colors.primary,
                      onChanged: (v) =>
                          setState(() => _settings.periodReminder = v),
                    ),
                  ],
                ),
                if (_settings.periodReminder) ...[
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.only(left: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0xFFDDBFC5), width: 2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Days before alert',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<int>(
                              value: _settings.periodDaysBefore,
                              items: List.generate(5, (index) => index + 1)
                                  .map(
                                    (i) => DropdownMenuItem<int>(
                                      value: i,
                                      child: Text('$i days'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(
                                () => _settings.periodDaysBefore = v ?? 2,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Daily reminding time',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final parts = _settings.periodTime
                                    .split(':')
                                    .map(int.parse)
                                    .toList();
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: parts[0],
                                    minute: parts[1],
                                  ),
                                );
                                if (time != null) {
                                  setState(
                                    () => _settings.periodTime =
                                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                  );
                                }
                              },
                              child: Text(
                                _settings.periodTime,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ovulation reminders',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Alert when fertility windows peak',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Switch(
                      value: _settings.ovulationReminder,
                      activeThumbColor: colors.primary,
                      onChanged: (v) =>
                          setState(() => _settings.ovulationReminder = v),
                    ),
                  ],
                ),
                const Divider(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Water break reminders',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Get recurring hydration alarms',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Switch(
                      value: _settings.hydrationReminder,
                      activeThumbColor: colors.primary,
                      onChanged: (v) =>
                          setState(() => _settings.hydrationReminder = v),
                    ),
                  ],
                ),
                if (_settings.hydrationReminder) ...[
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.only(left: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0xFFDDBFC5), width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Frequency Interval',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _settings.hydrationInterval,
                          items:
                              ['Every hour', 'Every 2 hours', 'Every 3 hours']
                                  .map(
                                    (s) => DropdownMenuItem<String>(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(
                            () => _settings.hydrationInterval =
                                v ?? 'Every 2 hours',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bedtime alarms',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Alert when nighttime targets begin',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Switch(
                      value: _settings.sleepReminder,
                      activeThumbColor: colors.primary,
                      onChanged: (v) =>
                          setState(() => _settings.sleepReminder = v),
                    ),
                  ],
                ),
                if (_settings.sleepReminder) ...[
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.only(left: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0xFFDDBFC5), width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Target sleep reminding time',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final parts = _settings.sleepTime
                                .split(':')
                                .map(int.parse)
                                .toList();
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: parts[0],
                                minute: parts[1],
                              ),
                            );
                            if (time != null) {
                              setState(
                                () => _settings.sleepTime =
                                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                              );
                            }
                          },
                          child: Text(
                            _settings.sleepTime,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_settings);
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
              child: const Text(
                'Save Reminders',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SecuritySettingsModal extends StatefulWidget {
  final AppSettings initialSettings;
  final Function(AppSettings) onSave;

  const SecuritySettingsModal({
    super.key,
    required this.initialSettings,
    required this.onSave,
  });

  @override
  State<SecuritySettingsModal> createState() => _SecuritySettingsModalState();
}

class _SecuritySettingsModalState extends State<SecuritySettingsModal> {
  late AppSettings _settings;
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings.copy();
    _pinController.text = _settings.pinCode;
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ModalHeader(title: 'Device Locks'),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PIN locks protection',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Use numeric keyboard before logs access',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Switch(
                      value: _settings.pinLockEnabled,
                      activeThumbColor: colors.primary,
                      onChanged: (v) =>
                          setState(() => _settings.pinLockEnabled = v),
                    ),
                  ],
                ),
                if (_settings.pinLockEnabled) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Configured passcode code',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: UnderlineInputBorder(),
                            ),
                            onChanged: (v) {
                              _settings.pinCode = v.replaceAll(
                                RegExp(r'\D'),
                                '',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Biometric unlock option',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Allow Face ID or finger scans',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Switch(
                      value: _settings.biometricsEnabled,
                      activeThumbColor: colors.primary,
                      onChanged: (v) =>
                          setState(() => _settings.biometricsEnabled = v),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(_settings);
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
                  child: const Text(
                    'Save Device Locks',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InsightsView extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onOpenReport;

  const InsightsView({
    super.key,
    required this.profile,
    required this.onOpenReport,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Insights',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore data patterns and medical reports from your logged history.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: colors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Ob-Gyn Clinical Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Compile your historical symptoms, mood fluctuations, sleep quality, and hydration logs into a structured PDF report to share with your healthcare provider.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onOpenReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf),
                      SizedBox(width: 8),
                      Text(
                        'Generate Medical Report',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'CYCLE TRENDS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Average Cycle Variation',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '±1.2 days',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMiniInsightCard(
                      'Follicular Phase',
                      'Days 1-13',
                      Colors.blue,
                    ),
                    _buildMiniInsightCard('Ovulation', 'Day 14', Colors.pink),
                    _buildMiniInsightCard(
                      'Luteal Phase',
                      'Days 15-28',
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInsightCard(String phase, String days, Color col) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: col.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: col.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Text(
              phase,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: col,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              days,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  final UserProfile profile;
  final AppSettings settings;
  final NotificationSettings notifications;
  final Function(AppSettings, NotificationSettings) onUpdateSettings;
  final VoidCallback onResetSetup;
  final Function(UserProfile) onUpdateProfile;

  const ProfileView({
    super.key,
    required this.profile,
    required this.settings,
    required this.notifications,
    required this.onUpdateSettings,
    required this.onResetSetup,
    required this.onUpdateProfile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final displayName = profile.fullName.isNotEmpty
        ? profile.fullName
        : 'Complete your profile';

    final initial = profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : profile.fullName.isNotEmpty
        ? profile.fullName[0].toUpperCase()
        : '?';

    final dobText = profile.dob.isNotEmpty
        ? 'DOB: ${profile.dob}'
        : 'DOB: Not set yet';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: colors.primary.withValues(alpha: 0.1),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      dobText,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => EditProfileModal(
                            profile: profile,
                            onSave: onUpdateProfile,
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'HEALTH PARAMETERS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                _buildProfileDetailRow(
                  'Height',
                  '${profile.height.toInt()} cm',
                ),
                const Divider(height: 24, color: Colors.black12),
                _buildProfileDetailRow(
                  'Weight',
                  '${profile.weight.toInt()} kg',
                ),
                const Divider(height: 24, color: Colors.black12),
                _buildProfileDetailRow(
                  'Email',
                  profile.email.isNotEmpty ? profile.email : 'Not set',
                ),
                const Divider(height: 24, color: Colors.black12),
                _buildProfileDetailRow(
                  'Cycle Length',
                  '${profile.cycleLength} days',
                ),
                const Divider(height: 24, color: Colors.black12),
                _buildProfileDetailRow(
                  'Period Length',
                  '${profile.periodLength} days',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'SETTINGS & SECURITY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notification Settings',
                  subtitle: 'Manage period and water reminders',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => NotificationSettingsModal(
                        initialSettings: notifications,
                        onSave: (newNotif) {
                          onUpdateSettings(settings, newNotif);
                        },
                      ),
                    );
                  },
                ),
                const Divider(height: 12, indent: 56, color: Colors.black12),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Device Locks & PIN',
                  subtitle: 'Manage passcode and biometrics',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => SecuritySettingsModal(
                        initialSettings: settings,
                        onSave: (newSettings) {
                          onUpdateSettings(newSettings, notifications);
                        },
                      ),
                    );
                  },
                ),
                const Divider(height: 12, indent: 56, color: Colors.black12),
                _buildSettingsTile(
                  icon: Icons.refresh,
                  title: 'Reset Onboarding',
                  subtitle: 'Redo setup wizard from scratch',
                  iconColor: Colors.redAccent,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Onboarding?'),
                        content: const Text(
                          'This will clear all logged symptom entries, sleep data, water records, and setup data. Proceed?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onResetSetup();
                            },
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.grey).withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.grey, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class EditProfileModal extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onSave;

  const EditProfileModal({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController _nameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _lastPeriodController;
  late TextEditingController _cycleLengthController;
  late TextEditingController _periodLengthController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _emailController = TextEditingController(text: widget.profile.email);
    _dobController = TextEditingController(text: widget.profile.dob);
    _heightController = TextEditingController(
      text: widget.profile.height == 0.0
          ? ''
          : widget.profile.height.toInt().toString(),
    );
    _weightController = TextEditingController(
      text: widget.profile.weight == 0.0
          ? ''
          : widget.profile.weight.toInt().toString(),
    );
    _lastPeriodController = TextEditingController(
      text: widget.profile.lastPeriodStart,
    );
    _cycleLengthController = TextEditingController(
      text: widget.profile.cycleLength.toString(),
    );
    _periodLengthController = TextEditingController(
      text: widget.profile.periodLength.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _lastPeriodController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    String initialStr,
  ) async {
    DateTime initial = DateTime.tryParse(initialStr) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
          const ModalHeader(title: 'Edit Profile'),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      label: 'Preferred Name',
                      controller: _nameController,
                      hint: 'e.g. Sarah',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Preferred name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Full Name',
                      controller: _fullNameController,
                      hint: 'e.g. Sarah Jenkins',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Full name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Email',
                      controller: _emailController,
                      hint: '',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(v.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: 'Date of Birth',
                      controller: _dobController,
                      onTap: () => _selectDate(
                        context,
                        _dobController,
                        _dobController.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'Height (cm)',
                            controller: _heightController,
                            hint: '165',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              final val = double.tryParse(v);
                              if (val == null || val <= 0) {
                                return 'Invalid height';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            label: 'Weight (kg)',
                            controller: _weightController,
                            hint: '60',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              final val = double.tryParse(v);
                              if (val == null || val <= 0) {
                                return 'Invalid weight';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: 'Last Period Start Date',
                      controller: _lastPeriodController,
                      onTap: () => _selectDate(
                        context,
                        _lastPeriodController,
                        _lastPeriodController.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'Cycle Length (days)',
                            controller: _cycleLengthController,
                            hint: '28',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              final val = int.tryParse(v);
                              if (val == null || val <= 0) {
                                return 'Invalid length';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            label: 'Period Length (days)',
                            controller: _periodLengthController,
                            hint: '5',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              final val = int.tryParse(v);
                              if (val == null || val <= 0 || val >= 20) {
                                return 'Invalid length';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final updatedProfile = UserProfile(
                            name: _nameController.text.trim(),
                            fullName: _fullNameController.text.trim(),
                            email: _emailController.text.trim(),
                            dob: _dobController.text.trim(),
                            height: double.parse(_heightController.text),
                            weight: double.parse(_weightController.text),
                            lastPeriodStart: _lastPeriodController.text.trim(),
                            cycleLength: int.parse(_cycleLengthController.text),
                            periodLength: int.parse(
                              _periodLengthController.text,
                            ),
                          );
                          widget.onSave(updatedProfile);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: IgnorePointer(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.04),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
