import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/screens/home_screen.dart';
import 'package:habit_tracker/screens/language_selection_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/l10n/app_localizations.dart'; // Add import

import 'package:habit_tracker/screens/profile_creation_screen.dart'; // Add import

void main() async {
  // Ensure binding initialized before Hive
  WidgetsFlutterBinding.ensureInitialized();
  
  final habitProvider = HabitProvider();
  await habitProvider.init();
  await Hive.initFlutter();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: habitProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);

    // Define a base text theme to ensure consistent structure (inherit values) for interpolation
    final baseTextTheme = GoogleFonts.loraTextTheme(Theme.of(context).textTheme);

    // Light Theme Definition
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Light Grey
      cardColor: Colors.white,
      primaryColor: const Color(0xFF2C3E50),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2C3E50),
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      // Apply colors to the SAME base text theme
      textTheme: baseTextTheme.apply(
        bodyColor: const Color(0xFF2C3E50),
        displayColor: const Color(0xFF2C3E50),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2C3E50),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      shadowColor: Colors.black.withOpacity(0.05),
    );

    // Dark Theme Definition
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212), // Very Dark Grey
      cardColor: const Color(0xFF1E1E1E), // Dark Grey for Cards
      primaryColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2C3E50),
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E1E),
      ),
      // Apply colors to the SAME base text theme
      textTheme: baseTextTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      shadowColor: Colors.black.withOpacity(0.3), // Darker shadow for depth
    );

    return MaterialApp(
      title: 'Daily Forge',
      debugShowCheckedModeBanner: false,
      themeMode: habitProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add our custom delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
        Locale('es', ''),
        Locale('zh', ''),
        Locale('ar', ''),
      ],
      locale: habitProvider.languageCode != null ? Locale(habitProvider.languageCode!) : null,
      home: () {
        if (habitProvider.languageCode == null) {
          return const LanguageSelectionScreen();
        } else if (habitProvider.userProfile == null) {
          return const ProfileCreationScreen();
        } else {
          return const HomeScreen();
        }
      }(),
    );
  }
}
