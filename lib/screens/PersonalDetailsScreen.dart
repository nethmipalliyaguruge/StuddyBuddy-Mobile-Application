import 'package:flutter/material.dart';

const kBrandGreen = Color(0xFF006644);

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final TextEditingController _dobController = TextEditingController();

  @override
  void dispose() {
    _dobController.dispose();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabel('Name'),
                  buildTextField(
                    labelText: 'Full Name',
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 18),
                  buildLabel('Email'),
                  buildTextField(labelText: 'Email', prefixIcon: Icons.email),
                  const SizedBox(height: 18),
                  buildLabel('Phone Number'),
                  buildTextField(
                    labelText: 'Phone Number',
                    prefixIcon: Icons.phone,
                  ),
                  const SizedBox(height: 18),
                  buildLabel('Date of Birth'),
                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          labelText: 'Date of Birth',
                          prefixIcon: Icons.cake,
                          controller: _dobController,
                          readOnly: true,
                          hintText: 'dd/mm/yyyy',
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
                              _dobController.text =
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
                      onPressed: () {
                        // Save logic here
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        prefixIcon: Icon(prefixIcon),
      ),
    );
  }
