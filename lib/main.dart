import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/add_habit_screen_enhanced.dart';
import 'services/notification_service.dart';
import 'services/profile_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service (simplified version)
  await NotificationService.initialize();
  await ProfileService.init();
  final initialProfileId = await ProfileService.getActiveProfileId();
  
  runApp(MyApp(initialProfileId: initialProfileId));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialProfileId});

  final String initialProfileId;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..load()),
        ChangeNotifierProvider(create: (_) => HabitProvider()..initialize(profileId: initialProfileId)),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeProvider>().themeMode;
          return MaterialApp(
            title: 'Health Habit Tracker',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4361EE), // modern blue
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF7F8FB),
              cardTheme: CardThemeData(
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.08),
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: false,
                elevation: 0,
                scrolledUnderElevation: 1,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF3B82F6), // Lighter blue for dark mode
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF0B1220),
              cardTheme: CardThemeData(
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.5),
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: false,
                elevation: 0,
                scrolledUnderElevation: 1,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ),
            themeMode: themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

/// Main screen with bottom navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const StatsScreen(),
    const AchievementsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddHabitScreenEnhanced(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Awards',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

