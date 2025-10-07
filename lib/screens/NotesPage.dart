import 'package:flutter/material.dart';
import 'package:studybuddy/screens/AddNotePage.dart';
import 'package:studybuddy/screens/detail_page.dart';

const kBrandGreen = Color(0xFF006644);

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Notes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: kBrandGreen,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildNoteItem(
            context,
            'Database and Data Structures - Normalization',
            'LKR 850.00',
            0,
            {
              'title': 'Database & Data Structures',
              'price': 'LKR 850.00',
              'rating': 4.8,
            },
          ),
          buildNoteItem(
            context,
            'WDOS - Web Development & Operating Systems Notes',
            'LKR 800.00',
            1,
            {
              'title': 'Web Development Fundamentals',
              'price': 'LKR 800.00',
              'rating': 4.5,
            },
          ),
          buildNoteItem(
            context,
            'Server-side Authentication Techniques',
            'LKR 750.00',
            2,
            {
              'title': 'Authentication & Security',
              'price': 'LKR 750.00',
              'rating': 4.7,
            },
          ),
          buildNoteItem(
            context,
            'Mobile Application Development',
            'LKR 350.00',
            3,
            {
              'title': 'Mobile App Development',
              'price': 'LKR 350.00',
              'rating': 4.6,
            },
          ),
          buildNoteItem(
            context,
            'Software Engineering Principles',
            'LKR 450.00',
            4,
            {
              'title': 'Software Engineering',
              'price': 'LKR 450.00',
              'rating': 4.4,
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (context) => AddNotePage()));
        },
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildNoteItem(
    BuildContext context,
    String title,
    String price,
    int index,
    Map<String, dynamic> product,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  NoteDetailPage(product: product),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
              transitionDuration: const Duration(milliseconds: 250),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Hero(
                tag: 'note-icon-$index',
                child: const Icon(Icons.note, size: 32, color: kBrandGreen),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'note-title-$index',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Hero(
                      tag: 'note-price-$index',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          price,
                          style: const TextStyle(
                            fontSize: 14,
                            color: kBrandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
