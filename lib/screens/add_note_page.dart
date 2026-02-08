import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:studybuddy/providers/notes_provider.dart';
import 'package:studybuddy/providers/materials_provider.dart';
import 'package:studybuddy/models/school.dart';
import 'package:studybuddy/models/level.dart';
import 'package:studybuddy/models/module.dart';
import 'package:studybuddy/utils/constants.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

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
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _noteFile;
  int? _noteFileSize;
  final List<XFile> _previewImages = [];

  @override
  void initState() {
    super.initState();

    // Fetch materials data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialsProvider>().fetchSchools();
    });
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
        title: const Text('Add New Note'),
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

    // Reset selection if it's no longer in the current list
    if (selectedSchool != null && !schools.contains(selectedSchool)) {
      selectedSchool = null;
      selectedLevel = null;
      selectedModule = null;
    }

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
          isExpanded: true,
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
            return DropdownMenuItem(value: school, child: Text(school.name, overflow: TextOverflow.ellipsis));
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

    // Reset selection if it's no longer in the current list
    if (selectedLevel != null && !levels.contains(selectedLevel)) {
      selectedLevel = null;
      selectedModule = null;
    }

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
          isExpanded: true,
          key: ValueKey('level_${selectedSchool?.id}'),
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
            return DropdownMenuItem(value: level, child: Text(level.name, overflow: TextOverflow.ellipsis));
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

    // Reset selection if it's no longer in the current list
    if (selectedModule != null && !modules.contains(selectedModule)) {
      selectedModule = null;
    }

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
          isExpanded: true,
          key: ValueKey('module_${selectedLevel?.id}'),
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
            return DropdownMenuItem(value: module, child: Text(module.name, overflow: TextOverflow.ellipsis));
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

  Future<void> _pickNoteFile() async {
    try {
      const typeGroup = XTypeGroup(
        label: 'Documents',
        extensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file != null && mounted) {
        final size = await file.length();
        setState(() {
          _noteFile = file;
          _noteFileSize = size;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _getFileExtension(String name) {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last : null;
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget buildFileUploadSection() {
    final hasFile = _noteFile != null;

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
        GestureDetector(
          onTap: _pickNoteFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: hasFile
                  ? kBrandGreen.withValues(alpha: 0.05)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFile ? kBrandGreen : Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  hasFile
                      ? _getFileIcon(_getFileExtension(_noteFile!.name))
                      : Icons.cloud_upload_outlined,
                  size: 48,
                  color: hasFile ? kBrandGreen : Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  hasFile
                      ? _noteFile!.name
                      : 'Tap to select a file',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: hasFile
                        ? kBrandGreen
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  hasFile
                      ? '${_getFileExtension(_noteFile!.name)?.toUpperCase() ?? ''} - ${_formatFileSize(_noteFileSize)} - Tap to change'
                      : 'PDF, DOC, DOCX, PPT, PPTX',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _pickPreviewImages() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: kBrandGreen),
                title: const Text('Choose from Gallery'),
                subtitle: Text(
                  'Select up to ${3 - _previewImages.length} image${3 - _previewImages.length == 1 ? '' : 's'}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              if (_previewImages.length < 3)
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: kBrandGreen),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (images.isNotEmpty && mounted) {
        final remaining = 3 - _previewImages.length;
        final toAdd = images.take(remaining).toList();
        setState(() => _previewImages.addAll(toAdd));
        if (images.length > remaining && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 3 preview images allowed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        if (_previewImages.length < 3) {
          setState(() => _previewImages.add(image));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget buildPreviewImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview Images',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Select 1-3 preview images to show buyers. (${_previewImages.length}/3 selected)',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        if (_previewImages.isEmpty)
          _buildAddImageCard(fullWidth: true)
        else
          Row(
            children: [
              for (int i = 0; i < _previewImages.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _buildSelectedImageCard(i)),
              ],
              if (_previewImages.length < 3) ...[
                const SizedBox(width: 12),
                Expanded(child: _buildAddImageCard()),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildSelectedImageCard(int index) {
    final image = _previewImages[index];
    return Stack(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: kBrandGreen),
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: kIsWeb
                  ? NetworkImage(image.path) as ImageProvider
                  : FileImage(File(image.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _previewImages.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageCard({bool fullWidth = false}) {
    return GestureDetector(
      onTap: _pickPreviewImages,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey.shade400),
              const SizedBox(height: 4),
              Text(
                fullWidth ? 'Add preview images' : 'Add',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              if (fullWidth)
                Text(
                  'Tap to select 1-3 images',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
            ],
          ),
        ),
      ),
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
                    : const Icon(Icons.save),
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
      },
    );
  }

  Future<void> saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_previewImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one preview image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final notesProvider = context.read<NotesProvider>();

    final title = titleController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final description = descriptionController.text.trim();
    final moduleId = selectedModule?.id ?? 0;

    // Read file bytes from XFile (works on both web and native)
    Uint8List? fileBytes;
    String? fileName;
    if (_noteFile != null) {
      fileBytes = await _noteFile!.readAsBytes();
      fileName = _noteFile!.name;
    }

    final List<Uint8List> previewBytesList = [];
    final List<String> previewNamesList = [];
    for (final img in _previewImages) {
      previewBytesList.add(await img.readAsBytes());
      previewNamesList.add(img.name);
    }

    final success = await notesProvider.createNote(
      title: title,
      description: description,
      price: price,
      moduleId: moduleId,
      fileBytes: fileBytes,
      fileName: fileName,
      previewImageBytesList: previewBytesList.isNotEmpty ? previewBytesList : null,
      previewImageNames: previewNamesList.isNotEmpty ? previewNamesList : null,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully!',
              style: TextStyle(color: Colors.white)),
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
