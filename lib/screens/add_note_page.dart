import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/providers/notes_provider.dart';
import 'package:studybuddy/providers/materials_provider.dart';
import 'package:studybuddy/models/note.dart';
import 'package:studybuddy/models/school.dart';
import 'package:studybuddy/models/level.dart';
import 'package:studybuddy/models/module.dart';
import 'package:studybuddy/utils/constants.dart';

class AddNotePage extends StatefulWidget {
  final Note? existingNote;
  final bool isEditing;

  const AddNotePage({
    super.key,
    this.existingNote,
    this.isEditing = false,
  });

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  School? selectedSchool;
  Level? selectedLevel;
  Module? selectedModule;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Fetch materials data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialsProvider>().fetchSchools();
    });

    // Pre-fill fields if editing
    if (widget.isEditing && widget.existingNote != null) {
      titleController.text = widget.existingNote!.title;
      priceController.text = widget.existingNote!.price.toStringAsFixed(2);
      descriptionController.text = widget.existingNote!.description ?? '';
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
      body: Consumer<MaterialsProvider>(
        builder: (context, materialsProvider, child) {
          return SingleChildScrollView(
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
                    keyboardType: TextInputType.number,
                    controller: priceController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
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
                  buildSchoolDropdown(materialsProvider),
                  const SizedBox(height: 12),
                  buildLevelDropdown(materialsProvider),
                  const SizedBox(height: 12),
                  buildModuleDropdown(materialsProvider),
                  const SizedBox(height: 20),
                  buildFileUploadSection(),
                  const SizedBox(height: 20),
                  buildPreviewImagesSection(),
                  const SizedBox(height: 30),
                  buildActionButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSchoolDropdown(MaterialsProvider materialsProvider) {
    final schools = materialsProvider.schools;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'School',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<School>(
          value: selectedSchool,
          decoration: InputDecoration(
            hintText: 'Select School',
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
          items: schools.map((school) {
            return DropdownMenuItem(value: school, child: Text(school.name));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedSchool = value;
              selectedLevel = null;
              selectedModule = null;
            });
            if (value != null) {
              materialsProvider.fetchLevels(schoolId: value.id);
            }
          },
        ),
      ],
    );
  }

  Widget buildLevelDropdown(MaterialsProvider materialsProvider) {
    final levels = materialsProvider.levels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Level',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Level>(
          value: selectedLevel,
          decoration: InputDecoration(
            hintText: selectedSchool == null
                ? 'Select a school first'
                : 'Select Level',
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
          items: levels.map((level) {
            return DropdownMenuItem(value: level, child: Text(level.name));
          }).toList(),
          onChanged: selectedSchool == null
              ? null
              : (value) {
                  setState(() {
                    selectedLevel = value;
                    selectedModule = null;
                  });
                  if (value != null) {
                    materialsProvider.fetchModules(levelId: value.id);
                  }
                },
        ),
      ],
    );
  }

  Widget buildModuleDropdown(MaterialsProvider materialsProvider) {
    final modules = materialsProvider.modules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Module',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Module>(
          value: selectedModule,
          decoration: InputDecoration(
            hintText:
                selectedLevel == null ? 'Select a level first' : 'Select Module',
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
          items: modules.map((module) {
            return DropdownMenuItem(value: module, child: Text(module.name));
          }).toList(),
          onChanged: selectedLevel == null
              ? null
              : (value) {
                  setState(() {
                    selectedModule = value;
                  });
                },
        ),
      ],
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

  Widget buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload File',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'Click to upload or drag & drop',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PDF, DOC, DOCX, PPT, PPTX',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPreviewImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview Images (Required)',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload clear images of the first 3 pages to show buyers a preview. Accepted: JPG, PNG, WEBP.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: buildImageUploadField('Page 1')),
            const SizedBox(width: 12),
            Expanded(child: buildImageUploadField('Page 2')),
            const SizedBox(width: 12),
            Expanded(child: buildImageUploadField('Page 3')),
          ],
        ),
      ],
    );
  }

  Widget buildImageUploadField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Image selection coming soon!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Choose File',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'No file chosen',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
                onPressed: notesProvider.isLoading ? null : saveNote,
                icon: notesProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(widget.isEditing ? Icons.update : Icons.save),
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
      },
    );
  }

  Future<void> saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notesProvider = context.read<NotesProvider>();

    final title = titleController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final description = descriptionController.text.trim();
    final moduleId = selectedModule?.id ?? 0;

    bool success;
    if (widget.isEditing && widget.existingNote != null) {
      success = await notesProvider.updateNote(
        id: widget.existingNote!.id,
        title: title,
        description: description,
        price: price,
        moduleId: moduleId,
      );
    } else {
      success = await notesProvider.createNote(
        title: title,
        description: description,
        price: price,
        moduleId: moduleId,
      );
    }

    if (!mounted) return;

    if (success) {
      String message = widget.isEditing
          ? 'Note updated successfully!'
          : 'Note saved successfully!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: kBrandGreen,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            notesProvider.error ?? 'Failed to save note. Please try again.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      notesProvider.clearError();
    }
  }
}
