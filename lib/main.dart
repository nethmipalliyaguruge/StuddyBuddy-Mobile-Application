import 'package:flutter/material.dart';
import 'package:studybuddy/screens/LoginPage.dart';

void main() {
  runApp(const StudyBuddyApp());
}
const kBrandGreen = Color(0xFF006644);
class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kBrandGreen),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: kBrandGreen.withOpacity(0.12),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (states) => TextStyle(
              fontWeight: FontWeight.w700,
              color: states.contains(WidgetState.selected)
                  ? kBrandGreen
                  : kBrandGreen.withOpacity(0.65),
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (states) => IconThemeData(
              size: 24,
              color: states.contains(WidgetState.selected)
                  ? kBrandGreen
                  : kBrandGreen.withOpacity(0.65),
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const Loginpage(),
    );
  }
}