import 'package:flutter/material.dart';

const kBrandGreen = Color(0xFF006644);

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  String? selectedSchool;
  String? selectedLevel;
  String? selectedModule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Note'),
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
            ),
            const SizedBox(height: 16),
            buildTextField(
              label: 'Price (LKR)',
              hint: 'Enter price in LKR',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            buildTextField(
              label: 'Note Description',
              hint: 'Enter a brief description',
              maxLines: 8,
            ),
            const SizedBox(height: 20),
            Text(
              'Category Selection',
              style: TextStyle(
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
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
                  content: Text('File upload feature coming soon!'),
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
            icon: const Icon(Icons.save),
            label: const Text('Save Note'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note saved successfully!'),
        backgroundColor: kBrandGreen,
      ),
    );
    Navigator.pop(context);
  }
}
