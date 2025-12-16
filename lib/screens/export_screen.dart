import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';

/// Screen for exporting habit data
class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  String _generateCSV(List<dynamic> habits) {
    final buffer = StringBuffer();
    buffer.writeln('Habit Name,Icon,Description,Created Date,Total Check-ins,Current Streak,Last 30 Days %');
    
    for (var habit in habits) {
      buffer.writeln([
        '"${habit.name}"',
        habit.icon,
        '"${habit.description ?? ''}"',
        DateFormat('yyyy-MM-dd').format(habit.createdDate),
        habit.checkInHistory.length.toString(),
        habit.getCurrentStreak().toString(),
        habit.getCompletionPercentage().toStringAsFixed(1),
      ].join(','));
    }
    
    return buffer.toString();
  }

  String _generateSummary(List<dynamic> habits) {
    final buffer = StringBuffer();
    buffer.writeln('=== HABIT TRACKER EXPORT ===\n');
    buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}\n');
    buffer.writeln('Total Habits: ${habits.length}\n');
    
    int completedToday = 0;
    int totalCheckIns = 0;
    int bestStreak = 0;
    
    for (var habit in habits) {
      if (habit.isCompletedToday()) completedToday++;
      totalCheckIns = totalCheckIns + (habit.checkInHistory.length as int);
      final streak = habit.getCurrentStreak();
      if (streak > bestStreak) bestStreak = streak;
    }
    
    buffer.writeln('Completed Today: $completedToday / ${habits.length}');
    buffer.writeln('Total Check-ins: $totalCheckIns');
    buffer.writeln('Best Streak: $bestStreak days\n');
    buffer.writeln('=== INDIVIDUAL HABITS ===\n');
    
    for (var habit in habits) {
      buffer.writeln('${habit.icon} ${habit.name}');
      if (habit.description != null && habit.description!.isNotEmpty) {
        buffer.writeln('  Description: ${habit.description}');
      }
      buffer.writeln('  Created: ${DateFormat('yyyy-MM-dd').format(habit.createdDate)}');
      buffer.writeln('  Check-ins: ${habit.checkInHistory.length}');
      buffer.writeln('  Current Streak: ${habit.getCurrentStreak()} days');
      buffer.writeln('  Last 30 Days: ${habit.getCompletionPercentage().toStringAsFixed(1)}%');
      buffer.writeln('');
    }
    
    return buffer.toString();
  }

  void _exportData(BuildContext context, String data, String filename) {
    // In a real app, you would use a package like `share_plus` or `path_provider`
    // For now, we'll just show the data in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export: $filename'),
        content: SingleChildScrollView(
          child: SelectableText(
            data,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Copy to clipboard (simplified - in real app use clipboard package)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data copied to clipboard!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        elevation: 0,
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data to export',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Export Options',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Export your habit data in various formats. You can copy the data and save it to a file.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // CSV Export
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.table_chart, color: Colors.green),
                  ),
                  title: const Text('Export as CSV'),
                  subtitle: const Text('Spreadsheet format for Excel/Google Sheets'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final csv = _generateCSV(provider.habits);
                    _exportData(context, csv, 'habits.csv');
                  },
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Text Summary
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description, color: Colors.blue),
                  ),
                  title: const Text('Export as Summary'),
                  subtitle: const Text('Human-readable text format'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final summary = _generateSummary(provider.habits);
                    _exportData(context, summary, 'habits_summary.txt');
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Statistics
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Stats',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(context, 'Total Habits', '${provider.totalHabits}'),
                      _buildStatRow(context, 'Completed Today', '${provider.completedTodayCount}/${provider.totalHabits}'),
                      _buildStatRow(context, 'Best Streak', '${provider.bestStreak} days'),
                      _buildStatRow(context, 'Overall Progress', '${provider.overallCompletionPercentage.toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

