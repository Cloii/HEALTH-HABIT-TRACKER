import 'package:hive/hive.dart';
import 'timer_session.dart';

part 'habit.g.dart';

/// Data model for a habit
/// Represents a single habit that users can track daily
@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String icon; // Emoji or icon string

  @HiveField(4)
  DateTime createdDate;

  @HiveField(5)
  List<DateTime> checkInHistory; // List of dates when habit was completed

  @HiveField(6)
  String? category; // Category: Health, Fitness, Productivity, Learning, etc.

  @HiveField(7)
  int? weeklyGoal; // Weekly goal (e.g., 5 out of 7 days)

  @HiveField(8)
  String? reminderTime; // Reminder time in HH:mm format (e.g., "09:00")

  @HiveField(9)
  bool? reminderEnabled; // Whether reminder is enabled (nullable for backward compatibility)

  @HiveField(10)
  bool hasTimer; // Whether this habit uses a timer

  @HiveField(11)
  List<TimerSession> timerSessions; // List of timer sessions

  @HiveField(12)
  int? targetDurationMinutes; // Target duration in minutes (optional goal)

  Habit({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.createdDate,
    List<DateTime>? checkInHistory,
    this.category,
    this.weeklyGoal,
    this.reminderTime,
    bool? reminderEnabled,
    this.hasTimer = false,
    List<TimerSession>? timerSessions,
    this.targetDurationMinutes,
  }) : checkInHistory = checkInHistory ?? [],
        timerSessions = timerSessions ?? [] {
    // Ensure reminderEnabled is never null
    this.reminderEnabled = reminderEnabled ?? false;
  }

  /// Check if habit was completed today
  bool isCompletedToday() {
    final today = DateTime.now();
    return checkInHistory.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  /// Get current streak (consecutive days completed)
  int getCurrentStreak() {
    if (checkInHistory.isEmpty) return 0;

    // Sort dates in descending order (most recent first)
    final sortedDates = List<DateTime>.from(checkInHistory)
      ..sort((a, b) => b.compareTo(a));

    // Remove duplicates (same day) and sort
    final uniqueDates = <DateTime>[];
    for (var date in sortedDates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (uniqueDates.isEmpty ||
          uniqueDates.last.day != normalizedDate.day ||
          uniqueDates.last.month != normalizedDate.month ||
          uniqueDates.last.year != normalizedDate.year) {
        uniqueDates.add(normalizedDate);
      }
    }

    if (uniqueDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final yesterdayNormalized = todayNormalized.subtract(const Duration(days: 1));

    // Check if today or yesterday was completed (streak continues)
    if (uniqueDates.first.day != todayNormalized.day &&
        uniqueDates.first.day != yesterdayNormalized.day &&
        uniqueDates.first.month != todayNormalized.month &&
        uniqueDates.first.month != yesterdayNormalized.month) {
      return 0; // Streak broken
    }

    int streak = 1;
    DateTime expectedDate = uniqueDates.first;

    for (int i = 1; i < uniqueDates.length; i++) {
      final previousDate = expectedDate.subtract(const Duration(days: 1));
      final normalizedPrevious = DateTime(
        previousDate.year,
        previousDate.month,
        previousDate.day,
      );
      final currentNormalized = DateTime(
        uniqueDates[i].year,
        uniqueDates[i].month,
        uniqueDates[i].day,
      );

      if (normalizedPrevious.day == currentNormalized.day &&
          normalizedPrevious.month == currentNormalized.month &&
          normalizedPrevious.year == currentNormalized.year) {
        streak++;
        expectedDate = previousDate;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get completion percentage for the last 30 days
  double getCompletionPercentage({int days = 30}) {
    if (days <= 0) return 0.0;

    final today = DateTime.now();
    int completedDays = 0;

    for (var date in checkInHistory) {
      final difference = today.difference(date).inDays;
      if (difference >= 0 && difference < days) {
        completedDays++;
      }
    }

    return (completedDays / days) * 100;
  }

  /// Toggle today's completion status
  void toggleToday() {
    final today = DateTime.now();
    if (isCompletedToday()) {
      // Remove today's check-in
      checkInHistory.removeWhere((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);
    } else {
      // Add today's check-in
      checkInHistory.add(today);
    }
  }

  /// Get weekly completion count (current week)
  int getWeeklyCompletionCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    int count = 0;
    for (var date in checkInHistory) {
      if (date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          date.isBefore(weekEnd.add(const Duration(days: 1)))) {
        count++;
      }
    }
    return count;
  }

  /// Check if weekly goal is met
  bool isWeeklyGoalMet() {
    if (weeklyGoal == null) return false;
    return getWeeklyCompletionCount() >= weeklyGoal!;
  }

  /// Get weekly progress percentage
  double getWeeklyProgressPercentage() {
    if (weeklyGoal == null || weeklyGoal == 0) return 0.0;
    final completed = getWeeklyCompletionCount();
    return (completed / weeklyGoal!) * 100;
  }

  /// Add a timer session
  void addTimerSession(TimerSession session) {
    timerSessions.add(session);
    // Also add to check-in history if not already there
    final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
    if (!checkInHistory.any((date) =>
        date.year == sessionDate.year &&
        date.month == sessionDate.month &&
        date.day == sessionDate.day)) {
      checkInHistory.add(sessionDate);
    }
  }

  /// Get total timer duration for today (in seconds)
  int getTodayTimerDuration() {
    final today = DateTime.now();
    return timerSessions
        .where((session) =>
            session.date.year == today.year &&
            session.date.month == today.month &&
            session.date.day == today.day)
        .fold(0, (sum, session) => sum + session.durationSeconds);
  }

  /// Get total timer duration for this week (in seconds)
  int getWeeklyTimerDuration() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return timerSessions
        .where((session) => session.date.isAfter(weekStart.subtract(const Duration(days: 1))))
        .fold(0, (sum, session) => sum + session.durationSeconds);
  }

  /// Get total timer duration for all time (in seconds)
  int getTotalTimerDuration() {
    return timerSessions.fold(0, (sum, session) => sum + session.durationSeconds);
  }

  /// Get average session duration (in minutes)
  double getAverageSessionDuration() {
    if (timerSessions.isEmpty) return 0.0;
    return getTotalTimerDuration() / timerSessions.length / 60.0;
  }

  /// Check if daily timer goal is met
  bool isDailyTimerGoalMet() {
    if (targetDurationMinutes == null || targetDurationMinutes! <= 0) return false;
    return getTodayTimerDuration() >= (targetDurationMinutes! * 60);
  }

  /// Copy with method for updating habits
  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    DateTime? createdDate,
    List<DateTime>? checkInHistory,
    String? category,
    int? weeklyGoal,
    String? reminderTime,
    bool? reminderEnabled,
    bool? hasTimer,
    List<TimerSession>? timerSessions,
    int? targetDurationMinutes,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      createdDate: createdDate ?? this.createdDate,
      checkInHistory: checkInHistory ?? List.from(this.checkInHistory),
      category: category ?? this.category,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? (this.reminderEnabled ?? false),
      hasTimer: hasTimer ?? this.hasTimer,
      timerSessions: timerSessions ?? List.from(this.timerSessions),
      targetDurationMinutes: targetDurationMinutes ?? this.targetDurationMinutes,
    );
  }
}

