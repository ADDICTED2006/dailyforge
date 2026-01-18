import 'dart:math';
import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/screens/home_screen.dart';
import 'package:habit_tracker/screens/profile_creation_screen.dart';
import 'package:provider/provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'hello': 'Hello'},
    {'code': 'hi', 'name': 'Hindi', 'hello': 'नमस्ते'},
    {'code': 'es', 'name': 'Spanish', 'hello': 'Hola'},
    {'code': 'zh', 'name': 'Chinese', 'hello': '你好'},
    {'code': 'ar', 'name': 'Arabic', 'hello': 'مرحبا'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectLanguage(String code) async {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    await provider.setLanguage(code);

    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Return to settings
      return;
    }

    // Check if profile exists to determine next screen
    if (provider.userProfile != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProfileCreationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Globe Animation with Bubbles
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                           BoxShadow(color: Colors.blueAccent, blurRadius: 30, spreadRadius: 5),
                        ]
                      ),
                      child: Image.asset('assets/globe_flat.png', fit: BoxFit.cover),
                    ),
                  // Floating Bubbles (Static positions with animated opacity or scale could be better, 
                  // but for simplicity we'll place them around)
                  _buildBubble('Hello', -120, -80),
                  _buildBubble('नमस्ते', 120, -60),
                  _buildBubble('Hola', -110, 80),
                  _buildBubble('你好', 110, 90),
                  _buildBubble('مرحبا', 0, -140),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                if (Navigator.canPop(context)) 
                  Positioned(
                    left: 20, 
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                const Column(
                  children: [
                     Text(
                      "Choose Your Language",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                     SizedBox(height: 10),
                     Text(
                      "Start your journey in your preferred language",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            // Language List
            Container(
              height: 250,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: _languages.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, i) {
                  final lang = _languages[i];
                  return ListTile(
                    title: Text(
                      lang['name']!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      lang['hello']!,
                      style: TextStyle(fontSize: 18, color: Colors.indigo[400]),
                    ),
                    onTap: () => _selectLanguage(lang['code']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(String text, double offsetX, double offsetY) {
    // Simple static bubbles for now, could be animated popping in/out
    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
