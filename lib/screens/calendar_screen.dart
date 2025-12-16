import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

/// Calendar view showing habit check-ins over time
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime.now();
              });
            },
            tooltip: 'Today',
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No habits to display',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Month selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Calendar grid
              Expanded(
                child: _buildCalendar(context, provider.habits),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, List<Habit> habits) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstDayOfWeek = firstDay.weekday;
    final daysInMonth = lastDay.day;

    // Get all check-in dates for the month
    final checkInDates = <DateTime>{};
    for (var habit in habits) {
      for (var date in habit.checkInHistory) {
        if (date.year == _selectedMonth.year && date.month == _selectedMonth.month) {
          checkInDates.add(DateTime(date.year, date.month, date.day));
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar days
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: firstDayOfWeek - 1 + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstDayOfWeek - 1) {
                  return const SizedBox.shrink();
                }

                final day = index - (firstDayOfWeek - 1) + 1;
                final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;
                final hasCheckIns = checkInDates.contains(date);

                // Determine if date was missed (past date without check-in)
                final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                final wasMissed = isPast && !hasCheckIns && date.isBefore(DateTime.now());
                
                return Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? Theme.of(context).colorScheme.primaryContainer
                        : hasCheckIns
                            ? Colors.green.withValues(alpha: 0.3) // Green for completed
                            : wasMissed
                                ? Colors.grey.withValues(alpha: 0.2) // Gray for missed
                                : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: isToday
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.5,
                          )
                        : hasCheckIns
                            ? Border.all(
                                color: Colors.green,
                                width: 1.5,
                              )
                            : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : hasCheckIns
                                      ? Colors.green.shade800
                                      : wasMissed
                                          ? Colors.grey
                                          : Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      if (hasCheckIns)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        )
                      else if (wasMissed)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Legend
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  context,
                  'Today',
                  Theme.of(context).colorScheme.primaryContainer,
                  hasBorder: true,
                ),
                _buildLegendItem(
                  context,
                  'Completed',
                  Colors.green.withValues(alpha: 0.3),
                ),
                _buildLegendItem(
                  context,
                  'Missed',
                  Colors.grey.withValues(alpha: 0.2),
                ),
                _buildLegendItem(
                  context,
                  'Not completed',
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color, {
    bool hasBorder = false,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: hasBorder
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

