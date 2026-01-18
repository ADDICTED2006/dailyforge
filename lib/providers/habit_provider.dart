import 'package:flutter/material.dart';
import 'package:habit_tracker/data/local_storage.dart';
import 'package:habit_tracker/models/activity_model.dart';
import 'package:habit_tracker/models/category_model.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:habit_tracker/models/user_profile.dart'; // Keep existing

class HabitProvider with ChangeNotifier {
  final LocalStorage _storage = LocalStorage();
  
  List<Category> _categories = [];
  List<ActivityLog> _recentLogs = [];
  Map<DateTime, List<Color>> _calendarColors = {};
  UserProfile? _userProfile;
  int _currentStreak = 0;
  bool _isLoading = true;
  bool _isDarkMode = false;

  List<Category> get categories => _categories;
  int get currentStreak => _currentStreak;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  UserProfile? get userProfile => _userProfile;
  bool get hasProfile => _userProfile != null;

  Future<void> init() async {
    await _storage.init();
    await _storage.seedDefaultData();
    _isDarkMode = await _storage.getThemeMode();
    await _loadData();
  }

  // Tutorial methods removed


  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    _storage.saveThemeMode(isDark);
    notifyListeners();
  }

  Future<void> saveUserProfile(String name, DateTime dob, String gender, String goal, String avatarPath) async {
    final profile = UserProfile(
      name: name,
      dob: dob,
      gender: gender,
      goal: goal,
      avatarPath: avatarPath,
    );
    await _storage.saveProfile(profile);
    _userProfile = profile;
    notifyListeners();
  }

  Future<void> _loadData() async {
    _categories = _storage.categories.values.toList();
    _recentLogs = _storage.activities.values.toList();
    _userProfile = _storage.getProfile();
    _dailyGoals = (await _storage.getDailyGoals()).toSet();
    _languageCode = await _storage.getLanguage();
    
    _calculateStreak();
    _generateCalendarColors();
    _isLoading = false;
    notifyListeners();
  }

  Set<String> _dailyGoals = {};
  Set<String> get dailyGoals => _dailyGoals;

  String? _languageCode;
  String? get languageCode => _languageCode;

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    await _storage.saveLanguage(code);
    notifyListeners();
  }

  Future<void> toggleDailyGoal(String habit) async {
    if (_dailyGoals.contains(habit)) {
      _dailyGoals.remove(habit);
    } else {
      _dailyGoals.add(habit);
    }
    await _storage.saveDailyGoals(_dailyGoals.toList());
    _calculateStreak(); // Recalculate streak based on new goals
    notifyListeners();
  }

  Future<void> addActivity(String categoryId, String subcategory, int duration, String notes) async {
    final newLog = ActivityLog(
      id: DateTime.now().toIso8601String(),
      categoryId: categoryId,
      subcategory: subcategory,
      date: DateTime.now(),
      durationMinutes: duration,
      notes: notes,
    );

    await _storage.saveActivity(newLog);
    _recentLogs.add(newLog);
    
    _calculateStreak();
    _generateCalendarColors();
    notifyListeners();
  }

  Future<void> addHabitToCategory(String categoryId, String habitName) async {
    final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = _categories[categoryIndex];
    if (category.subcategories.contains(habitName)) return;

    // Create a new list with the added habit
    final updatedSubcategories = List<String>.from(category.subcategories)..add(habitName);

    // Create a new Category object (since fields are likely final)
    final updatedCategory = Category(
      id: category.id,
      name: category.name,
      colorValue: category.colorValue,
      iconCodePoint: category.iconCodePoint,
      subcategories: updatedSubcategories,
    );

    await _storage.saveCategory(updatedCategory);
    
    // Update local state
    _categories[categoryIndex] = updatedCategory;
    notifyListeners();
  }

  Future<void> updateCategoryIcon(String categoryId, int codePoint) async {
    final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = _categories[categoryIndex];

    final updatedCategory = Category(
      id: category.id,
      name: category.name,
      colorValue: category.colorValue,
      iconCodePoint: codePoint.toString(),
      subcategories: category.subcategories,
    );

    await _storage.saveCategory(updatedCategory);
    _categories[categoryIndex] = updatedCategory;
    notifyListeners();
  }

  bool _justIncreasedStreak = false;
  bool get justIncreasedStreak => _justIncreasedStreak;

  void consumeStreakEvent() {
    _justIncreasedStreak = false;
    notifyListeners();
  }

  void _calculateStreak() {
    if (_recentLogs.isEmpty || _categories.isEmpty) {
      _currentStreak = 0;
      return;
    }

    // 1. Identify all required subcategories (Use Daily Goals)
    // If no goals are set, streak is 0 (or we could say 0 requirements met = streak? No, that's cheating :P)
    // Let's assume if no goals, no streak.
    
    if (_dailyGoals.isEmpty) {
      _currentStreak = 0; 
      return; 
    }

    final Set<String> requirements = _dailyGoals;

    // 2. Group logs by date
    final Map<String, Set<String>> logsByDate = {};
    for (var log in _recentLogs) {
      final dateStr = DateFormat('yyyy-MM-dd').format(log.date);
      if (!logsByDate.containsKey(dateStr)) {
        logsByDate[dateStr] = {};
      }
      logsByDate[dateStr]!.add(log.subcategory);
    }

    // 3. Determine which dates are "Complete"
    final List<String> completeDates = [];
    logsByDate.forEach((dateStr, completedSubs) {
      // Check if completedSubs contains ALL required subs
      // We use checking size first for speed, then contain check
      bool allDone = true;
      for (var req in requirements) {
        if (!completedSubs.contains(req)) {
          allDone = false;
          break;
        }
      }
      if (allDone) {
        completeDates.add(dateStr);
      }
    });

    completeDates.sort((a, b) => b.compareTo(a)); // Descending

    if (completeDates.isEmpty) {
      _currentStreak = 0;
      return;
    }

    // 4. Calculate Streak
    int newStreak = 0;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));

    // Check if the most recent *complete* date was today or yesterday
    if (completeDates.first != today && completeDates.first != yesterday) {
      _currentStreak = 0;
      return;
    }

    DateTime checkDate = DateTime.now();
    String dateStr = DateFormat('yyyy-MM-dd').format(checkDate);
    
    // If today is not complete, start checking from yesterday
    if (!completeDates.contains(dateStr)) {
       checkDate = checkDate.subtract(const Duration(days: 1));
       dateStr = DateFormat('yyyy-MM-dd').format(checkDate);
       if (!completeDates.contains(dateStr)) {
         _currentStreak = 0;
         return;
       }
    }

    while (completeDates.contains(dateStr)) {
      newStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
      dateStr = DateFormat('yyyy-MM-dd').format(checkDate);
    }

    // Check if streak increased just now (only if we are adding activity)
    if (newStreak > _currentStreak && newStreak > 0) {
      _justIncreasedStreak = true;
    }
    
    _currentStreak = newStreak;
  }

  void _generateCalendarColors() {
    _calendarColors = {};
    
    for (var log in _recentLogs) {
      final dateKey = DateTime(log.date.year, log.date.month, log.date.day);
      
      final category = _categories.firstWhere(
        (c) => c.id == log.categoryId, 
        orElse: () => Category(id: 'unknown', name: 'Unknown', colorValue: 0xFF888888)
      );
      
      final color = Color(category.colorValue);

      if (!_calendarColors.containsKey(dateKey)) {
        _calendarColors[dateKey] = [];
      }
      
      // Avoid duplicate colors for the same day if we want unique segments per category
      // or allow multiple segments for multiple entries. User asked for "circular outline should have 2 different colors that will be assigned to that specific habit"
      // Assuming unique colors per category per day.
      if (!_calendarColors[dateKey]!.contains(color)) {
        _calendarColors[dateKey]!.add(color);
      }
    }
  }

  List<Color> getColorsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _calendarColors[dateKey] ?? [];
  }

  Future<void> resetProgress() async {
    await _storage.clearAllData();
    _recentLogs.clear();
    _calendarColors.clear();
    _currentStreak = 0;
    notifyListeners();
  }
  Set<String> getCompletedHabitsForToday(String categoryId) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _recentLogs
        .where((log) => 
            log.categoryId == categoryId && 
            DateFormat('yyyy-MM-dd').format(log.date) == todayStr)
        .map((log) => log.subcategory)
        .toSet();
  }

  Future<void> undoActivity(String categoryId, String subcategory) async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final logToRemove = _recentLogs.firstWhere(
      (log) => 
        log.categoryId == categoryId && 
        log.subcategory == subcategory &&
        DateFormat('yyyy-MM-dd').format(log.date) == todayStr,
      orElse: () => ActivityLog(id: '', categoryId: '', subcategory: '', date: DateTime.now(), durationMinutes: 0)
    );

    if (logToRemove.id.isNotEmpty) {
      await _storage.deleteActivity(logToRemove.id);
      _recentLogs.remove(logToRemove);
      _calculateStreak();
      _generateCalendarColors();
      notifyListeners();
    }
  }
  List<ActivityLog> getActivitiesForDate(DateTime date) {
    final targetDateStr = DateFormat('yyyy-MM-dd').format(date);
    return _recentLogs.where((log) {
      return DateFormat('yyyy-MM-dd').format(log.date) == targetDateStr;
    }).toList();
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<DateTime, int> getDailyCompletionStats(int daysCount) {
    final Map<DateTime, int> stats = {};
    final now = DateTime.now();
    
    // Initialize with 0 for all days
    for (int i = 0; i < daysCount; i++) {
        final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        stats[date] = 0;
    }

    // Count completions
    for (var log in _recentLogs) {
      final dateKey = DateTime(log.date.year, log.date.month, log.date.day);
      if (stats.containsKey(dateKey)) {
        stats[dateKey] = (stats[dateKey] ?? 0) + 1;
      }
    }
    
    return stats;
  }

  // --- Graph Settings & Debug ---
  int _graphRangeDays = 14;
  int get graphRangeDays => _graphRangeDays;

  void setGraphRange(int days) {
    _graphRangeDays = days;
    notifyListeners();
  }

  Future<void> seedHistory() async {
    final random = Random();
    final categories = _categories;
    if (categories.isEmpty) return;

    // Generate random activities for past 30 days
    for (int i = 0; i < 30; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      
      // Randomly decide if we did something this day (70% chance)
      if (random.nextDouble() > 0.3) {
        // Add 1-4 activities
        int count = random.nextInt(4) + 1;
        for (int k = 0; k < count; k++) {
           final cat = categories[random.nextInt(categories.length)];
           final sub = cat.subcategories.isNotEmpty 
              ? cat.subcategories[random.nextInt(cat.subcategories.length)]
              : 'Generic Habit';
           
           final newLog = ActivityLog(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString() + k.toString(),
            categoryId: cat.id,
            subcategory: sub,
            date: date,
            durationMinutes: 15 + random.nextInt(45),
            notes: 'Auto-generated log',
          );
          await _storage.saveActivity(newLog);
          _recentLogs.add(newLog);
        }
      }
    }
    _calculateStreak();
    _generateCalendarColors();
    notifyListeners();
  }
}

extension DateUtils on DateTime {
  DateTime normalizeDate() {
    return DateTime(year, month, day);
  }
}
