import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/habit.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions for Android 13+
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  /// Schedule a daily notification for a habit
  static Future<void> scheduleHabitReminder(Habit habit) async {
    if (habit.reminderTime == null || habit.reminderTime!.isEmpty) return;

    try {
      // Parse the time string (format: "HH:mm")
      final timeParts = habit.reminderTime!.split(':');
      if (timeParts.length != 2) {
        print('❌ Invalid time format: ${habit.reminderTime}');
        return;
      }
      
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      // Convert to TZDateTime
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the scheduled time is in the past, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Prepare notification body
      final description = habit.description;
      final body = (description != null && description.isNotEmpty)
          ? description
          : 'Don\'t forget to complete your habit!';

      await _notifications.zonedSchedule(
        habit.id.hashCode, // Unique ID for each habit
        '⏰ Time for ${habit.name}',
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            channelDescription: 'Daily reminders for your habits',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the same time
      );

      print('✅ Scheduled notification for ${habit.name} at $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  /// Cancel a specific habit's notification
  static Future<void> cancelHabitReminder(String habitId) async {
    await _notifications.cancel(habitId.hashCode);
    print('❌ Cancelled notification for habit: $habitId');
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('❌ Cancelled all notifications');
  }

  /// Update a habit's notification (cancel old and schedule new)
  static Future<void> updateHabitReminder(Habit habit) async {
    await cancelHabitReminder(habit.id);
    if (habit.reminderTime != null) {
      await scheduleHabitReminder(habit);
    }
  }

  /// Show an immediate notification (for testing)
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Daily reminders for your habits',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Get all pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}