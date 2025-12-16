import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen_enhanced.dart' as enhanced;

/// Home screen displaying all habits with today's check-in status
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Consumer<HabitProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

          // Calculate today's progress
            final completedCount = provider.completedTodayCount;
            final totalCount = provider.totalHabits;
            final progress = totalCount > 0 ? (completedCount / totalCount) * 100 : 0.0;
            final today = DateTime.now();
            final weekday = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][today.weekday - 1];
            final filteredHabits = provider.habits;
            final focusHabits = provider.habits
                .where((h) => !h.isCompletedToday())
                .toList()
              ..sort((a, b) => b.getCurrentStreak().compareTo(a.getCurrentStreak()));
            final topFocus = focusHabits.take(3).toList();
            final avg7Day = provider.habits.isEmpty
                ? 0.0
                : provider.habits
                        .map((h) => h.getCompletionPercentage(days: 7))
                        .fold<double>(0, (a, b) => a + b) /
                    provider.habits.length;
            final bottomPadding = MediaQuery.of(context).padding.bottom + 24;

            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${weekday.toUpperCase()}, ${today.day}',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.85),
                                    letterSpacing: 0.5,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Good ${today.hour < 12 ? 'morning' : today.hour < 18 ? 'afternoon' : 'evening'}!',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Removed brightness and settings icons as requested
                      ],
                    ),
                  ),
                ),

                // Streak health + focus
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Streak Health',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              '${avg7Day.toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (avg7Day / 100).clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              avg7Day >= 75
                                  ? Colors.greenAccent
                                  : avg7Day >= 40
                                      ? Colors.amber
                                      : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          avg7Day >= 75
                              ? '🔥 You are protecting your streaks.'
                              : avg7Day >= 40
                                  ? 'Almost there. Hit one more habit today.'
                                  : 'Do one quick habit to boost your streak health.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.85),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (topFocus.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Focus Now',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${topFocus.length} picks',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: topFocus.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final habit = topFocus[index];
                                final streak = habit.getCurrentStreak();
                                return Container(
                                  width: 200,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                                        Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.2),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(habit.icon, style: const TextStyle(fontSize: 24)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              habit.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.local_fire_department, color: Colors.orange, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${streak}d',
                                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                        color: Colors.orange,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                            onPressed: () {
                                              provider.toggleHabitCompletion(habit.id);
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context).colorScheme.primary,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: const Text('Mark done'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Search removed per request

                // Enhanced Today's progress card
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35),
                            Theme.of(context).colorScheme.primary.withOpacity(0.35),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    weekday,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Today\'s Progress',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  progress == 100 ? Icons.celebration : Icons.track_changes,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                '$completedCount',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              Text(
                                ' / $totalCount',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.75),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  '${progress.toStringAsFixed(0)}%',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              minHeight: 12,
                              backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.25),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Habits list
                if (filteredHabits.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No habits yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start building your streak today by adding\nyour first daily ritual.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const enhanced.AddHabitScreenEnhanced(),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 6,
                            shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                          ),
                          child: const Text('Create First Habit'),
                        ),
                      ],
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final habit = filteredHabits[index];
                        return Dismissible(
                          key: Key(habit.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Habit'),
                                  content: Text('Are you sure you want to delete "${habit.name}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            ) ?? false;
                          },
                          onDismissed: (direction) {
                            provider.deleteHabit(habit.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${habit.name} deleted'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    // Note: Undo functionality would require saving deleted habit temporarily
                                  },
                                ),
                              ),
                            );
                          },
                          child: HabitCard(
                            habit: habit,
                            onTap: () {
                              provider.toggleHabitCompletion(habit.id);
                            },
                            onDelete: () {
                              provider.deleteHabit(habit.id);
                            },
                            onEdit: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => enhanced.AddHabitScreenEnhanced(habitId: habit.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: filteredHabits.length,
                    ),
                  ),
                SliverPadding(padding: EdgeInsets.only(bottom: bottomPadding)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const enhanced.AddHabitScreenEnhanced(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
    );
  }
}