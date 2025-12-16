import 'package:hive/hive.dart';

part 'timer_session.g.dart';

/// Represents a single timer session for a habit
@HiveType(typeId: 1)
class TimerSession extends HiveObject {
  @HiveField(0)
  DateTime startTime;

  @HiveField(1)
  DateTime? endTime;

  @HiveField(2)
  int durationSeconds; // Total duration in seconds

  @HiveField(3)
  DateTime date; // The date this session was completed

  TimerSession({
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.date,
  });

  /// Get duration in minutes
  int get durationMinutes => durationSeconds ~/ 60;

  /// Get formatted duration string (e.g., "1h 30m" or "45m")
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Get duration in HH:MM:SS format
  String get formattedTime {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

