import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/screens/category_detail_screen.dart';
import 'package:habit_tracker/screens/settings_screen.dart';
import 'package:habit_tracker/screens/statistics_screen.dart';
import 'package:habit_tracker/screens/profile_screen.dart';
import 'package:habit_tracker/screens/calendar_day_detail_screen.dart';
import 'package:habit_tracker/widgets/multi_color_circle.dart';
import 'package:habit_tracker/widgets/streak_celebration.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/widgets/home_progress_graph.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habit_tracker/l10n/app_localizations.dart'; // Add import
// Tutorial related imports removed

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Tutorial check removed
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);

    // Check transient event
    bool shouldPlay = provider.justIncreasedStreak;
    
    return StreakCelebration(
      play: shouldPlay,
      onFinished: () => provider.consumeStreakEvent(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daily Forge'),
          actions: [
            // Graph button removed
             IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        body: provider.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStreakHeader(provider.currentStreak),
                    const SizedBox(height: 24),
                    _buildCalendar(provider),
                    const SizedBox(height: 24),
                    const Text(
                      'Categories',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryGrid(provider),
                     const SizedBox(height: 24),
                     const HomeProgressGraph(), // New embedded graph
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStreakHeader(int streak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange[700], size: 32),
          const SizedBox(width: 12),
          Text(
            '$streak ${AppLocalizations.of(context).get('dayStreak')}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(HabitProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TableCalendar(
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _showDayDetails(context, selectedDay);
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          weekendTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).iconTheme.color),
          rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayWithRing(day, provider);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayWithRing(day, provider, isToday: true);
          },
          selectedBuilder: (context, day, focusedDay) {
             return _buildDayWithRing(day, provider, isSelected: true);
          },
        ),
      ),
    );
  }

  Widget _buildDayWithRing(DateTime day, HabitProvider provider, {bool isToday = false, bool isSelected = false}) {
    final colors = provider.getColorsForDate(day);
    
    // Determine text color for the day number
    Color textColor;
    if (isSelected) {
      textColor = Colors.black; // Selected day bg is grey[300]
    } else if (isToday) {
      // Today bg is grey[100], so text should be dark regardless of theme
       textColor = Colors.black;
    } else {
      // Normal day, use theme text color
      textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (colors.isNotEmpty)
            Hero(
              tag: 'day_ring_${day.toIso8601String()}',
              child: MultiColorCircle(
                colors: colors,
                size: 38,
                strokeWidth: 3,
                explosionFactor: 0.0,
              ),
            ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey[300] : (isToday ? Colors.grey[100] : Colors.transparent),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(HabitProvider provider) {
    return SizedBox(
      height: 130, // Fixed height for the horizontal slider
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryDetailScreen(category: category),
                ),
              );
            },
            child: Container(
              width: 110, // Width to fit roughly 3 items on standard screens
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(category.colorValue).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(category.iconCodePoint),
                      color: Color(category.colorValue),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  IconData _getCategoryIcon(String? codePointStr) {
    if (codePointStr == null || codePointStr.isEmpty) {
      return Icons.category;
    }
    try {
      final int code = int.parse(codePointStr);
      return IconData(code, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.category;
    }
  }

  void _showDayDetails(BuildContext context, DateTime date) {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    final activities = provider.getActivitiesForDate(date);

    if (activities.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarDayDetailScreen(
          date: date,
          activities: activities,
        ),
      ),
    );
  }
}
