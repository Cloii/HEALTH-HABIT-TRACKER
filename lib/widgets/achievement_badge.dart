import 'package:flutter/material.dart';

/// Achievement badge widget

class AchievementBadge extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;
  final bool isLegendary;
  final bool isSecret;
  final double progress; // 0.0 to 1.0 for locked achievements

  const AchievementBadge({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.unlocked = false,
    this.isLegendary = false,
    this.isSecret = false,
    this.progress = 0.0,
  });

  @override
  State<AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _wasUnlocked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    if (widget.unlocked) {
      _controller.forward();
      _wasUnlocked = true;
    }
  }

  @override
  void didUpdateWidget(covariant AchievementBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unlocked && !_wasUnlocked) {
      _controller.forward(from: 0);
      _wasUnlocked = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final isSecret = widget.isSecret && !widget.unlocked;
        final isLegendary = widget.isLegendary;
        return Opacity(
          opacity: widget.unlocked ? _fadeAnim.value : 1.0,
          child: Transform.scale(
            scale: widget.unlocked ? _scaleAnim.value : 1.0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isLegendary
                    ? LinearGradient(colors: [Colors.amber, Colors.deepOrangeAccent, Colors.yellowAccent])
                    : null,
                color: isLegendary
                    ? null
                    : (widget.unlocked
                        ? widget.color.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest),
                borderRadius: BorderRadius.circular(16),
                border: widget.unlocked
                    ? Border.all(color: widget.color, width: 2)
                    : Border.all(
                        color: isLegendary
                            ? Colors.amber.withOpacity(0.7)
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                boxShadow: isLegendary && widget.unlocked
                    ? [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 16, spreadRadius: 2)]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.unlocked
                          ? widget.color.withOpacity(0.2)
                          : isLegendary
                              ? Colors.amber.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSecret ? Icons.help_outline : widget.icon,
                      color: widget.unlocked
                          ? (isLegendary ? Colors.amber : widget.color)
                          : Colors.grey,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSecret ? '???' : widget.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: widget.unlocked
                                    ? (isLegendary ? Colors.amber : widget.color)
                                    : Colors.grey,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSecret ? 'Secret achievement' : widget.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (!widget.unlocked && widget.progress > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: LinearProgressIndicator(
                              value: widget.progress,
                              minHeight: 6,
                              backgroundColor: Colors.grey.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isLegendary ? Colors.amber : widget.color,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.unlocked)
                    Icon(
                      Icons.check_circle,
                      color: isLegendary ? Colors.amber : widget.color,
                    )
                  else if (isSecret)
                    Icon(
                      Icons.lock,
                      color: Colors.grey.withOpacity(0.5),
                    )
                  else
                    Icon(
                      Icons.lock_outline,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
      progress: (totalHabits / 1).clamp(0.0, 1.0),
    ),
    AchievementData(
      id: 'streak_3',
      title: 'On Fire!',
      description: '3 day streak',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      unlocked: bestStreak >= 3,
      progress: (bestStreak / 3).clamp(0.0, 1.0),
    ),
    AchievementData(
      id: 'streak_7',
      title: 'Week Warrior',
      description: '7 day streak',
      icon: Icons.emoji_events,
      color: Colors.purple,
      unlocked: bestStreak >= 7,
      progress: (bestStreak / 7).clamp(0.0, 1.0),
    ),
    AchievementData(
      id: 'streak_30',
      title: 'Unstoppable',
      description: '30 day streak',
      icon: Icons.whatshot,
      color: Colors.red,
      unlocked: bestStreak >= 30,
      progress: (bestStreak / 30).clamp(0.0, 1.0),
      isLegendary: true,
    ),
    AchievementData(
      id: 'perfection_week',
      title: 'Perfect Week',
      description: '100% completion for 7 days',
      icon: Icons.verified,
      color: Colors.green,
      unlocked: overallPercentage >= 100 && totalDaysTracked >= 7,
      progress: (totalDaysTracked / 7).clamp(0.0, 1.0),
    ),
    AchievementData(
      id: 'habit_collector',
      title: 'Habit Collector',
      description: 'Created 5 habits',
      icon: Icons.collections,
      color: Colors.blue,
      unlocked: totalHabits >= 5,
      progress: (totalHabits / 5).clamp(0.0, 1.0),
    ),
    // Secret achievement example
    AchievementData(
      id: 'secret_earlybird',
      title: 'Early Bird',
      description: 'Completed a habit before 6am',
      icon: Icons.wb_twighlight,
      color: Colors.teal,
      unlocked: false, // Set to true if user meets secret condition
      isSecret: true,
      progress: 0.0,
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
  final bool isLegendary;
  final bool isSecret;
  final double progress;

  AchievementData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
    this.isLegendary = false,
    this.isSecret = false,
    this.progress = 0.0,
  });
}

