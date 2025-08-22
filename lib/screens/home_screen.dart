import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiu_connect/screens/notification/notification_screen.dart';
import 'package:jiu_connect/widgets/post_card.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan gradien
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Home',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
          actions: [
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('borrow_requests')
                      .where('uid', isEqualTo: currentUser?.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                int overdueCount = 0;
                int pendingCount = 0;

                if (snapshot.hasData) {
                  final now = DateTime.now();

                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data()! as Map<String, dynamic>;

                    final status = data['status'];
                    final isReturned = data['isReturned'] ?? false;

                    if (status == 'pending') {
                      pendingCount++;
                    }

                    if (status == 'approved' && !isReturned) {
                      final estimatedTime =
                          (data['estimatedTime'] as Timestamp?)?.toDate();
                      if (estimatedTime != null &&
                          estimatedTime.isBefore(now)) {
                        overdueCount++;
                      }
                    }
                  }
                }

                final totalBadgeCount = pendingCount + overdueCount;
                NotificationBadgeController.updateBadge(totalBadgeCount);

                return Padding(
                  padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      ).then((_) {
                        setState(() {
                          NotificationBadgeController.clearBadge();
                        });
                      });
                    },
                    child: badges.Badge(
                      showBadge: totalBadgeCount > 0,
                      badgeContent: Text(
                        totalBadgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      badgeStyle: badges.BadgeStyle(
                        badgeColor: Colors.redAccent,
                        padding: const EdgeInsets.all(6),
                        elevation: 3,
                      ),
                      position: badges.BadgePosition.topEnd(top: -4, end: -4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;
          double width = constraints.maxWidth;

          if (width >= 1200) {
            crossAxisCount = 4;
          } else if (width >= 800) {
            crossAxisCount = 3;
          } else if (width >= 600) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }

          double childAspectRatio = (width / crossAxisCount) / 220;

          return StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('borrow_requests')
                    .where('status', isEqualTo: 'approved')
                    .where('isReturned', isEqualTo: false)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              //   return const Center(
              //     child: Text(
              //       "No active borrow requests have been approved yet.",
              //       style: TextStyle(fontSize: 16, color: Colors.black54),
              //     ),
              //   );
              // }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: Lottie.asset(
                          'assets/lottie/empty.json', // Pastikan path sesuai dengan lokasi kamu
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "There is no active borrow items",
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }
              final borrowDocs = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: GridView.builder(
                  itemCount: borrowDocs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final borrowData =
                        borrowDocs[index].data() as Map<String, dynamic>;

                    return Material(
                      borderRadius: BorderRadius.circular(16),
                      elevation: 4,
                      shadowColor: Colors.black26,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: PostCard(borrowData: borrowData),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationBadgeController {
  static int _badgeCount = 0;

  static int get badgeCount => _badgeCount;

  static void updateBadge(int count) {
    _badgeCount = count;
  }

  static void clearBadge() {
    _badgeCount = 0;
  }
}
