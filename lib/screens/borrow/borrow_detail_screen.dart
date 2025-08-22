import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowDetailScreen extends StatelessWidget {
  final Map<String, dynamic> borrowData;

  const BorrowDetailScreen({Key? key, required this.borrowData})
    : super(key: key);

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final borrowerName =
        (borrowData['borrowerName'] as String?)?.isNotEmpty == true
            ? borrowData['borrowerName']
            : 'Unknown';
    final itemName = borrowData['itemName'] ?? '-';
    final itemVariant = borrowData['itemId'] ?? '-';
    final room = borrowData['room'] ?? '-';
    final borrowDate = formatDate(borrowData['borrowDateTime']);
    final estimatedReturn = formatDate(borrowData['estimatedTime']);
    final status = (borrowData['status'] ?? '-').toString();
    final reason = borrowData['reason'] ?? '-';

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green.shade700;
        break;
      case 'pending':
        statusColor = Colors.orange.shade700;
        break;
      case 'rejected':
        statusColor = Colors.red.shade700;
        break;
      default:
        statusColor = Colors.grey.shade600;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrow Details'),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: Colors.blueAccent.withOpacity(0.4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRow(label: 'Borrower Name', value: borrowerName),
                DetailRow(label: 'Item Name', value: itemName),
                DetailRow(label: 'Item Variant', value: itemVariant),
                DetailRow(label: 'Room', value: room),
                DetailRow(label: 'Borrow Date', value: borrowDate),
                DetailRow(label: 'Estimated Return', value: estimatedReturn),
                DetailRow(
                  label: 'Status',
                  value: status,
                  valueColor: statusColor,
                ),
                DetailRow(label: 'Reason', value: reason),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const DetailRow({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight:
                    valueColor != null ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
