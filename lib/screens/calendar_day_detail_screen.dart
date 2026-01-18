import 'package:flutter/material.dart';
import 'package:habit_tracker/models/activity_model.dart';
import 'package:habit_tracker/models/category_model.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/widgets/multi_color_circle.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CalendarDayDetailScreen extends StatefulWidget {
  final DateTime date;
  final List<ActivityLog> activities;

  const CalendarDayDetailScreen({
    super.key,
    required this.date,
    required this.activities,
  });

  @override
  State<CalendarDayDetailScreen> createState() => _CalendarDayDetailScreenState();
}

class _CalendarDayDetailScreenState extends State<CalendarDayDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _explosionAnimation;
  late Animation<double> _listOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _explosionAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _listOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    // Start animation after a brief delay for Hero to finish (or partially during)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    final colors = provider.getColorsForDate(widget.date);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(DateFormat('MMMM d, yyyy').format(widget.date)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Hero Ring
          Center(
            child: Hero(
              tag: 'day_ring_${widget.date.toIso8601String()}',
              child: AnimatedBuilder(
                animation: _explosionAnimation,
                builder: (context, child) {
                  return MultiColorCircle(
                    colors: colors,
                    size: 150, // Larger size
                    strokeWidth: 12,
                    explosionFactor: _explosionAnimation.value,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: FadeTransition(
              opacity: _listOpacityAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.activities.length,
                itemBuilder: (context, index) {
                  final log = widget.activities[index];
                  final category = provider.getCategoryById(log.categoryId);
                  final color = category != null ? Color(category.colorValue) : Colors.grey;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                             Container(
                              width: 3,
                              height: 20,
                              color: index == 0 ? Colors.transparent : Colors.grey.withOpacity(0.3),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: color, width: 2),
                              ),
                              child: Icon(
                                _getCategoryIcon(category?.iconCodePoint),
                                color: color,
                                size: 20,
                              ),
                            ),
                             Container(
                              width: 3,
                              height: 40,
                              color: index == widget.activities.length -1 ? Colors.transparent : Colors.grey.withOpacity(0.3),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20), // Align with dot
                              Text(
                                log.subcategory,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                '${log.durationMinutes} mins • ${DateFormat('h:mm a').format(log.date)}',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              if (log.notes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    log.notes,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
}
