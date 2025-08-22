import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:jiu_connect/constants/urls.dart';
import 'package:jiu_connect/screens/auth/sign_in_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Latar belakang putih
      body: Stack(
        children: [
          // 🔹 Background animation (di atas warna putih)
          SizedBox.expand(
            child: Lottie.asset(
              'assets/lottie/background.json',
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Foreground content (logo + tombol)
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 350),
                    Image.network(logoUrl, height: 200, fit: BoxFit.contain),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4facfe),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFF4facfe)),
                        ),
                        child: const Text(
                          "Let's Go",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
