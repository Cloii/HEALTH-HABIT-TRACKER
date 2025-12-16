import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../utils/categories.dart';
import '../screens/timer_screen.dart';

/// Custom card widget for displaying a single habit
/// Shows habit details, completion status, and streak information
class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _checkAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _checkAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _checkScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void didUpdateWidget(HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habit.isCompletedToday() != oldWidget.habit.isCompletedToday()) {
      if (widget.habit.isCompletedToday()) {
        _checkAnimationController.forward(from: 0);
      } else {
        _checkAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _checkAnimationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
      widget.onTap();
    });
  }

  String _formatTimerDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.habit.isCompletedToday();
    final streak = widget.habit.getCurrentStreak();
    final category = getCategoryByName(widget.habit.category);
    final weeklyGoal = widget.habit.weeklyGoal;
    final weeklyProgress = weeklyGoal != null ? widget.habit.getWeeklyCompletionCount() : null;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: isCompleted ? 4 : 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isCompleted
                ? LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      Theme.of(context).colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon/Emoji with animated background
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: !isCompleted
                          ? Theme.of(context).colorScheme.surfaceContainerHighest
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        widget.habit.icon,
                        style: TextStyle(
                          fontSize: 32,
                          shadows: isCompleted
                              ? [
                                  Shadow(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Habit details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted
                                    ? Theme.of(context).colorScheme.onSurfaceVariant
                                    : null,
                              ),
                        ),
                        if (widget.habit.description != null &&
                            widget.habit.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.habit.description!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Category and indicators row
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // Category badge
                            if (category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: category.color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: category.color.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      category.icon,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      category.name,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: category.color,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            // Streak indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: streak > 0
                                    ? Colors.orange.withValues(alpha: 0.1)
                                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 14,
                                    color: streak > 0 ? Colors.orange : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$streak day${streak != 1 ? 's' : ''}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: streak > 0 ? Colors.orange : Colors.grey,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            // Weekly goal progress
                            if (weeklyGoal != null && weeklyProgress != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.habit.isWeeklyGoalMet()
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.habit.isWeeklyGoalMet()
                                          ? Icons.check_circle
                                          : Icons.track_changes,
                                      size: 14,
                                      color: widget.habit.isWeeklyGoalMet()
                                          ? Colors.green
                                          : Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$weeklyProgress/$weeklyGoal',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: widget.habit.isWeeklyGoalMet()
                                                ? Colors.green
                                                : Colors.blue,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            // Timer stats (if timer is enabled)
                            if (widget.habit.hasTimer) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      size: 14,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTimerDuration(widget.habit.getTodayTimerDuration()),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                    ),
                                    if (widget.habit.targetDurationMinutes != null) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '/ ${widget.habit.targetDurationMinutes}m',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      if (widget.habit.isDailyTimerGoalMet()) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.emoji_events,
                                          size: 12,
                                          color: Colors.amber,
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Timer button (if habit has timer enabled)
                      if (widget.habit.hasTimer)
                        IconButton(
                          icon: Icon(
                            Icons.timer_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TimerScreen(habit: widget.habit),
                              ),
                            );
                          },
                          tooltip: 'Start timer',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      // Edit button
                      if (widget.onEdit != null) ...[
                        if (widget.habit.hasTimer) const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          onPressed: widget.onEdit,
                          tooltip: 'Edit habit',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                      const SizedBox(width: 8),
                      // Animated checkbox/Completion indicator
                      ScaleTransition(
                        scale: _checkScaleAnimation,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                              width: 2.5,
                            ),
                            boxShadow: isCompleted
                                ? [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isCompleted
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 22,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

