import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/habit_provider.dart';
import '../widgets/custom_widgets.dart';

/// Statistics screen showing completion rates, streaks, and overall progress
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedPeriod = '30'; // 7, 30, or 90 days

  List<int> _computeDailyCompletions(List<dynamic> habits, {int days = 7}) {
    final today = DateTime.now();
    final List<int> counts = List.filled(days, 0);
    for (int i = 0; i < days; i++) {
      final day = today.subtract(Duration(days: i));
      final normalized = DateTime(day.year, day.month, day.day);
      final completed = habits.where((habit) => habit.checkInHistory.any((date) =>
          date.year == normalized.year &&
          date.month == normalized.month &&
          date.day == normalized.day)).length;
      counts[days - 1 - i] = completed; // oldest first
    }
    return counts;
  }

  List<String> _weekdayLabels(int days) {
    final today = DateTime.now();
    final List<String> labels = [];
    for (int i = days - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      labels.add(['M', 'T', 'W', 'T', 'F', 'S', 'S'][day.weekday - 1]);
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title removed as requested
        elevation: 0,
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: '7',
                child: Text('Last 7 days'),
              ),
              const PopupMenuItem(
                value: '30',
                child: Text('Last 30 days'),
              ),
              const PopupMenuItem(
                value: '90',
                child: Text('Last 90 days'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.habits.isEmpty) {
            return const EmptyStateWidget(
              message: 'No statistics available.\nAdd some habits to see your progress!',
              icon: Icons.analytics_outlined,
            );
          }

          // Calculate statistics
          final totalHabits = provider.totalHabits;
          final completedToday = provider.completedTodayCount;
          final overallPercentage = provider.overallCompletionPercentage;
          final bestStreak = provider.bestStreak;
          final dailyCompletions = _computeDailyCompletions(provider.habits, days: 7);
          final dailyLabels = _weekdayLabels(7);
          final maxDaily = (dailyCompletions.isEmpty ? 1 : (dailyCompletions.reduce((a, b) => a > b ? a : b)).clamp(1, 10));

          // Get habits sorted by streak
          final sortedHabits = List.from(provider.habits)
            ..sort((a, b) => b.getCurrentStreak().compareTo(a.getCurrentStreak()));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),

              // Overview stats in tiles
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatTile(
                    label: 'Today\'s Rate',
                    value: '$completedToday',
                    subtitle: totalHabits > 0 ? '/ $totalHabits' : '',
                    icon: Icons.radio_button_checked,
                    color: Colors.blue,
                  ),
                  _StatTile(
                    label: 'Avg Streak',
                    value: '$bestStreak',
                    subtitle: 'days',
                    icon: Icons.flash_on,
                    color: Colors.orange,
                  ),
                  _StatTile(
                    label: '30-day Rate',
                    value: '${provider.overallCompletionPercentage.toStringAsFixed(0)}%',
                    subtitle: '',
                    icon: Icons.trending_up,
                    color: Colors.teal,
                  ),
                  _StatTile(
                    label: 'Perfect Days',
                    value: provider.habits.where((h) => h.isCompletedToday()).length.toString(),
                    subtitle: 'today',
                    icon: Icons.event_available,
                    color: Colors.amber,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Weekly completions chart
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last 7 Days',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (maxDaily + 1).toDouble(),
                            gridData: FlGridData(show: true, horizontalInterval: 1, getDrawingHorizontalLine: (_) => FlLine(color: Theme.of(context).dividerColor, strokeWidth: 0.4)),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 28,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toInt().toString(),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= dailyLabels.length) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        dailyLabels[index],
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: List.generate(dailyCompletions.length, (index) {
                              final val = dailyCompletions[index].toDouble();
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: val,
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completed habits per day (all habits)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

              // Achievement badges section
              if (bestStreak > 0 || overallPercentage > 50)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.1),
                        Colors.amber.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.orange,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Achievements',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bestStreak >= 7
                                  ? '🔥 Amazing! $bestStreak day streak!'
                                  : bestStreak >= 3
                                      ? '💪 Great progress! Keep it up!'
                                      : '⭐ You\'re doing great!',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Individual habit statistics
              Text(
                'Habit Performance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              ...sortedHabits.map((habit) {
                final streak = habit.getCurrentStreak();
                final completionPercentage = habit.getCompletionPercentage(days: int.parse(_selectedPeriod));

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: completionPercentage >= 70
                          ? LinearGradient(
                              colors: [
                                Colors.green.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  habit.icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habit.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (habit.description != null)
                                      Text(
                                        habit.description!,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: completionPercentage >= 70
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : completionPercentage >= 50
                                          ? Colors.orange.withValues(alpha: 0.2)
                                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${completionPercentage.toStringAsFixed(0)}%',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: completionPercentage >= 70
                                            ? Colors.green
                                            : completionPercentage >= 50
                                                ? Colors.orange
                                                : null,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                      size: 16,
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
                              const Spacer(),
                              if (completionPercentage >= 90)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Excellent!',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ProgressIndicatorWidget(
                            percentage: completionPercentage,
                            label: '30-day completion rate',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            const SizedBox(height: 6),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

