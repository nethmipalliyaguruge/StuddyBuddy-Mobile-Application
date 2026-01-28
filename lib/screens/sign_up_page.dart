import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/providers/auth_provider.dart';
import 'package:studybuddy/utils/constants.dart';
import 'package:studybuddy/utils/helpers.dart';
import 'package:studybuddy/widgets/custom_button.dart';
import 'package:studybuddy/widgets/custom_textfield.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool acceptTerms = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildHeader(),
                  const SizedBox(height: 32),
                  buildSignUpForm(),
                  const SizedBox(height: 20),
                  buildTermsCheckbox(),
                  const SizedBox(height: 24),
                  buildSignUpButton(),
                  const SizedBox(height: 16),
                  buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: kBrandGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.person_add, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join StudyBuddy and start learning!',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget buildSignUpForm() {
    return Column(
      children: [
        CustomTextField(
          controller: nameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          prefixIcon: Icons.person_outline,
          validator: Helpers.validateName,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: emailController,
          label: 'Email Address',
          hint: 'Enter your email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: Helpers.validateEmail,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: phoneController,
          label: 'Phone Number',
          hint: 'Enter your phone number',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: Helpers.validatePhone,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: passwordController,
          label: 'Password',
          hint: 'Enter your password',
          obscureText: !isPasswordVisible,
          prefixIcon: Icons.lock_outlined,
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
          validator: Helpers.validatePassword,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          obscureText: !isConfirmPasswordVisible,
          prefixIcon: Icons.lock_outlined,
          suffixIcon: IconButton(
            icon: Icon(
              isConfirmPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              setState(() {
                isConfirmPasswordVisible = !isConfirmPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: acceptTerms,
          onChanged: (value) {
            setState(() {
              acceptTerms = value ?? false;
            });
          },
          activeColor: kBrandGreen,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                acceptTerms = !acceptTerms;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 9.0),
              child: Text(
                'I accept the Terms and Conditions and Privacy Policy',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSignUpButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return authProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: kBrandGreen),
              )
            : CustomButton(text: 'Create Account', onPressed: handleSignUp);
      },
    );
  }

  Widget buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Log In',
            style: TextStyle(color: kBrandGreen, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> handleSignUp() async {
    if (formKey.currentState!.validate()) {
      if (!acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please accept the Terms and Conditions',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get the registered credentials
      String registeredName = nameController.text.trim();
      String registeredEmail = emailController.text.trim();
      String registeredPhone = phoneController.text.trim();
      String registeredPassword = passwordController.text.trim();

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        name: registeredName,
        email: registeredEmail,
        phone: registeredPhone,
        password: registeredPassword,
        passwordConfirmation: confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully! Redirecting to login...',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: kBrandGreen,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to LoginPage with credentials
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.pop(context, {
            'email': registeredEmail,
            'password': registeredPassword,
            'registered': true,
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.error ?? 'Registration failed. Please try again.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        authProvider.clearError();
      }
    }
  }
}
