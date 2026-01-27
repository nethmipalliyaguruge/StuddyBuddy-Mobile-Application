import 'package:flutter/material.dart';
import 'package:studybuddy/utils/constants.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Details"),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildLabel('Name'),
                    buildTextField(
                      labelText: 'Full Name',
                      prefixIcon: Icons.person,
                      controller: nameController,
                      validator: validateName,
                    ),
                    const SizedBox(height: 18),
                    buildLabel('Email'),
                    buildTextField(
                      labelText: 'Email',
                      prefixIcon: Icons.email,
                      controller: emailController,
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    buildLabel('Phone Number'),
                    buildTextField(
                      labelText: 'Phone Number',
                      prefixIcon: Icons.phone,
                      controller: phoneController,
                      validator: validatePhone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    buildLabel('Date of Birth'),
                    Row(
                      children: [
                        Expanded(
                          child: buildTextField(
                            labelText: 'Date of Birth',
                            prefixIcon: Icons.cake,
                            controller: dobController,
                            readOnly: true,
                            hintText: 'dd/mm/yyyy',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please select your date of birth';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month_outlined),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1999, 1, 1),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dobController.text =
                                    "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: savePersonalDetails,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Validation Methods
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  void savePersonalDetails() {
    if (_formKey.currentState!.validate()) {
      // Simulate saving data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Personal details saved successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: kBrandGreen,
          duration: Duration(seconds: 3),
        ),
      );

      // Optional: Navigate back after successful save
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pop(context);
      });
    }
  }
}

Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6.0),
    child: Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );
}

Widget buildTextField({
  required String labelText,
  required IconData prefixIcon,
  TextEditingController? controller,
  bool readOnly = false,
  String? hintText,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
}) {
  return TextFormField(
    controller: controller,
    readOnly: readOnly,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: kBrandGreen, width: 2),
      ),
      prefixIcon: Icon(prefixIcon, color: kBrandGreen),
    ),
  );
}
