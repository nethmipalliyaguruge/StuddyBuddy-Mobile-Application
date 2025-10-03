import 'package:flutter/material.dart';

const kBrandGreen = Color(0xFF006644);
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildNoteItem('Database and Data Structures - Normalization','LKR 850.00',() {
          },),
          buildNoteItem('WDOS - Web Development & Operating Systems Notes', 'LKR 800.00', () {
          }),
          buildNoteItem('Server-side Authentication Techniques', 'LKR 750.00', () {
          }),
          buildNoteItem('Mobile Application Development', 'LKR 350.00', () {
          }),
          buildNoteItem('Software Engineering Principles', 'LKR 450.00', () {
          }),
        ],
      ),
            floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildNoteItem(String title, String price, VoidCallback onEdit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.note, size: 32, color: kBrandGreen),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 14,
                      color: kBrandGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Edit icon
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
