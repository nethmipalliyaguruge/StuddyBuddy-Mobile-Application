import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/providers/notes_provider.dart';
import 'package:studybuddy/models/note.dart';
import 'package:studybuddy/utils/constants.dart';

class EditNotePage extends StatefulWidget {
  final Note existingNote;

  const EditNotePage({
    super.key,
    required this.existingNote,
  });

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.existingNote.title;
    priceController.text = widget.existingNote.price.toStringAsFixed(2);
    descriptionController.text = widget.existingNote.description ?? '';
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        centerTitle: true,
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTextField(
                label: 'Note Title',
                hint: 'Enter note title',
                controller: titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextField(
                label: 'Price (LKR)',
                hint: 'Enter price in LKR',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: priceController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null) {
                    return 'Please enter a valid number';
                  }
                  if (price < 0) {
                    return 'Price cannot be negative';
                  }
                  if (price == 0) {
                    return 'Price must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              buildTextField(
                label: 'Note Description',
                hint: 'Enter a brief description',
                maxLines: 8,
                controller: descriptionController,
              ),
              const SizedBox(height: 30),
              buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBrandGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildActionButtons() {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: notesProvider.isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: kBrandGreen,
                  side: const BorderSide(color: kBrandGreen),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: notesProvider.isLoading ? null : _updateNote,
                icon: notesProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.update),
                label: const Text('Update Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notesProvider = context.read<NotesProvider>();

    final title = titleController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final description = descriptionController.text.trim();

    final success = await notesProvider.updateNote(
      id: widget.existingNote.id,
      title: title,
      description: description,
      price: price,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Note updated successfully!',
                  style: TextStyle(color: Colors.white)),
          backgroundColor: kBrandGreen,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            notesProvider.error ?? 'Failed to update note. Please try again.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      notesProvider.clearError();
    }
  }
}
