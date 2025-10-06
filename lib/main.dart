import 'package:flutter/material.dart';
import 'package:studybuddy/screens/LoginPage.dart';

void main() {
  runApp(const StudyBuddyApp());
}

const kBrandGreen = Color(0xFF006644);

// Theme Manager for Dark/Light mode
class ThemeManager extends ChangeNotifier {
  static final ThemeManager instance = ThemeManager.internal();
  factory ThemeManager() => instance;
  ThemeManager.internal();

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}

class StudyBuddyApp extends StatefulWidget {
  const StudyBuddyApp({super.key});

  @override
  State<StudyBuddyApp> createState() => _StudyBuddyAppState();
}

class _StudyBuddyAppState extends State<StudyBuddyApp> {
  final ThemeManager themeManager = ThemeManager();

  @override
  void initState() {
    super.initState();
    themeManager.addListener(onThemeChanged);
  }

  @override
  void dispose() {
    themeManager.removeListener(onThemeChanged);
    super.dispose();
  }

  void onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBuddy',
      debugShowCheckedModeBanner: false,

      // Light Theme (Material 3)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrandGreen,
          brightness: Brightness.light,
        ),

        // App Bar Theme
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: kBrandGreen,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // Navigation Bar Theme
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: kBrandGreen.withOpacity(0.12),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (states) => TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: states.contains(WidgetState.selected)
                  ? kBrandGreen
                  : Colors.grey[600],
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (states) => IconThemeData(
              size: 24,
              color: states.contains(WidgetState.selected)
                  ? kBrandGreen
                  : Colors.grey[600],
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),

        // Card Theme
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBrandGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),

        // FAB Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kBrandGreen,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: CircleBorder(),
        ),
      ),

      // Dark Theme (Material 3)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrandGreen,
          brightness: Brightness.dark,
        ),

        // App Bar Theme
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // Navigation Bar Theme
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: kBrandGreen.withOpacity(0.12),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (states) => TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: states.contains(WidgetState.selected)
                  ? kBrandGreen
                  : Colors.grey[400],
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (states) => IconThemeData(
              size: 24,
              color: states.contains(WidgetState.selected)
                  ? kBrandGreen
                  : Colors.grey[400],
            ),
          ),
          backgroundColor: Colors.grey[900],
          surfaceTintColor: Colors.transparent,
        ),

        // Card Theme
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.grey[850],
        ),

        // Scaffold Background
        scaffoldBackgroundColor: Colors.grey[900],

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBrandGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),

        // FAB Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kBrandGreen,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: CircleBorder(),
        ),
      ),

      themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const Loginpage(),
    );
  }
}
