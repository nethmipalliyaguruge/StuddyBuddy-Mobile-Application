import 'package:flutter/material.dart';
import 'package:studybuddy/screens/ExplorePage.dart';
import 'package:studybuddy/screens/NotesPage.dart';
import 'package:studybuddy/screens/detail_page.dart';

const kBrandGreen = Color(0xFF006644);

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _index = 0;

  final _pages = const [HomePage(), ExplorePage(), NotesPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyBuddy', style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        )),
        backgroundColor: kBrandGreen,
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int newIndex) {
          setState(() => _index = newIndex); // switch page
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(icon: Icon(Icons.note_rounded), label: 'Notes'),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NoteDetailPage()),
              );
            },
            child: const Text('View'),
          ),
        ],
      ),
    ),
  );
}



class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Profile')));
}
