import 'package:hive_flutter/hive_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  static const String _boxName = 'profiles';
  static const String _activeKey = 'active_profile';
  static Box<dynamic>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box ??= await Hive.openBox<dynamic>(_boxName);
    if (_box!.isEmpty) {
      // Seed with a default profile
      final defaultProfile = UserProfile(name: 'You', avatar: '🙂');
      await _box!.put(defaultProfile.id, defaultProfile.toMap());
      await _box!.put(_activeKey, defaultProfile.id);
    } else if (!_box!.containsKey(_activeKey)) {
      // Ensure active key exists
      final firstKey = _box!.keys.firstWhere((k) => k != _activeKey);
      await _box!.put(_activeKey, firstKey);
    }
  }

  static Future<List<UserProfile>> getProfiles() async {
    await init();
    final profiles = <UserProfile>[];
    for (final key in _box!.keys) {
      if (key == _activeKey) continue;
      final map = _box!.get(key);
      if (map is Map) {
        profiles.add(UserProfile.fromMap(map));
      }
    }
    return profiles;
  }

  static Future<UserProfile> createProfile({required String name, required String avatar}) async {
    await init();
    final profile = UserProfile(name: name, avatar: avatar);
    await _box!.put(profile.id, profile.toMap());
    return profile;
  }

  static Future<void> deleteProfile(String id) async {
    await init();
    await _box!.delete(id);
    // If deleting active, fall back to first profile
    final active = await getActiveProfileId();
    if (active == id) {
      final profiles = await getProfiles();
      if (profiles.isNotEmpty) {
        await setActiveProfile(profiles.first.id);
      } else {
        final defaultProfile = UserProfile(name: 'You', avatar: '🙂');
        await _box!.put(defaultProfile.id, defaultProfile.toMap());
        await setActiveProfile(defaultProfile.id);
      }
    }
  }

  static Future<void> setActiveProfile(String id) async {
    await init();
    await _box!.put(_activeKey, id);
  }

  static Future<String> getActiveProfileId() async {
    await init();
    return _box!.get(_activeKey) as String;
  }

  static Future<UserProfile> getActiveProfile() async {
    final id = await getActiveProfileId();
    final map = _box!.get(id);
    if (map is Map) {
      return UserProfile.fromMap(map);
    }
    final defaultProfile = UserProfile(name: 'You', avatar: '🙂');
    await _box!.put(defaultProfile.id, defaultProfile.toMap());
    await setActiveProfile(defaultProfile.id);
    return defaultProfile;
  }
}

