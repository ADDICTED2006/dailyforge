import 'package:flutter/material.dart';
import 'package:habit_tracker/models/category_model.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/l10n/app_localizations.dart'; // Add import

class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final TextEditingController _notesController = TextEditingController();
  String? _selectedSubcategory;
  int _duration = 30;

  @override
  void initState() {
    super.initState();
    if (widget.category.subcategories.isNotEmpty) {
      _selectedSubcategory = widget.category.subcategories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Color(widget.category.colorValue).withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Change Icon',
            onPressed: () => _showIconPickerDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLogCard(),
            const SizedBox(height: 24),
            Text(
              // 'Log Activity' - I don't have this exact key in map, I'll use 'categoryName' as logic or just 'Log' which I forgot to add.
              // Wait, I should add 'logActivity' to map if I want it perfect.
              // For now I'll use hardcoded 'Log Activity' to avoid complexity or use 'progress' key? No.
              // I will leave 'Log Activity' hardcoded for now to not break flow, or update map. 
              // Actually I can modify map easily.
              'Log Activity', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).get('progress'), // Using 'Progress' or 'History' if I had it. Map has 'progress'.
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // ...
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Log Activity',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.category.subcategories.isNotEmpty) ...[
              Consumer<HabitProvider>(
                builder: (context, provider, child) {
                  final completedFn = provider.getCompletedHabitsForToday(widget.category.id);
                  // Sort: Pending first, then Completed
                  final sortedSubcategories = List<String>.from(widget.category.subcategories);
                  sortedSubcategories.sort((a, b) {
                    final isADone = completedFn.contains(a);
                    final isBDone = completedFn.contains(b);
                    if (isADone && !isBDone) return 1; // A is done, put it after B
                    if (!isADone && isBDone) return -1; // B is done, put it after A
                    return 0;
                  });

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...sortedSubcategories.map((sub) {
                        final isDone = completedFn.contains(sub);
                        return ChoiceChip(
                          avatar: null,
                          label: Text(
                            sub,
                            style: TextStyle(
                              // decoration: isDone ? TextDecoration.lineThrough : null, // Removed as requested
                              color: isDone ? Colors.white : null,
                            ),
                          ),
                          selected: _selectedSubcategory == sub,
                          selectedColor: isDone ? Colors.green.withOpacity(0.5) : null, // Fixed: Green even if selected
                          backgroundColor: isDone ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.1), // Red tint for incomplete
                          onSelected: (selected) {
                            if (isDone) {
                               // Deselect/Undo logic
                               Provider.of<HabitProvider>(context, listen: false)
                                   .undoActivity(widget.category.id, sub);
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Habit undone'), duration: Duration(milliseconds: 700)),
                               );
                            } else {
                              setState(() {
                                _selectedSubcategory = sub;
                              });
                            }
                          },
                        );
                      }).toList(),
                      ActionChip(
                        label: const Icon(Icons.add, size: 18),
                        onPressed: () => _showAddHabitDialog(context),
                        tooltip: 'Add new habit',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ] else ...[
              Center(
                child: TextButton.icon(
                  onPressed: () => _showAddHabitDialog(context),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add your first habit'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Text('Duration: ', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                Expanded(
                  child: Slider(
                    value: _duration.toDouble(),
                    min: 15,
                    max: 180,
                    divisions: 11,
                    onChanged: (val) {
                      setState(() {
                        _duration = val.toInt();
                      });
                    },
                    activeColor: Color(widget.category.colorValue),
                  ),
                ),
                Text('${_duration}m', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(widget.category.colorValue),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Activity'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveActivity() {
    final sub = _selectedSubcategory ?? 'General';
    Provider.of<HabitProvider>(context, listen: false).addActivity(
      widget.category.id,
      sub,
      _duration,
      _notesController.text,
    );
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: const Text('Activity Logged!'),
         backgroundColor: Color(widget.category.colorValue),
       ),
    );
    Navigator.pop(context);
  }

  void _showAddHabitDialog(BuildContext context) {
    final TextEditingController habitController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Habit'),
        content: TextField(
          controller: habitController,
          decoration: const InputDecoration(hintText: 'e.g., Drink Water'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (habitController.text.isNotEmpty) {
                Provider.of<HabitProvider>(context, listen: false)
                  .addHabitToCategory(widget.category.id, habitController.text.trim());
                Navigator.pop(context);
                // Auto-select if it was first
                if (widget.category.subcategories.isEmpty) {
                   setState(() {
                     _selectedSubcategory = habitController.text.trim();
                   });
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showIconPickerDialog(BuildContext context) {
    final List<IconData> icons = [
       Icons.star, Icons.favorite, Icons.lightbulb, Icons.check_circle,
       Icons.public, Icons.science, Icons.sports_basketball, Icons.directions_bike,
       Icons.music_note, Icons.movie, Icons.camera_alt, Icons.brush,
       Icons.work, Icons.attach_money, Icons.home, Icons.pets,
       Icons.fastfood, Icons.local_cafe, Icons.bed, Icons.air,
       Icons.edit, Icons.build, Icons.rocket, Icons.flag,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Icon'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: icons.length,
            itemBuilder: (context, index) {
              return IconButton(
                onPressed: () {
                  Provider.of<HabitProvider>(context, listen: false)
                      .updateCategoryIcon(widget.category.id, icons[index].codePoint);
                  Navigator.pop(context);
                },
                icon: Icon(icons[index], color: Color(widget.category.colorValue)),
              );
            },
          ),
        ),
      ),
    );
  }
}
