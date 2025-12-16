import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../utils/habit_templates.dart';
import '../utils/categories.dart';
import '../services/notification_service.dart';

/// Enhanced screen for adding or editing a habit with categories, goals, and reminders
class AddHabitScreenEnhanced extends StatefulWidget {
  final String? habitId; // If provided, we're editing an existing habit

  const AddHabitScreenEnhanced({super.key, this.habitId});

  @override
  State<AddHabitScreenEnhanced> createState() => _AddHabitScreenEnhancedState();
}

class _AddHabitScreenEnhancedState extends State<AddHabitScreenEnhanced> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _iconController;
  late TextEditingController _weeklyGoalController;
  late TextEditingController _reminderTimeController;
  late TextEditingController _targetDurationController;

  String? _selectedCategory;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;
  bool _hasTimer = false;
  bool _isSaving = false;

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
    _iconController = TextEditingController(text: '🎯');
    _weeklyGoalController = TextEditingController();
    _reminderTimeController = TextEditingController();
    _targetDurationController = TextEditingController();

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
    _selectedCategory = habit.category;
    _weeklyGoalController.text = habit.weeklyGoal?.toString() ?? '';
    _reminderEnabled = habit.reminderEnabled ?? false;
    _hasTimer = habit.hasTimer;
    _targetDurationController.text = habit.targetDurationMinutes?.toString() ?? '';
    
    if (habit.reminderTime != null) {
      final parts = habit.reminderTime!.split(':');
      _reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      _reminderTimeController.text = habit.reminderTime!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    _weeklyGoalController.dispose();
    _reminderTimeController.dispose();
    _targetDurationController.dispose();
    super.dispose();
  }

  Future<void> _selectReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
        _reminderTimeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveHabit() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();

    final formState = _formKey.currentState;
    if (formState == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form error. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!formState.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fix the highlighted fields'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final nameText = _nameController.text.trim();

    setState(() {
      _isSaving = true;
    });
    try {
      final provider = Provider.of<HabitProvider>(context, listen: false);

      // Parse weekly goal - if invalid, treat as empty (optional field)
      final weeklyGoalText = _weeklyGoalController.text.trim();
      final weeklyGoal = weeklyGoalText.isNotEmpty
          ? int.tryParse(weeklyGoalText)
          : null;
      
      // If user entered something but it's not a valid number, ignore it (optional field)
      final validWeeklyGoal = (weeklyGoal != null && weeklyGoal >= 1 && weeklyGoal <= 7) 
          ? weeklyGoal 
          : null;
      
      // Parse target duration (optional)
      final targetDurationText = _targetDurationController.text.trim();
      final targetDuration = targetDurationText.isNotEmpty
          ? int.tryParse(targetDurationText)
          : null;
      final validTargetDuration = (targetDuration != null && targetDuration > 0)
          ? targetDuration
          : null;
      
      // Validate reminder time if reminder is enabled
      if (_reminderEnabled && _reminderTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a reminder time or disable reminders'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final reminderTimeStr = _reminderEnabled && _reminderTime != null
          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
          : null;

      if (widget.habitId != null) {
        // Update existing habit
        final habit = provider.habits.firstWhere((h) => h.id == widget.habitId);
        final updatedHabit = habit.copyWith(
          name: nameText,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          icon: _iconController.text.trim().isEmpty ? '🎯' : _iconController.text.trim(),
          category: _selectedCategory,
          weeklyGoal: validWeeklyGoal,
          reminderTime: reminderTimeStr,
          reminderEnabled: _reminderEnabled,
          hasTimer: _hasTimer,
          targetDurationMinutes: validTargetDuration,
        );
        await provider.updateHabit(updatedHabit);

        // Update notification
        if (_reminderEnabled && reminderTimeStr != null) {
          await NotificationService.scheduleHabitReminder(
            habitId: habit.id.hashCode,
            habitName: updatedHabit.name,
            habitIcon: updatedHabit.icon,
            time: reminderTimeStr,
          );
        } else {
          await NotificationService.cancelHabitReminder(habit.id.hashCode);
        }
      } else {
        // Add new habit
        await provider.addHabit(
          name: nameText,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          icon: _iconController.text.trim().isEmpty ? '🎯' : _iconController.text.trim(),
          category: _selectedCategory,
          weeklyGoal: validWeeklyGoal,
          reminderTime: reminderTimeStr,
          reminderEnabled: _reminderEnabled,
          hasTimer: _hasTimer,
          targetDurationMinutes: validTargetDuration,
        );
        // Schedule notification for new habit
        if (_reminderEnabled && reminderTimeStr != null) {
          final newHabit = provider.habits.last;
          await NotificationService.scheduleHabitReminder(
            habitId: newHabit.id.hashCode,
            habitName: newHabit.name,
            habitIcon: newHabit.icon,
            time: reminderTimeStr,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.habitId != null ? 'Habit updated!' : 'Habit created!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        Navigator.pop(context);
      } else {
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
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
                      hintText: 'Enter an emoji (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.emoji_emotions),
                    ),
                    maxLength: 2,
                    onChanged: (value) {
                      setState(() {});
                    },
                    // Icon is optional - will default to 🎯 if empty
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

            const SizedBox(height: 24),

            // Category selection
            Text(
              'Category (Optional)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: habitCategories.map((category) {
                final isSelected = _selectedCategory == category.name;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.icon),
                      const SizedBox(width: 4),
                      Text(category.name),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category.name : null;
                    });
                  },
                  selectedColor: category.color.withValues(alpha: 0.2),
                  checkmarkColor: category.color,
                  avatar: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: isSelected ? category.color : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Weekly Goal
            TextFormField(
              controller: _weeklyGoalController,
              decoration: const InputDecoration(
                labelText: 'Weekly Goal (Optional)',
                hintText: 'Enter a number 1-7 (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.track_changes),
                helperText: 'Leave empty for daily completion, or enter 1-7 (invalid entries are ignored)',
              ),
              keyboardType: TextInputType.number,
              // Optional: invalid entries are silently ignored when saving
              validator: (_) => null,
            ),

            const SizedBox(height: 24),

            // Timer settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined),
                        const SizedBox(width: 8),
                        Text(
                          'Timer',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Enable timer for this habit'),
                      subtitle: const Text('Track time spent (e.g., studying, working out)'),
                      value: _hasTimer,
                      onChanged: (value) {
                        setState(() {
                          _hasTimer = value;
                        });
                      },
                    ),
                    if (_hasTimer) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _targetDurationController,
                        decoration: const InputDecoration(
                          labelText: 'Target Duration (Optional)',
                          hintText: 'e.g., 30 (minutes per day)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.track_changes),
                          helperText: 'Set a daily goal in minutes',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final duration = int.tryParse(value);
                            if (duration == null || duration < 1) {
                              return 'Please enter a valid number (minutes)';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Reminder settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_outlined),
                        const SizedBox(width: 8),
                        Text(
                          'Reminder',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Enable daily reminder'),
                      subtitle: const Text('Get notified to complete your habit'),
                      value: _reminderEnabled,
                      onChanged: (value) {
                        setState(() {
                          _reminderEnabled = value;
                        });
                      },
                    ),
                    if (_reminderEnabled) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectReminderTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Reminder Time',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(
                            _reminderTime != null
                                ? _reminderTime!.format(context)
                                : 'Tap to select time',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _isSaving ? null : _saveHabit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isSaving
                    ? 'Saving...'
                    : isEditing
                        ? 'Update Habit'
                        : 'Create Habit',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

