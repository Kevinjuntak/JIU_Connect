import 'package:flutter/material.dart';
import 'package:jiu_connect/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_button.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final name = nameController.text.trim();
    final nickname = nicknameController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    setState(() => isLoading = true);

    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    final success = await authProvider.signUp(email, password, name, nickname);

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Account created successfully. Please verify your email.",
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign Up failed. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create your account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              CustomInputField(
                controller: nameController,
                labelText: 'Name',
                hintText: 'Enter your full name',
              ),
              const SizedBox(height: 16),

              CustomInputField(
                controller: nicknameController,
                labelText: 'Nickname',
                hintText: 'Enter your nickname',
              ),
              const SizedBox(height: 16),

              CustomInputField(
                controller: emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              CustomInputField(
                controller: passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                obscureText: true,
              ),
              const SizedBox(height: 16),

              CustomInputField(
                controller: confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                obscureText: true,
              ),
              const SizedBox(height: 24),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                    text: 'Sign Up',
                    color: Theme.of(context).primaryColor,
                    onPressed: _handleSignUp,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
