import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int colorValue; // Store color as int (0xAARRGGBB)

  @HiveField(3)
  final List<String> subcategories;

  @HiveField(4)
  final String iconCodePoint; // Store icon data if needed, or just use name to map

  Category({
    required this.id,
    required this.name,
    required this.colorValue,
    this.subcategories = const [],
    this.iconCodePoint = '',
  });
}
