import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/providers/notes_provider.dart';
import 'package:studybuddy/models/note.dart';
import 'package:studybuddy/screens/add_note_page.dart';
import 'package:studybuddy/screens/edit_note_page.dart';
import 'package:studybuddy/utils/constants.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  void initState() {
    super.initState();
    // Fetch notes when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
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
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          if (notesProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: kBrandGreen),
            );
          }

          if (notesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    notesProvider.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => notesProvider.fetchNotes(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (notesProvider.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first note',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => notesProvider.fetchNotes(),
            color: kBrandGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notesProvider.notes.length,
              itemBuilder: (context, index) {
                final note = notesProvider.notes[index];
                return buildNoteItem(context, note, index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<bool>(
              builder: (context) => const AddNotePage(),
            ),
          );
        },
        tooltip: 'Add new note',
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildNoteItem(BuildContext context, Note note, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          _navigateToEditNote(context, note);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Hero(
                tag: 'note-icon-${note.id}',
                child: const Icon(Icons.note, size: 32, color: kBrandGreen),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'note-title-${note.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Hero(
                      tag: 'note-price-${note.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          'LKR ${note.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: kBrandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (note.module != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        note.module!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit note',
                onPressed: () {
                  _navigateToEditNote(context, note);
                },
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete note',
                onPressed: () => _confirmDeleteNote(context, note),
                color: Colors.red[400],
                iconSize: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteNote(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text(
          "Are you sure you want to delete '${note.title}'? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final provider = this.context.read<NotesProvider>();
              final messenger = ScaffoldMessenger.of(this.context);
              final success = await provider.deleteNote(note.id);
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Note deleted successfully'
                        : 'Failed to delete note',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditNote(BuildContext context, Note note) {
    Navigator.of(context).push(
      PageRouteBuilder<bool>(
        pageBuilder: (context, animation, secondaryAnimation) => EditNotePage(
          existingNote: note,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
        transitionDuration: const Duration(milliseconds: 50),
      ),
    );
  }
}
