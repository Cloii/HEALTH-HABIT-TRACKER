import 'package:uuid/uuid.dart';

class UserProfile {
  final String id;
  final String name;
  final String avatar;

  UserProfile({
    String? id,
    required this.name,
    required this.avatar,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'avatar': avatar,
      };

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      avatar: map['avatar'] as String? ?? '🙂',
    );
  }
}

