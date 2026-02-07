import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/providers/auth_provider.dart';
import 'package:studybuddy/screens/home_screen.dart';
import 'package:studybuddy/screens/sign_up_page.dart';
import 'package:studybuddy/utils/constants.dart';
import 'package:studybuddy/widgets/custom_button.dart';
import 'package:studybuddy/widgets/custom_textfield.dart';

class Loginpage extends StatefulWidget {
  final String? prefilledEmail;
  final String? prefilledPassword;

  const Loginpage({super.key, this.prefilledEmail, this.prefilledPassword});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool isPasswordVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if credentials are provided from sign up
    if (widget.prefilledEmail != null) {
      emailController.text = widget.prefilledEmail!;
    }
    if (widget.prefilledPassword != null) {
      passwordController.text = widget.prefilledPassword!;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  buildHeader(),
                  const SizedBox(height: 40),
                  buildLoginForm(),
                  const SizedBox(height: 24),
                  buildLoginButton(),
                  const SizedBox(height: 16),
                  buildForgotPassword(),
                  const SizedBox(height: 32),
                  buildSignUpLink(),
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
          child: const Icon(Icons.school, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to StudyBuddy!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please log in to continue.',
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

  Widget buildLoginForm() {
    return Column(
      children: [
        buildEmailField(),
        const SizedBox(height: 16),
        buildPasswordField(),
      ],
    );
  }

  Widget buildEmailField() {
    return CustomTextField(
      controller: emailController,
      label: 'Email',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget buildPasswordField() {
    return CustomTextField(
      controller: passwordController,
      label: 'Password',
      prefixIcon: Icons.lock_outlined,
      obscureText: !isPasswordVisible,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }

  Widget buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return authProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: kBrandGreen),
              )
            : CustomButton(text: 'Log In', onPressed: handleLogin);
      },
    );
  }

  Widget buildForgotPassword() {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Forgot password feature coming soon!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(color: kBrandGreen, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        TextButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpPage()),
            );

            // If user successfully registered, prefill the login form
            if (result != null && result is Map<String, dynamic>) {
              if (result['registered'] == true) {
                if (!mounted) return;
                setState(() {
                  emailController.text = result['email'] ?? '';
                  passwordController.text = result['password'] ?? '';
                });

                // Show a welcome message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Registration successful! You can now log in.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: kBrandGreen,
                  ),
                );
              }
            }
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(color: kBrandGreen, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> handleLogin() async {
    if (formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(email, password);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login successful! Welcome to StudyBuddy!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: kBrandGreen,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homescreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.error ?? 'Invalid email or password. Please try again.',
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
