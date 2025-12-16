import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

/// Screen for running a timer for a habit
class TimerScreen extends StatefulWidget {
  final Habit habit;

  const TimerScreen({super.key, required this.habit});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) {
      // Resume from pause
      _isPaused = false;
    } else {
      // Start fresh
      _elapsedSeconds = 0;
    }
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _elapsedSeconds = 0;
    });
  }

  Future<void> _saveSession() async {
    if (_elapsedSeconds < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timer must run for at least 1 second'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final provider = Provider.of<HabitProvider>(context, listen: false);
    await provider.addTimerSession(widget.habit.id, _elapsedSeconds);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session saved: ${_formatDuration(_elapsedSeconds)}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final targetMinutes = widget.habit.targetDurationMinutes;
    final targetSeconds = targetMinutes != null ? targetMinutes * 60 : null;
    final progress = targetSeconds != null && targetSeconds > 0
        ? (_elapsedSeconds / targetSeconds).clamp(0.0, 1.0)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.habit.icon} ${widget.habit.name}'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timer display
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Large timer display
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 4,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _formatDuration(_elapsedSeconds),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    if (targetSeconds != null) ...[
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Goal: ${widget.habit.targetDurationMinutes} minutes',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            if (progress != null && progress >= 1.0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Goal achieved!',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Control buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Stop button
                      if (_isRunning || _isPaused)
                        ElevatedButton.icon(
                          onPressed: _stopTimer,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),

                      // Start/Pause button
                      FilledButton.icon(
                        onPressed: _isRunning ? _pauseTimer : _startTimer,
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isRunning ? 'Pause' : _isPaused ? 'Resume' : 'Start'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          minimumSize: const Size(150, 56),
                        ),
                      ),

                      // Save button
                      if (_elapsedSeconds > 0 && !_isRunning)
                        ElevatedButton.icon(
                          onPressed: _saveSession,
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  if (_elapsedSeconds > 0 && !_isRunning && _isPaused) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _saveSession,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Session'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Today's stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        'Today',
                        _formatDuration(widget.habit.getTodayTimerDuration()),
                        Icons.today,
                      ),
                      _buildStatItem(
                        context,
                        'This Week',
                        _formatDuration(widget.habit.getWeeklyTimerDuration()),
                        Icons.calendar_view_week,
                      ),
                      _buildStatItem(
                        context,
                        'Total',
                        _formatDuration(widget.habit.getTotalTimerDuration()),
                        Icons.access_time,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

