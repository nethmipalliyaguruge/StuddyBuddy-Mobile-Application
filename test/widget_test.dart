// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/services/storage_service.dart';
import 'package:studybuddy/services/api_service.dart';
import 'package:studybuddy/services/connectivity_service.dart';
import 'package:studybuddy/services/database_service.dart';
import 'package:studybuddy/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Create mock services
    final storageService = StorageService();
    final apiService = ApiService(storageService);
    final connectivityService = ConnectivityService();
    final databaseService = DatabaseService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(StudyBuddyApp(
      storageService: storageService,
      apiService: apiService,
      connectivityService: connectivityService,
      databaseService: databaseService,
    ));

    // Verify that our app shows the login page
    expect(find.text('StudyBuddy'), findsWidgets);
  });
}
