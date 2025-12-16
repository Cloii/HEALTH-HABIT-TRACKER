import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../models/timer_session.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

/// Provider class for managing habit state
/// Handles all business logic related to habits
class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  /// Initialize the provider and load habits from database
  Future<void> initialize({String profileId = 'default'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await DatabaseService.init(profileId: profileId);
      _habits = DatabaseService.getAllHabits();
      
      // Ensure all habits have reminderEnabled set (for backward compatibility with old data)
      bool needsSave = false;
      for (var habit in _habits) {
        if (habit.reminderEnabled == null) {
          // Fix old habits that don't have reminderEnabled
          final updatedHabit = habit.copyWith(reminderEnabled: false);
          _habits[_habits.indexOf(habit)] = updatedHabit;
          await DatabaseService.updateHabit(updatedHabit);
          needsSave = true;
        }
      }
      if (needsSave) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadForProfile(String profileId) async {
    await initialize(profileId: profileId);
  }

  /// Add a new habit
  Future<void> addHabit({
    required String name,
    String? description,
    required String icon,
    String? category,
    int? weeklyGoal,
    String? reminderTime,
    bool reminderEnabled = false,
    bool hasTimer = false,
    int? targetDurationMinutes,
  }) async {
    try {
      final habit = Habit(
        id: const Uuid().v4(),
        name: name,
        description: description,
        icon: icon,
        createdDate: DateTime.now(),
        category: category,
        weeklyGoal: weeklyGoal,
        reminderTime: reminderTime,
        reminderEnabled: reminderEnabled, // This will be converted to non-null in constructor
        hasTimer: hasTimer,
        targetDurationMinutes: targetDurationMinutes,
      );

      await DatabaseService.saveHabit(habit);
      _habits.add(habit);
      notifyListeners();
      debugPrint('Habit added: ${habit.name}, Total habits: ${_habits.length}');
    } catch (e) {
      debugPrint('Error adding habit: $e');
      rethrow;
    }
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit habit) async {
    try {
      await DatabaseService.updateHabit(habit);
      
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
        notifyListeners();
        debugPrint('Habit updated: ${habit.name}');
      } else {
        debugPrint('Warning: Habit not found in list: ${habit.id}');
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow;
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      await DatabaseService.deleteHabit(habitId);
      final initialLength = _habits.length;
      _habits.removeWhere((habit) => habit.id == habitId);
      notifyListeners();
      debugPrint('Habit deleted: $habitId, Remaining: ${_habits.length} (was $initialLength)');
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      rethrow;
    }
  }

  /// Toggle today's completion status for a habit
  Future<void> toggleHabitCompletion(String habitId) async {
    try {
      final habit = _habits.firstWhere((h) => h.id == habitId);
      habit.toggleToday();
      await DatabaseService.updateHabit(habit);
      notifyListeners();
      debugPrint('Habit completion toggled: ${habit.name}, Completed: ${habit.isCompletedToday()}');
    } catch (e) {
      debugPrint('Error toggling habit completion: $e');
      rethrow;
    }
  }

  /// Get total number of habits
  int get totalHabits => _habits.length;

  /// Get total number of completed habits today
  int get completedTodayCount {
    return _habits.where((habit) => habit.isCompletedToday()).length;
  }

  /// Get overall completion percentage
  double get overallCompletionPercentage {
    if (_habits.isEmpty) return 0.0;
    
    double total = 0;
    for (var habit in _habits) {
      total += habit.getCompletionPercentage();
    }
    
    return total / _habits.length;
  }

  /// Get the best streak across all habits
  int get bestStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.getCurrentStreak()).reduce((a, b) => a > b ? a : b);
  }

  /// Add a timer session to a habit
  Future<void> addTimerSession(String habitId, int durationSeconds) async {
    try {
      final habit = _habits.firstWhere((h) => h.id == habitId);
      final now = DateTime.now();
      final session = TimerSession(
        startTime: now.subtract(Duration(seconds: durationSeconds)),
        endTime: now,
        durationSeconds: durationSeconds,
        date: now,
      );
      habit.addTimerSession(session);
      await DatabaseService.updateHabit(habit);
      notifyListeners();
      debugPrint('Timer session added: ${habit.name}, Duration: ${session.formattedDuration}');
    } catch (e) {
      debugPrint('Error adding timer session: $e');
      rethrow;
    }
  }
}

