import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 1)
class ActivityLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String subcategory;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int durationMinutes;

  @HiveField(5)
  final String notes;

  ActivityLog({
    required this.id,
    required this.categoryId,
    required this.subcategory,
    required this.date,
    required this.durationMinutes,
    this.notes = '',
  });
}
