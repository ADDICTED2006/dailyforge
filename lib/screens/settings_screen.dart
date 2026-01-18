import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/screens/daily_goals_screen.dart';
import 'package:habit_tracker/screens/language_selection_screen.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, "Preferences"),
          Consumer<HabitProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                   SwitchListTile(
                    title: const Text('Dark Mode'),
                    secondary: const Icon(Icons.dark_mode),
                    value: provider.isDarkMode,
                    onChanged: (value) {
                      provider.toggleTheme(value);
                    },
                  ),
                  ListTile(
                    title: const Text('Manage Daily Goals'),
                    subtitle: const Text('Select habits for your streak'),
                    leading: const Icon(Icons.check_circle_outline, color: Colors.blue),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DailyGoalsScreen()),
                      );
                    },
                  ),
                   ListTile(
                    title: const Text('Language'),
                    subtitle: const Text('Change app language'),
                    leading: const Icon(Icons.language, color: Colors.purple),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Data & Privacy',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Reset My Progress',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Clear all activity logs and streaks'),
            onTap: () => _showResetConfirmation(context),
          ),
          const Divider(),
           const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Graph Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Consumer<HabitProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  ListTile(
                    title: const Text('Graph Range'),
                    subtitle: Text('${provider.graphRangeDays} Days'),
                    trailing: DropdownButton<int>(
                      value: provider.graphRangeDays,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('7 Days')),
                        DropdownMenuItem(value: 14, child: Text('14 Days')),
                        DropdownMenuItem(value: 30, child: Text('30 Days')),
                      ],
                      onChanged: (val) {
                        if (val != null) provider.setGraphRange(val);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Developer Zone (Debug)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          ListTile(
             leading: const Icon(Icons.science, color: Colors.orange),
             title: const Text('Populate Mock Data'),
             subtitle: const Text('Adds random history for testing'),
             onTap: () async {
               await Provider.of<HabitProvider>(context, listen: false).seedHistory();
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Added random history data!')),
               );
             },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will permanently delete all your activity history and reset your current streak to 0.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Provider.of<HabitProvider>(context, listen: false).resetProgress();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset successfully')),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
