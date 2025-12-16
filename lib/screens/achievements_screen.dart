import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/achievement_badge.dart';

/// Achievements screen showing unlocked badges
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        elevation: 0,
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          final achievements = getAchievements(
            bestStreak: provider.bestStreak,
            totalHabits: provider.totalHabits,
            overallPercentage: provider.overallCompletionPercentage,
            totalDaysTracked: 30, // Can be calculated from habit history
          );

          final unlockedCount = achievements.where((a) => a.unlocked).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$unlockedCount / ${achievements.length}',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Achievements Unlocked',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: unlockedCount / achievements.length,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Achievements list
              ...achievements.map((achievement) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AchievementBadge(
                      title: achievement.title,
                      description: achievement.description,
                      icon: achievement.icon,
                      color: achievement.color,
                      unlocked: achievement.unlocked,
                      isLegendary: achievement.isLegendary,
                      isSecret: achievement.isSecret,
                      progress: achievement.progress,
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

