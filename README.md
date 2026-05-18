# Health Habit Tracker

A clean, simple Flutter app for tracking daily healthy habits. Built with Material Design 3, this app helps you build consistent habits with streak tracking, statistics, and an intuitive interface.

---

## Features

- Add habits with custom names, icons, and descriptions
- Daily check-in by tapping habits
- Streak tracking (consecutive days completed)
- Statistics dashboard with completion percentages
- Swipe to delete habits
- Local data persistence using Hive
- Material Design 3 UI
- Dark mode support

---

## Screenshots

- **Home Screen** — View all habits with today's completion status
- **Statistics Screen** — See completion rates, streaks, and progress
- **Settings Screen** — Manage app preferences and data

---

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio or VS Code with Flutter extensions
- Android/iOS emulator or physical device

### Installation

1. Clone or download the repository.

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Hive adapters:
   ```bash
   flutter pub run build_runner build
   ```

   > **Note:** This will generate the `habit.g.dart` file required for Hive to work. You may see errors in your IDE before running this command — this is expected and will resolve once code generation completes.

4. Run the app:
   ```bash
   flutter run
   ```

---

## Project Structure

```
lib/
├── main.dart                  # App entry point and theme configuration
├── models/
│   └── habit.dart             # Habit data model with Hive annotations
├── screens/
│   ├── home_screen.dart       # Main habit list screen
│   ├── add_habit_screen.dart  # Form to add/edit habits
│   ├── stats_screen.dart      # Statistics and progress view
│   └── settings_screen.dart   # App settings
├── widgets/
│   ├── habit_card.dart        # Reusable habit card widget
│   └── custom_widgets.dart    # Additional UI components
├── services/
│   └── database_service.dart  # Hive database operations
└── providers/
    └── habit_provider.dart    # State management with Provider
```

---

## Usage

### Adding a Habit

1. Tap the **+** button on the home screen.
2. Choose an emoji icon or type your own.
3. Enter a habit name (required).
4. Optionally add a description.
5. Tap **Create Habit**.

### Checking In

- Tap any habit card to mark it as complete for today.
- Tap again to uncheck if needed.
- Streaks are tracked automatically.

### Viewing Statistics

- Navigate to the **Stats** tab to see overall completion rates, best streaks, and individual habit performance.

### Deleting Habits

- Swipe left on a habit card, or use the delete option in settings.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| State Management | Provider |
| Local Database | Hive |
| UI | Material Design 3 |

---

## Data Model

Each habit contains:

- Unique ID
- Name
- Optional description
- Emoji/icon
- Creation date
- Check-in history (list of completion dates)
- Calculated streak (derived from history)

---

## Planned Enhancements

- Calendar view showing check-in history
- Habit categories (health, fitness, productivity, etc.)
- Daily reminder notifications
- Data export feature
- Habit templates and suggestions
- Advanced analytics and charts

---

## Development Notes

- Data persists between sessions via Hive local storage.
- Streaks are calculated based on consecutive days of completion.
- Completion percentage is calculated over the last 30 days.
- The app follows clean architecture principles with separation of concerns.

---

## License

This project is intended for educational purposes and potential small-scale commercial use.

---

## Support

For issues or questions, refer to the [Flutter documentation](https://docs.flutter.dev) or open an issue in the project repository.
