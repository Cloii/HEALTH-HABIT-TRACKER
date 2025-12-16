import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  List<UserProfile> _profiles = [];
  UserProfile? _active;
  bool _loading = true;

  List<UserProfile> get profiles => _profiles;
  UserProfile? get activeProfile => _active;
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    await ProfileService.init();
    _profiles = await ProfileService.getProfiles();
    _active = await ProfileService.getActiveProfile();
    _loading = false;
    notifyListeners();
  }

  Future<void> switchProfile(String id) async {
    await ProfileService.setActiveProfile(id);
    _active = await ProfileService.getActiveProfile();
    notifyListeners();
  }

  Future<UserProfile> createProfile({required String name, required String avatar}) async {
    final profile = await ProfileService.createProfile(name: name, avatar: avatar);
    _profiles = await ProfileService.getProfiles();
    notifyListeners();
    return profile;
  }
}

