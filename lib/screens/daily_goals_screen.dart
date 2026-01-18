import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:habit_tracker/screens/home_screen.dart'; // Import HomeScreen

class DailyGoalsScreen extends StatelessWidget {
  final bool isOnboarding;

  const DailyGoalsScreen({Key? key, this.isOnboarding = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).get('dailyGoalsTitle')), // Translated
        centerTitle: true,
        automaticallyImplyLeading: !isOnboarding, // Hide back button if onboarding
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.categories.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context).get('noHabitsFound'), // Translated
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return Column(
            children: [
              if (isOnboarding)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context).get('selectHabitsCommit'), // Translated
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];
                      if (category.subcategories.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(category.colorValue),
                              ),
                            ),
                          ),
                          Card(
                            elevation: 0,
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              children: category.subcategories.map((habit) {
                                    final isSelected = provider.dailyGoals.contains(habit);
                                    return CheckboxListTile(
                                      title: Text(habit),
                                      value: isSelected,
                                      activeColor: Color(category.colorValue),
                                      onChanged: (value) {
                                        provider.toggleDailyGoal(habit);
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: isOnboarding
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Home and clear stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: Text(AppLocalizations.of(context).get('startJourney'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          : null,
    );
  }
}
