import 'package:flutter/material.dart';

const kBrandGreen = Color(0xFF006644);

class AddNotePage extends StatefulWidget {
  final String? existingTitle;
  final String? existingPrice;
  final bool isEditing;

  const AddNotePage({
    super.key,
    this.existingTitle,
    this.existingPrice,
    this.isEditing = false,
  });

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  String? selectedSchool;
  String? selectedLevel;
  String? selectedModule;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if editing
    if (widget.isEditing) {
      titleController.text = widget.existingTitle ?? '';
      priceController.text = widget.existingPrice?.replaceAll('LKR ', '') ?? '';
    }
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
        title: Text(widget.isEditing ? 'Edit Note' : 'Add New Note'),
        centerTitle: true,
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTextField(
              label: 'Note Title',
              hint: 'Enter note title',
              controller: titleController,
            ),
            const SizedBox(height: 16),
            buildTextField(
              label: 'Price (LKR)',
              hint: 'Enter price in LKR',
              keyboardType: TextInputType.number,
              controller: priceController,
            ),
            const SizedBox(height: 20),
            buildTextField(
              label: 'Note Description',
              hint: 'Enter a brief description',
              maxLines: 8,
              controller: descriptionController,
            ),
            const SizedBox(height: 20),
            Text(
              'Category Selection',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kBrandGreen,
              ),
            ),
            const SizedBox(height: 12),
            buildDropdownField(
              label: 'School',
              value: selectedSchool,
              items: ['Computing', 'Business', 'Law'],
              onChanged: (value) => setState(() => selectedSchool = value),
            ),
            const SizedBox(height: 12),
            buildDropdownField(
              label: 'Level',
              value: selectedLevel,
              items: ['Level 4', 'Level 5', 'Level 6'],
              onChanged: (value) => setState(() => selectedLevel = value),
            ),
            const SizedBox(height: 12),
            buildDropdownField(
              label: 'Module',
              value: selectedModule,
              items: [
                'Commercial Computing',
                'Mobile App Development',
                'Server Side Programming',
                'Database and Data Structure',
                'Web Development',
                'Software Engineering',
              ],
              onChanged: (value) => setState(() => selectedModule = value),
            ),
            const SizedBox(height: 20),
            buildFileUploadSection(),
            const SizedBox(height: 30),
            buildActionButtons(),
          ],
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
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

  Widget buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: 'Select $label',
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
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget buildFileUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.upload_file, size: 48, color: kBrandGreen),
          const SizedBox(height: 12),
          const Text(
            'Upload Note Files',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload PDF, DOCX, or image files',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'File upload feature coming soon!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: kBrandGreen,
                ),
              );
            },
            icon: const Icon(Icons.attach_file),
            label: const Text('Choose Files'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: kBrandGreen,
              side: const BorderSide(color: kBrandGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
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
            onPressed: () {
              saveNote();
            },
            icon: Icon(widget.isEditing ? Icons.update : Icons.save),
            label: Text(widget.isEditing ? 'Update Note' : 'Save Note'),
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
  }

  void saveNote() {
    // Validate fields
    String message = widget.isEditing
        ? 'Note updated successfully!'
        : 'Note saved successfully!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: kBrandGreen,
      ),
    );
    Navigator.pop(context);
  }
}
