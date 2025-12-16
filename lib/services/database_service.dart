import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../models/timer_session.dart';

/// Service for managing local database operations using Hive
/// Handles CRUD operations for habits
class DatabaseService {
  static const String _boxNameBase = 'habits';
  static String _currentProfileId = 'default';
  static Box<Habit>? _box;

  /// Initialize Hive and open the habits box
  static Future<void> init({String profileId = 'default'}) async {
    await Hive.initFlutter();
    if (_box != null && _currentProfileId == profileId) {
      return;
    }
    _currentProfileId = profileId;
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
    
    // Register the Habit adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitAdapter());
    }

    // Register the TimerSession adapter
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TimerSessionAdapter());
    }

    // Open the habits box for the active profile
    final boxName = '${_boxNameBase}_$profileId';
    _box = await Hive.openBox<Habit>(boxName);
  }

  /// Get all habits from the database
  static List<Habit> getAllHabits() {
    if (_box == null) return [];
    return _box!.values.toList();
  }

  /// Save a habit to the database
  static Future<void> saveHabit(Habit habit) async {
    if (_box == null) await init();
    await _box!.put(habit.id, habit);
  }

  /// Delete a habit from the database
  static Future<void> deleteHabit(String habitId) async {
    if (_box == null) await init();
    await _box!.delete(habitId);
  }

  /// Get a specific habit by ID
  static Habit? getHabitById(String habitId) {
    if (_box == null) return null;
    return _box!.get(habitId);
  }

  /// Update an existing habit
  static Future<void> updateHabit(Habit habit) async {
    if (_box == null) await init();
    await _box!.put(habit.id, habit);
  }

  /// Clear all habits (useful for testing or reset)
  static Future<void> clearAllHabits() async {
    if (_box == null) await init();
    await _box!.clear();
  }

  /// Close the database box
  static Future<void> close() async {
    if (_box != null) {
      await _box!.close();
    }
  }
}

