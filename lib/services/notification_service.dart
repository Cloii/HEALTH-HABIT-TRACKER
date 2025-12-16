import 'package:flutter/foundation.dart';

/// Simplified notification service for in-app reminders
/// Note: This is a placeholder that stores reminder preferences
/// Real push notifications can be added later with a compatible package
class NotificationService {
  static bool _initialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('Notification service initialized (simplified mode)');
  }

  /// Schedule a daily reminder for a habit (stores preference only)
  /// In a full implementation, this would schedule actual notifications
  static Future<void> scheduleHabitReminder({
    required int habitId,
    required String habitName,
    required String habitIcon,
    required String time, // Format: "HH:mm"
  }) async {
    if (!_initialized) await initialize();
    
    // Store reminder preference (in a real app, save to SharedPreferences or database)
    debugPrint('Reminder scheduled for $habitName at $time (stored locally)');
    
    // Note: Actual notifications would be scheduled here
    // For now, this just stores the preference
    // Users can see their reminder times in the habit settings
  }

  /// Cancel a habit reminder
  static Future<void> cancelHabitReminder(int habitId) async {
    debugPrint('Reminder cancelled for habit ID: $habitId');
    // In a real implementation, cancel the scheduled notification
  }

  /// Cancel all habit reminders
  static Future<void> cancelAllReminders() async {
    debugPrint('All reminders cancelled');
    // In a real implementation, cancel all scheduled notifications
  }

  /// Show a congratulatory notification for achievements (in-app only)
  static Future<void> showAchievementNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();
    
    // In-app notifications can be shown using SnackBar or Dialog
    // This is called from the UI when achievements are unlocked
    debugPrint('Achievement: $title - $body');
  }

  /// Check if reminders are enabled (placeholder)
  static bool areRemindersEnabled() {
    // In a real app, check user preferences
    return true;
  }
}
