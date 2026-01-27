import 'package:flutter/material.dart';
import 'package:studybuddy/screens/LoginPage.dart';
import 'package:studybuddy/utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyBuddyApp());
}

/// Theme Manager for Dark/Light mode toggle
class ThemeManager extends ChangeNotifier with WidgetsBindingObserver {
  static final ThemeManager instance = ThemeManager.internal();
  factory ThemeManager() => instance;

  ThemeManager.internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Always notify listeners when platform brightness changes
    notifyListeners();
    super.didChangePlatformBrightness();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Use platformDispatcher to get the system brightness directly
      // This works even if context is not available yet
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme() {
    // If we are currently following system, clicking toggle locks it to the OPPOSITE of current system state.
    // Otherwise, it just swaps.
    if (_themeMode == ThemeMode.system) {
      _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    } else {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    }
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

/// Build a Material 3 Theme with Roboto + accessible colors
ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  // Use Material 3 color system from a seed
  final scheme = ColorScheme.fromSeed(
    seedColor: kBrandGreen,
    brightness: brightness,
  );

  // Material 3 typography + Roboto (make sure you added fonts in pubspec.yaml)
  final baseText = isDark
      ? Typography.material2021().white
      : Typography.material2021().black;

  final textTheme = baseText.apply(fontFamily: 'Roboto');

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'Roboto',
    textTheme: textTheme,

    // AppBar: ensure strong contrast in both modes
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: isDark ? const Color(0xFF121212) : kBrandGreen,
      foregroundColor: Colors.white,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    // Bottom Navigation: scheme tokens for contrast + consistency
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF121212) : scheme.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelMedium!.copyWith(
          fontWeight: FontWeight.w600,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
    ),

    // Card: use surface colors so onSurface text has correct contrast
    cardTheme: CardThemeData(
      elevation: isDark ? 4 : 2,
      color: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    ),

    // Elevated/Filled buttons: onPrimary text = accessible
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    // Inputs: outline color from scheme; focused = primary
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      hintStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      labelStyle: textTheme.labelLarge?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // FAB: primary + onPrimary = readable
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 6,
      shape: const CircleBorder(),
    ),

    // Scaffold surfaces
    scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : scheme.surface,
  );
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

  void onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBuddy',
      debugShowCheckedModeBanner: false,

      // Light/Dark themes with Roboto + accessible contrast
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeManager.themeMode,

      home: const Loginpage(),
    );
  }
}
