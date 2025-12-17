import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import 'export_screen.dart';
import '../services/notification_service.dart'; // TESTING: Remove after testing notifications

/// Settings screen with app options
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profiles
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profiles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Consumer2<ProfileProvider, HabitProvider>(
                    builder: (context, profiles, habits, _) {
                      if (profiles.isLoading || profiles.activeProfile == null) {
                        return const LinearProgressIndicator();
                      }
                      final active = profiles.activeProfile!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Text(active.avatar, style: const TextStyle(fontSize: 28)),
                            title: Text(active.name, style: Theme.of(context).textTheme.titleMedium),
                            subtitle: const Text('Active profile'),
                            trailing: TextButton(
                              onPressed: () => _showProfileSwitcher(context, profiles, habits),
                              child: const Text('Switch'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // TESTING: Remove this entire notification test section after testing
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '🔔 Notification Testing',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.orange),
                  title: const Text('Test Notification'),
                  subtitle: const Text('Send a test notification now'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    await NotificationService.showImmediateNotification(
                      title: '🎉 Test Notification',
                      body: 'Your notifications are working perfectly!',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification sent! Check your notification bar.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt, color: Colors.orange),
                  title: const Text('View Pending Notifications'),
                  subtitle: const Text('See all scheduled notifications'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final pending = await NotificationService.getPendingNotifications();
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Pending Notifications'),
                          content: pending.isEmpty
                              ? const Text('No pending notifications')
                              : SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: pending.length,
                                    itemBuilder: (ctx, i) {
                                      final notif = pending[i];
                                      return ListTile(
                                        title: Text(notif.title ?? 'No title'),
                                        subtitle: Text(notif.body ?? 'No body'),
                                        dense: true,
                                      );
                                    },
                                  ),
                                ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // END TESTING

          const SizedBox(height: 16),

          // Appearance
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    final currentMode = themeProvider.themeMode;
                    return SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.settings_suggest_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                      selected: {currentMode},
                      onSelectionChanged: (value) {
                        final mode = value.firstOrNull ?? ThemeMode.system;
                        themeProvider.setThemeMode(mode);
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // App info section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('App Version'),
                  subtitle: Text('1.0.2 (future updates soon!)'),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('About'),
                  subtitle: const Text('Health Habit Tracker'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Health Habit Tracker',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.self_improvement, size: 48),
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'A simple and beautiful habit tracking app to help you build healthy daily habits.  -made by Bil and Mark :)',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Data management section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Consumer<HabitProvider>(
                  builder: (context, provider, child) {
                    return ListTile(
                      leading: const Icon(Icons.delete_outline, color: Colors.red),
                      title: const Text('Clear All Habits'),
                      subtitle: const Text('Permanently delete all habits'),
                      onTap: provider.habits.isEmpty
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Clear All Habits'),
                                    content: const Text(
                                      'Are you sure you want to delete all habits? This action cannot be undone.',
                                    ),
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
                                        child: const Text('Delete All'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmed == true && context.mounted) {
                                // Delete all habits
                                for (var habit in provider.habits) {
                                  await provider.deleteHabit(habit.id);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('All habits deleted'),
                                    ),
                                  );
                                }
                              }
                            },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Data export section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Data Export',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Export Data'),
                  subtitle: const Text('Export habits as CSV or text'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExportScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Help section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Help',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('How to Use'),
                  subtitle: const Text('Tap a habit to mark it complete for today'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('How to Use'),
                          content: const SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '• Tap the + button to add a new habit',
                                  style: TextStyle(height: 1.5),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '• Tap a habit card to mark it as complete for today',
                                  style: TextStyle(height: 1.5),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '• Swipe left on a habit to delete it',
                                  style: TextStyle(height: 1.5),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '• Check the Statistics tab to see your progress',
                                  style: TextStyle(height: 1.5),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '• Build streaks by completing habits daily!',
                                  style: TextStyle(height: 1.5),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Got it'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileSwitcher(BuildContext context, ProfileProvider profiles, HabitProvider habits) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final list = profiles.profiles;
        final activeId = profiles.activeProfile?.id;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Switch Profile', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (list.isEmpty)
                const Text('No other profiles yet. Add one below.'),
              ...list.map((p) {
                final isActive = p.id == activeId;
                return ListTile(
                  leading: Text(p.avatar, style: const TextStyle(fontSize: 24)),
                  title: Text(p.name),
                  trailing: isActive ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () async {
                    Navigator.pop(context);
                    await profiles.switchProfile(p.id);
                    await habits.loadForProfile(p.id);
                  },
                );
              }),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _showCreateProfileDialog(context, profiles, habits);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Profile'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCreateProfileDialog(BuildContext context, ProfileProvider profiles, HabitProvider habits) async {
    final nameController = TextEditingController();
    final avatarController = TextEditingController(text: '🙂');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: avatarController,
                decoration: const InputDecoration(labelText: 'Avatar (emoji)'),
                maxLength: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
          ],
        );
      },
    );
    if (result == true) {
      final name = nameController.text.trim().isEmpty ? 'Profile' : nameController.text.trim();
      final avatar = avatarController.text.trim().isEmpty ? '🙂' : avatarController.text.trim();
      final profile = await profiles.createProfile(name: name, avatar: avatar);
      await profiles.switchProfile(profile.id);
      await habits.loadForProfile(profile.id);
    }
  }
}