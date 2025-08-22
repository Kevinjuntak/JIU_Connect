import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiu_connect/screens/borrow/borrow_detail_screen.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> borrowData;

  const PostCard({Key? key, required this.borrowData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemName = borrowData['itemName'] ?? 'Item Name Not Available';
    final variant = borrowData['itemId'] ?? 'No Variant';
    final Timestamp? estimatedTimestamp = borrowData['estimatedTime'];
    final DateTime? estimatedTime =
        estimatedTimestamp != null ? estimatedTimestamp.toDate() : null;

    final estimatedReturn =
        estimatedTime != null
            ? DateFormat('dd MMM yyyy, HH:mm').format(estimatedTime)
            : 'No Estimated Return Date';

    final nickname =
        (borrowData['borrowerName'] as String?)?.isNotEmpty == true
            ? borrowData['borrowerName']
            : 'Unknown User';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BorrowDetailScreen(borrowData: borrowData),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Variant: $variant',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                'Estimated Return: $estimatedReturn',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text('Borrower: $nickname', style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
