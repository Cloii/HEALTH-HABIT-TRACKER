import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../utils/habit_templates.dart';

/// Screen for adding or editing a habit
class AddHabitScreen extends StatefulWidget {
  final String? habitId; // If provided, we're editing an existing habit

  const AddHabitScreen({super.key, this.habitId});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _iconController;

  // Common emoji suggestions
  final List<String> suggestedEmojis = [
    '💧', '🏃', '📚', '🧘', '🍎', '💤', '✍️', '🎯',
    '💪', '🧠', '🌱', '🎨', '🎵', '📱', '☕', '🍽️',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _iconController = TextEditingController(text: '🎯'); // Default icon

    // If editing, populate fields
    if (widget.habitId != null) {
      _loadHabitData();
    }
  }

  void _loadHabitData() {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    final habit = provider.habits.firstWhere(
      (h) => h.id == widget.habitId,
      orElse: () => throw Exception('Habit not found'),
    );

    _nameController.text = habit.name;
    _descriptionController.text = habit.description ?? '';
    _iconController.text = habit.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<HabitProvider>(context, listen: false);

      if (widget.habitId != null) {
        // Update existing habit
        final habit = provider.habits.firstWhere((h) => h.id == widget.habitId);
        await provider.updateHabit(
          habit.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            icon: _iconController.text.trim(),
          ),
        );
      } else {
        // Add new habit
        await provider.addHabit(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          icon: _iconController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Habit' : 'New Habit'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Icon preview and input
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        _iconController.text.isEmpty
                            ? '🎯'
                            : _iconController.text,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _iconController,
                    decoration: const InputDecoration(
                      labelText: 'Icon (Emoji)',
                      hintText: 'Enter an emoji',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.emoji_emotions),
                    ),
                    maxLength: 2,
                    onChanged: (value) {
                      setState(() {}); // Update preview
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an emoji';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Habit Templates
            if (widget.habitId == null) ...[
              Text(
                'Quick Templates',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: habitTemplates.length,
                  itemBuilder: (context, index) {
                    final template = habitTemplates[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _nameController.text = template.name;
                            _iconController.text = template.icon;
                            _descriptionController.text = template.description;
                          });
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                template.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                template.name,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Suggested emojis
            Text(
              'Suggested Icons',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestedEmojis.map((emoji) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _iconController.text = emoji;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _iconController.text == emoji
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: _iconController.text == emoji ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Habit name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name *',
                hintText: 'e.g., Drink Water, Exercise, Read',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit name';
                }
                if (value.trim().length < 2) {
                  return 'Habit name must be at least 2 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add a note about this habit',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _saveHabit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Update Habit' : 'Create Habit',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

