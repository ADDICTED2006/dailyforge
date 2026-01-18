import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/screens/daily_goals_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/l10n/app_localizations.dart'; // Add import

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  DateTime? _dob;
  String _selectedGender = 'Male';
  String _selectedAvatar = 'assets/avatars/fox.png'; // Mock path

  // Simple avatar list (using Icons for now to represent them visually if assets missing)
  final List<String> _avatars = [
    'assets/avatars/fox.png',
    'assets/avatars/lion_new.png', // Updated calm lion
    'assets/avatars/panda.png',
    'assets/avatars/eagle.png',
    'assets/avatars/wolf.png',
    'assets/avatars/owl.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2C3E50), // Navy
              Colors.blue.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Welcome to Daily Forge!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Let's get to know you better.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      
                      // Avatar Selection (Mock UI)
                      // Avatar Selection
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          separatorBuilder: (context, index) => const SizedBox(width: 16),
                          itemCount: _avatars.length,
                          itemBuilder: (context, index) {
                            final isSelected = _avatars[index] == _selectedAvatar;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedAvatar = _avatars[index]),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: AssetImage(_avatars[index]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).get('enterName'), // Translated
                          prefixIcon: const Icon(Icons.person_outline, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 16),

                      // DOB
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) setState(() => _dob = date);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: const Icon(Icons.calendar_today, color: Colors.orange),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          child: Text(
                            _dob == null ? 'Select Date' : DateFormat('dd/MM/yyyy').format(_dob!),
                            style: TextStyle(color: _dob == null ? Colors.grey : Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Gender
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).get('selectGender'), // Translated
                          prefixIcon: const Icon(Icons.people_outline, color: Colors.purple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: ['Male', 'Female', 'Other', 'Prefer not to say']
                            .map((g) {
                               String label = g;
                               if(g == 'Male') label = AppLocalizations.of(context).get('male');
                               if(g == 'Female') label = AppLocalizations.of(context).get('female');
                               if(g == 'Other') label = AppLocalizations.of(context).get('other');
                               return DropdownMenuItem(value: g, child: Text(label)); // Use translated label
                            })
                            .toList(),
                        onChanged: (val) => setState(() => _selectedGender = val!),
                      ),
                      const SizedBox(height: 16),

                      // Goal
                      TextFormField(
                        controller: _goalController,
                        decoration: InputDecoration(
                          labelText: 'Main Goal',
                          hintText: 'e.g., Become a Developer',
                          prefixIcon: const Icon(Icons.flag_outlined, color: Colors.red),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a goal' : null,
                      ),
                      const SizedBox(height: 40),

                      // Submit
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: Text(AppLocalizations.of(context).get('createProfile'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_dob == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your Date of Birth')));
        return;
      }

      await Provider.of<HabitProvider>(context, listen: false).saveUserProfile(
        _nameController.text,
        _dob!,
        _selectedGender,
        _goalController.text,
        _selectedAvatar,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DailyGoalsScreen(isOnboarding: true)),
        );
      }
    }
  }
}
