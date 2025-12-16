# Quick Start Guide - How to Run the App

## Step 1: Install Dependencies

First, install all the required packages:

```bash
flutter pub get
```

## Step 2: Generate Hive Code (REQUIRED)

You **must** run this before the app will work. This generates the database adapter code:

```bash
flutter pub run build_runner build
```

**Important:** If you see errors about `habit.g.dart` or `HabitAdapter`, this is normal! These errors will disappear after running the command above.

## Step 3: Check Available Devices

See what devices you can run on:

```bash
flutter devices
```

You should see something like:
- Android emulator (if you have one running)
- iOS Simulator (if on Mac)
- Physical device connected via USB
- Chrome (for web testing)

## Step 4: Run the App

### Option A: Run on the first available device
```bash
flutter run
```

### Option B: Run on a specific device
```bash
flutter run -d <device-id>
```

For example:
```bash
# Android emulator
flutter run -d emulator-5554

# Chrome (web)
flutter run -d chrome

# Physical device
flutter run -d <your-device-id>
```

## Common Issues & Solutions

### Issue: "No devices found"
**Solution:** 
- Start an Android emulator from Android Studio
- Or connect a physical device via USB with USB debugging enabled
- Or use `flutter run -d chrome` to run on web

### Issue: Build errors about missing files
**Solution:** Make sure you ran `flutter pub run build_runner build` (Step 2)

### Issue: Gradle build errors (Android)
**Solution:** 
- Make sure you have Android SDK installed
- Try: `flutter clean` then `flutter pub get` then run again

### Issue: Code generation conflicts
**Solution:** If build_runner has conflicts, use:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Hot Reload & Hot Restart

Once the app is running:
- Press `r` in the terminal for **hot reload** (quick updates)
- Press `R` for **hot restart** (full restart)
- Press `q` to **quit**

## Development Workflow

1. Make changes to your code
2. Save the file
3. Press `r` in the terminal for hot reload
4. See changes instantly!

## Recommended Setup

For the best experience:
1. **Android Studio** - Full IDE with Flutter plugin
2. **VS Code** - Lightweight editor with Flutter extensions
3. **Android Emulator** - For testing Android
4. **Physical Device** - For real-world testing

## Next Steps After Running

1. Tap the **+** button to add your first habit
2. Select an emoji icon
3. Enter a habit name
4. Tap a habit card to mark it complete for today
5. Check the **Stats** tab to see your progress!

---

**Need Help?** Check the main README.md for more detailed information.

