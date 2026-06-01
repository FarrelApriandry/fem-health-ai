import 'package:flutter/material.dart';
import '../providers/fem_health_provider.dart';
import 'package:provider/provider.dart';

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

  const SymptomLoggerModal({
    super.key,
    required this.dateStr,
  });

  @override
  State<SymptomLoggerModal> createState() => _SymptomLoggerModalState();
}

class _SymptomLoggerModalState extends State<SymptomLoggerModal> {
  late List<String> _symptoms;
  late String _mood;
  late double _severity;
  late TextEditingController _notesController;
  String _selectedCategory = 'Physical';

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
    final provider = context.read<FemHealthProvider>();
    final log = provider.getLogForDate(widget.dateStr);
    _symptoms = List.from(log.symptoms);
    _mood = log.mood ?? 'okay';
    _severity = log.severity.toDouble();
    _notesController = TextEditingController(text: log.personalNotes);
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
    final provider = context.read<FemHealthProvider>();
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

                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Physical'),
                          selected: _selectedCategory == 'Physical',
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = 'Physical';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Emotional'),
                          selected: _selectedCategory == 'Emotional',
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = 'Emotional';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (_selectedCategory == 'Physical')
                    _buildSymptomCategory(
                      'Physical',
                      Icons.bolt,
                      colors.primary,
                      _physicalList,
                    ),

                  if (_selectedCategory == 'Emotional')
                    _buildSymptomCategory(
                      'Emotional',
                      Icons.favorite_border,
                      colors.secondary,
                      _emotionalList,
                    ),

                  if (_selectedCategory == 'Lifestyle')
                    _buildSymptomCategory(
                      'Lifestyle',
                      Icons.wb_sunny,
                      Colors.orange,
                      _lifestyleList,
                    ),

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
              onPressed: () {
                provider.saveSymptomLog(
                  widget.dateStr,
                  _mood,
                  _symptoms,
                  _severity.toInt(),
                  _notesController.text,
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
