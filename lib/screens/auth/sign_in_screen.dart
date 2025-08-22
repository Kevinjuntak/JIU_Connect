import 'package:flutter/material.dart';
import 'package:jiu_connect/constants/app_theme.dart';
import 'package:jiu_connect/constants/urls.dart';
import 'package:jiu_connect/providers/auth_provider.dart';
import 'package:jiu_connect/screens/admin/admin_dashboard_screen.dart';
import 'package:jiu_connect/screens/navigation_screen.dart';
import 'package:jiu_connect/screens/auth/sign_up_screen.dart';
import 'package:jiu_connect/widgets/custom_button.dart';
import 'package:jiu_connect/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ latar putih

      body: Stack(
        children: [
          // 🎬 Lottie background
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottie/background.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),

          // 📦 Login form content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Image.network(
                      logoUrl,
                      height: 220, // atau pakai width: 220,
                      fit: BoxFit.contain,
                    ),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter your email to reset password',
                              ),
                            ),
                          );
                          return;
                        }

                        final authProvider =
                            Provider.of<AuthenticationProvider>(
                              context,
                              listen: false,
                            );

                        try {
                          await authProvider.resetPassword(email);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password reset email sent! Please check your inbox.',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to send reset email: $e'),
                            ),
                          );
                        }
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: 'Login',
                    color: const Color.fromARGB(255, 0, 255, 60),
                    onPressed: () async {
                      final authProvider = Provider.of<AuthenticationProvider>(
                        context,
                        listen: false,
                      );
                      final email = emailController.text.trim();
                      final password = passwordController.text;
                      final success = await authProvider.signIn(
                        email,
                        password,
                      );

                      if (success) {
                        final role = await authProvider.getUserRole();
                        if (role == 'admin') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const AdminDashboardScreen(),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NavigationScreen(),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Login gagal. Periksa email & password.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),

                  ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              setState(() => isLoading = true);
                              final authProvider =
                                  Provider.of<AuthenticationProvider>(
                                    context,
                                    listen: false,
                                  );
                              final success =
                                  await authProvider.signInWithGoogle();

                              if (success) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const NavigationScreen(),
                                  ),
                                  (route) => false,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Google sign-in failed. Please try again.',
                                    ),
                                  ),
                                );
                              }
                              setState(() => isLoading = false);
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                            : const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 255, 34),
                                fontSize: 16,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
