import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BorrowHistoryScreen extends StatefulWidget {
  const BorrowHistoryScreen({super.key});

  @override
  State<BorrowHistoryScreen> createState() => _BorrowHistoryScreenState();
}

class _BorrowHistoryScreenState extends State<BorrowHistoryScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<QueryDocumentSnapshot> borrowRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchUserBorrowRequests();
  }

  Future<void> _fetchUserBorrowRequests() async {
    try {
      final borrowRequestsSnapshot =
          await FirebaseFirestore.instance
              .collection('borrow_requests')
              .where('uid', isEqualTo: user?.uid)
              .get();

      setState(() {
        borrowRequests = borrowRequestsSnapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve borrow requests: $e')),
      );
    }
  }

  Future<void> _updateReturnStatus(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('borrow_requests')
          .doc(docId)
          .update({
            'isReturned': true,
            'returnDateTime': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item successfully returned.")),
      );
      _fetchUserBorrowRequests(); // refresh display
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update return status: $e")),
      );
    }
  }

  void _simulateUploadAndReturn(String docId) async {
    await Future.delayed(const Duration(seconds: 1));
    _updateReturnStatus(docId);
  }

  Widget _buildStatusChip(String text, Color color) {
    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrow History'),
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            borrowRequests.isEmpty
                ? const Center(
                  child: Text(
                    "No borrowed items found.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
                : ListView.builder(
                  itemCount: borrowRequests.length,
                  itemBuilder: (context, index) {
                    final doc = borrowRequests[index];
                    final borrowRequest = doc.data() as Map<String, dynamic>;

                    final itemName =
                        borrowRequest['itemName'] ?? 'Item Unavailable';
                    final borrowDateTime =
                        borrowRequest['borrowDateTime'] != null
                            ? (borrowRequest['borrowDateTime'] as Timestamp)
                                .toDate()
                            : DateTime.now();
                    final estimatedTime =
                        borrowRequest['estimatedTime'] != null
                            ? (borrowRequest['estimatedTime'] as Timestamp)
                                .toDate()
                            : DateTime.now();
                    final isReturned = borrowRequest['isReturned'] ?? false;
                    final returnDateTime =
                        borrowRequest['returnDateTime'] != null
                            ? (borrowRequest['returnDateTime'] as Timestamp)
                                .toDate()
                            : null;

                    final now = DateTime.now();
                    final bool isOverdue =
                        !isReturned && now.isAfter(estimatedTime);
                    final bool returnedLate =
                        isReturned &&
                        returnDateTime != null &&
                        returnDateTime.isAfter(estimatedTime);

                    // Colors and icons by condition
                    Color backgroundColor;
                    Icon leadingIcon;
                    String statusText;
                    Color statusColor;

                    if (isReturned) {
                      if (returnedLate) {
                        backgroundColor = Colors.yellow.shade100;
                        leadingIcon = const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                        );
                        statusText = 'Returned Late';
                        statusColor = Colors.orange.shade700;
                      } else {
                        backgroundColor = Colors.green.shade50;
                        leadingIcon = const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        );
                        statusText = 'Returned On Time';
                        statusColor = Colors.green.shade700;
                      }
                    } else if (isOverdue) {
                      backgroundColor = Colors.orange.shade100;
                      leadingIcon = const Icon(
                        Icons.timer_off,
                        color: Colors.orange,
                      );
                      statusText = 'Overdue';
                      statusColor = Colors.orange.shade700;
                    } else {
                      backgroundColor = Colors.red.shade50;
                      leadingIcon = const Icon(
                        Icons.schedule,
                        color: Colors.red,
                      );
                      statusText = 'Not Returned Yet';
                      statusColor = Colors.red.shade700;
                    }

                    // Borrow request status
                    String borrowStatusText;
                    Color borrowStatusColor;

                    switch (borrowRequest['status']) {
                      case 'approved':
                        borrowStatusText = 'Approved';
                        borrowStatusColor = Colors.green.shade600;
                        break;
                      case 'rejected':
                        borrowStatusText = 'Rejected';
                        borrowStatusColor = Colors.red.shade600;
                        break;
                      default:
                        borrowStatusText = 'Pending Approval';
                        borrowStatusColor = Colors.orange.shade600;
                    }

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: backgroundColor,
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                leadingIcon,
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    itemName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed:
                                      isReturned
                                          ? null
                                          : () =>
                                              _simulateUploadAndReturn(doc.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isReturned ? Colors.green : Colors.red,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: Icon(
                                    isReturned
                                        ? Icons.check_circle
                                        : Icons.upload,
                                  ),
                                  label: Text(
                                    isReturned ? "Returned" : "Upload & Return",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                _buildStatusChip(
                                  'Status: $borrowStatusText',
                                  borrowStatusColor,
                                ),
                                if (borrowRequest['status'] != 'rejected')
                                  _buildStatusChip(
                                    'Return Status: $statusText',
                                    statusColor,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            Text(
                              'Borrowed by: ${borrowRequest['borrowerName'] ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Room: ${borrowRequest['room'] ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Reason: ${borrowRequest['reason'] ?? 'No reason provided'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Borrowed on: ${DateFormat('dd-MM-yyyy HH:mm').format(borrowDateTime)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Estimated Return: ${DateFormat('dd-MM-yyyy HH:mm').format(estimatedTime)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            if (isReturned && returnDateTime != null)
                              Text(
                                'Returned on: ${DateFormat('dd-MM-yyyy HH:mm').format(returnDateTime)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
