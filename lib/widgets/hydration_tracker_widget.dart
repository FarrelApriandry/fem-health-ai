import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models.dart';
import '../providers/fem_health_provider.dart';
import 'package:provider/provider.dart';
import 'symptom_logger_modal.dart';

class HydrationLoggerModal extends StatefulWidget {
  const HydrationLoggerModal({super.key});

  @override
  State<HydrationLoggerModal> createState() => _HydrationLoggerModalState();
}

class _HydrationLoggerModalState extends State<HydrationLoggerModal> {
  late List<HydrationLog> _logs;
  late int _goal;
  late String _date;
  bool _customMode = false;
  final _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<FemHealthProvider>();
    _date = provider.selectedDate;
    final log = provider.getLogForDate(_date);
    _logs = List.from(log.hydrationLogs ?? []);
    _goal = log.hydrationGoal;
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
    final provider = context.read<FemHealthProvider>();
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
                          "TODAY'S INTAKE",
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
                            color: percent >= 1.0
                                ? const Color(0xFF10B981)
                                : Colors.grey,
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
                    "Today's History",
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
              onPressed: () {
                provider.saveHydrationLog(_date, _logs, _goal);
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
