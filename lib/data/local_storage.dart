import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker/models/category_model.dart';
import 'package:habit_tracker/models/activity_model.dart';
import 'package:habit_tracker/models/user_profile.dart';

class LocalStorage {
  static const String _paramBox = 'paramBox';
  static const String _categoriesBox = 'categoriesBox';
  static const String _activitiesBox = 'activitiesBox';
  static const String _profileBox = 'profileBox';
  static const String _keySecure = 'hiveEncryptionKey';

  static final LocalStorage _instance = LocalStorage._internal();

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    
    // register adapters
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(ActivityLogAdapter());
    Hive.registerAdapter(UserProfileAdapter());

    // encryption
    const secureStorage = FlutterSecureStorage();
    final containsEncryptionKey = await secureStorage.containsKey(key: _keySecure);
    
    if (!containsEncryptionKey) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(key: _keySecure, value: base64UrlEncode(key));
    }
    
    final keyBase64 = await secureStorage.read(key: _keySecure);
    final encryptionKey = base64Url.decode(keyBase64!);
    
    // open boxes
    await Hive.openBox<Category>(_categoriesBox, encryptionCipher: HiveAesCipher(encryptionKey));
    await Hive.openBox<ActivityLog>(_activitiesBox, encryptionCipher: HiveAesCipher(encryptionKey));
    await Hive.openBox<UserProfile>(_profileBox, encryptionCipher: HiveAesCipher(encryptionKey));
  }

  Box<Category> get categories => Hive.box<Category>(_categoriesBox);
  Box<ActivityLog> get activities => Hive.box<ActivityLog>(_activitiesBox);
  Box<UserProfile> get profile => Hive.box<UserProfile>(_profileBox);

  Future<void> saveProfile(UserProfile userProfile) async {
    // We only store one profile, key 'me'
    await profile.put('me', userProfile);
  }

  UserProfile? getProfile() {
    return profile.get('me');
  }

  Future<void> saveCategory(Category category) async {
    await categories.put(category.id, category);
  }

  Future<void> saveActivity(ActivityLog activity) async {
    await activities.put(activity.id, activity);
  }

  Future<void> deleteActivity(String id) async {
    await activities.delete(id);
  }

  Future<void> clearAllData() async {
    await activities.clear();
  }

  Future<void> saveThemeMode(bool isDark) async {
    final box = await Hive.openBox(_paramBox);
    await box.put('isDarkMode', isDark);
  }

  Future<bool> getThemeMode() async {
    final box = await Hive.openBox(_paramBox);
    return box.get('isDarkMode', defaultValue: false);
  }

  Future<void> saveDailyGoals(List<String> goals) async {
    final box = await Hive.openBox(_paramBox);
    await box.put('dailyGoals', goals);
  }

  Future<List<String>> getDailyGoals() async {
    final box = await Hive.openBox(_paramBox);
    final List<dynamic>? stored = box.get('dailyGoals');
    if (stored == null) return [];
    return List<String>.from(stored);
  }

  Future<void> saveLanguage(String code) async {
    final box = await Hive.openBox(_paramBox);
    await box.put('languageCode', code);
  }

  Future<String?> getLanguage() async {
    final box = await Hive.openBox(_paramBox);
    return box.get('languageCode');
  }

    // Seed default data
  Future<void> seedDefaultData() async {
    // Explicitly remove the old 'studies' category if it exists to avoid confusion
    if (categories.containsKey('studies')) {
      await categories.delete('studies');
    }

    // We overwrite/update these keys to ensure new subcategories are present
    final List<Category> defaultCategories = [
      Category(
        id: 'cs',
        name: 'Computer Science',
        colorValue: 0xFF2196F3, // Blue
        iconCodePoint: 0xe1b2.toString(), // Icons.computer
        subcategories: [
          'DSA practice', 'DAA', 'Java', 'Python', 'C / C++', 'DBMS',
          'Operating Systems', 'Computer Networks', 'Cybersecurity basics',
          'Cryptography', 'Web development', 'Competitive programming'
        ],
      ),
      Category(
        id: 'fitness',
        name: 'Fitness & Health',
        colorValue: 0xFF4CAF50, // Green
        iconCodePoint: 0xe28d.toString(), // Icons.fitness_center
        subcategories: [
          'Walking', 'Running / Jogging', 'Gym workout', 'Push-ups',
          'Yoga', 'Stretching', 'Skipping rope', 'Cycling'
        ],
      ),
      Category(
        id: 'mental',
        name: 'Mental Health',
        colorValue: 0xFF9C27B0, // Purple
        iconCodePoint: 0xf36e.toString(), // Icons.self_improvement
        subcategories: [
          'Meditation', 'Deep breathing', 'Gratitude journaling',
          'No social media', 'Digital detox'
        ],
      ),
      Category(
        id: 'productivity',
        name: 'Productivity',
        colorValue: 0xFFFF9800, // Orange
        iconCodePoint: 0xf425.toString(), // Icons.timer_outlined
        subcategories: [
          'Wake up early', 'No phone after waking', 'Plan the day',
          'Review goals', 'Pomodoro session'
        ],
      ),
      Category(
        id: 'reading',
        name: 'Reading',
        colorValue: 0xFFFFC107, // Amber
        iconCodePoint: 0xe3e0.toString(), // Icons.menu_book
        subcategories: [
          'Book reading', 'Technical articles', 'Research papers', 'News'
        ],
      ),
      Category(
        id: 'creative',
        name: 'Creativity',
        colorValue: 0xFFE91E63, // Pink
        iconCodePoint: 0xe40a.toString(), // Icons.palette
        subcategories: [
          'Drawing', 'Writing', 'Blogging', 'Content creation',
          'Video editing', 'Music practice', 'Photography'
        ],
      ),
      Category(
        id: 'career',
        name: 'Career Growth',
        colorValue: 0xFF009688, // Teal
        iconCodePoint: 0xe6f2.toString(), // Icons.work
        subcategories: [
          'Resume improvement', 'Interview prep', 'Coding practice',
          'System design', 'Portfolio building', 'LinkedIn learning'
        ],
      ),
      Category(
        id: 'life',
        name: 'Life Habits',
        colorValue: 0xFF795548, // Brown
        iconCodePoint: 0xe318.toString(), // Icons.home
        subcategories: [
          'Room cleaning', 'Personal hygiene', 'Skincare routine',
          'Healthy eating', 'Cooking at home'
        ],
      ),
      Category(
        id: 'custom',
        name: 'Custom',
        colorValue: 0xFF607D8B, // Blue Grey
        iconCodePoint: 0xe23e.toString(), // Icons.edit_note (or similar)
        subcategories: [], // Empty initially
      ),
    ];

    for (var category in defaultCategories) {
      // Put (overwrite) to ensure updates are applied
      await saveCategory(category);
    }
  }
}
