import 'package:flutter/material.dart';

/// Achievement badge widget
class AchievementBadge extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.unlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked
            ? color.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: unlocked
            ? Border.all(color: color, width: 2)
            : Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unlocked ? color.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: unlocked ? color : Colors.grey,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: unlocked ? color : Colors.grey,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (unlocked)
            Icon(
              Icons.check_circle,
              color: color,
            )
          else
            Icon(
              Icons.lock_outline,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
        ],
      ),
    );
  }
}

/// Check and return achievements based on habit stats
List<AchievementData> getAchievements({
  required int bestStreak,
  required int totalHabits,
  required double overallPercentage,
  required int totalDaysTracked,
}) {
  return [
    AchievementData(
      id: 'first_habit',
      title: 'Getting Started',
      description: 'Created your first habit',
      icon: Icons.star,
      color: Colors.amber,
      unlocked: totalHabits >= 1,
    ),
    AchievementData(
      id: 'streak_3',
      title: 'On Fire!',
      description: '3 day streak',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      unlocked: bestStreak >= 3,
    ),
    AchievementData(
      id: 'streak_7',
      title: 'Week Warrior',
      description: '7 day streak',
      icon: Icons.emoji_events,
      color: Colors.purple,
      unlocked: bestStreak >= 7,
    ),
    AchievementData(
      id: 'streak_30',
      title: 'Unstoppable',
      description: '30 day streak',
      icon: Icons.whatshot,
      color: Colors.red,
      unlocked: bestStreak >= 30,
    ),
    AchievementData(
      id: 'perfection_week',
      title: 'Perfect Week',
      description: '100% completion for 7 days',
      icon: Icons.verified,
      color: Colors.green,
      unlocked: overallPercentage >= 100 && totalDaysTracked >= 7,
    ),
    AchievementData(
      id: 'habit_collector',
      title: 'Habit Collector',
      description: 'Created 5 habits',
      icon: Icons.collections,
      color: Colors.blue,
      unlocked: totalHabits >= 5,
    ),
  ];
}

class AchievementData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;

  AchievementData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
  });
}

