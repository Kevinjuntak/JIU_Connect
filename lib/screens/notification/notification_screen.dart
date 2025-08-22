import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:jiu_connect/providers/notifcation_provider.dart';
import 'package:jiu_connect/screens/notification/notification_badge_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationBadgeController.clearBadge();
    });
  }

  void cancelRequest(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Cancel Request"),
            content: const Text(
              "Are you sure you want to cancel this request?",
            ),
            actions: [
              TextButton(
                child: const Text("No"),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text("Yes"),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('borrow_requests')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request has been successfully cancelled."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('borrow_requests')
                .where('uid', isEqualTo: currentUser?.uid)
                .orderBy('requestDate', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('You do not have any notifications.'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data()! as Map<String, dynamic>;
              final itemName = data['itemName'] ?? 'Item';
              final room = data['room'] ?? '-';
              final requestDate = (data['requestDate'] as Timestamp).toDate();
              final status = data['status'] ?? 'pending';
              final estimatedTime =
                  (data['estimatedTime'] as Timestamp?)?.toDate();
              final borrowTime =
                  (data['borrowDateTime'] as Timestamp?)?.toDate();

              if (status == 'approved' && borrowTime != null) {
                final notifTime = borrowTime.subtract(const Duration(hours: 1));
                if (notifTime.isAfter(DateTime.now())) {
                  NotifcationProvider.scheduleNotification(
                    id: index,
                    title: 'Borrow Reminder',
                    body:
                        'Item "$itemName" is scheduled to be borrowed in 1 hour at room $room.',
                    scheduledTime: notifTime,
                  );
                }
              }

              final isLateReturn =
                  estimatedTime != null &&
                  DateTime.now().isAfter(estimatedTime) &&
                  status == 'approved' &&
                  (data['isReturned'] == false);

              return Card(
                color:
                    isLateReturn ? Colors.red.shade100 : Colors.purple.shade50,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Icon(
                    status == 'approved'
                        ? Icons.check_circle
                        : status == 'rejected'
                        ? Icons.cancel
                        : Icons.hourglass_empty,
                    color:
                        status == 'approved'
                            ? Colors.green
                            : status == 'rejected'
                            ? Colors.red
                            : Colors.orange,
                  ),
                  title: Text(itemName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Room: $room'),
                      Text(
                        'Request Date: ${DateFormat('dd-MM-yyyy HH:mm').format(requestDate)}',
                      ),
                      if (estimatedTime != null)
                        Text(
                          'Estimated Return Time: ${DateFormat('dd-MM-yyyy HH:mm').format(estimatedTime)}',
                        ),
                      Text(
                        'Status: ${status == 'approved'
                            ? 'Approved'
                            : status == 'rejected'
                            ? 'Rejected'
                            : 'Pending'}',
                        style: TextStyle(
                          color:
                              status == 'approved'
                                  ? Colors.green
                                  : status == 'rejected'
                                  ? Colors.red
                                  : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isLateReturn)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            '⚠️ This item is overdue. Please return it as soon as possible!',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (status == 'pending')
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => cancelRequest(context, doc.id),
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            label: const Text(
                              'Cancel Request',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
