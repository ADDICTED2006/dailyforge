import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime dob;

  @HiveField(2)
  final String gender;

  @HiveField(3)
  final String goal;

  @HiveField(4)
  final String avatarPath;

  UserProfile({
    required this.name,
    required this.dob,
    required this.gender,
    required this.goal,
    required this.avatarPath,
  });
}
