import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../constants/urls.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'borrow/borrow_screen.dart';
import 'report/report_screen.dart';
import 'profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int screenIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    BorrowScreen(),
    ReportScreen(),
    const ProfileScreen(),
  ];

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        centerTitle: true,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        title: Center(child: Image.network(logoUrl, height: 300)),
      ),
      body: screens[screenIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: screenIndex,
        onTap: (index) {
          setState(() {
            screenIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Borrow',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),

      // Tombol floating di kanan bawah untuk toggle dark mode
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          themeProvider.toggleTheme(!themeProvider.isDarkMode);
        },
        child: Icon(
          themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
        ),
      ),
    );
  }
}
