import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/screens/home_screen.dart';
import 'package:studybuddy/utils/constants.dart';

// Services
import 'package:studybuddy/services/storage_service.dart';
import 'package:studybuddy/services/api_service.dart';
import 'package:studybuddy/services/connectivity_service.dart';

// Providers
import 'package:studybuddy/providers/auth_provider.dart';
import 'package:studybuddy/providers/theme_provider.dart';
import 'package:studybuddy/providers/cart_provider.dart';
import 'package:studybuddy/providers/notes_provider.dart';
import 'package:studybuddy/providers/materials_provider.dart';
import 'package:studybuddy/providers/purchases_provider.dart';
import 'package:studybuddy/providers/connectivity_provider.dart';
import 'package:studybuddy/providers/recently_viewed_provider.dart';
import 'package:studybuddy/providers/search_history_provider.dart';
import 'package:studybuddy/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final apiService = ApiService(storageService);
  final connectivityService = ConnectivityService();
  final databaseService = DatabaseService();

  runApp(StudyBuddyApp(
    storageService: storageService,
    apiService: apiService,
    connectivityService: connectivityService,
    databaseService: databaseService,
  ));
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

class StudyBuddyApp extends StatelessWidget {
  final StorageService storageService;
  final ApiService apiService;
  final ConnectivityService connectivityService;
  final DatabaseService databaseService;

  const StudyBuddyApp({
    super.key,
    required this.storageService,
    required this.apiService,
    required this.connectivityService,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Connectivity Provider
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(connectivityService)..initialize(),
        ),

        // Theme Provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storageService)..initialize(),
        ),

        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService, storageService)..initialize(),
        ),

        // Cart Provider
        ChangeNotifierProvider(
          create: (_) => CartProvider(apiService, storageService)..loadCart(),
        ),

        // Notes Provider
        ChangeNotifierProvider(
          create: (_) => NotesProvider(apiService, storageService),
        ),

        // Materials Provider
        ChangeNotifierProvider(
          create: (_) => MaterialsProvider(apiService, storageService),
        ),

        // Purchases Provider
        ChangeNotifierProvider(
          create: (_) => PurchasesProvider(apiService, storageService),
        ),

        // Recently Viewed Provider (SQLite-backed)
        ChangeNotifierProvider(
          create: (_) => RecentlyViewedProvider(databaseService)..loadRecentlyViewed(),
        ),

        // Search History Provider (SQLite-backed)
        ChangeNotifierProvider(
          create: (_) => SearchHistoryProvider(databaseService)..loadHistory(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'StudyBuddy',
            debugShowCheckedModeBanner: false,

            // Light/Dark themes with Roboto + accessible contrast
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: themeProvider.themeMode,
            themeAnimationDuration: const Duration(milliseconds: 400),
            themeAnimationCurve: Curves.easeInOut,

            builder: (context, child) {
              return SafeArea(
                top: false, // AppBar handles the top
                child: child!,
              );
            },
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (!auth.isInitialized) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (auth.isAuthenticated) {
                  return const Homescreen();
                }
                return const Loginpage();
              },
            ),
          );
        },
      ),
    );
  }
}
