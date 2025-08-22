import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowModel {
  final String itemId;
  final String itemName;
  final String borrowerId;
  final String borrowerName;
  final String room;
  final DateTime borrowDateTime;
  final bool isReturned;
  final String imageUrl;
  final DateTime? estimatedTime;
  final DateTime? returnDateTime;
  final bool status;

  BorrowModel({
    required this.itemId,
    required this.itemName,
    required this.borrowerId,
    required this.borrowerName,
    required this.room,
    required this.borrowDateTime,
    required this.isReturned,
    required this.imageUrl,
    this.estimatedTime,
    this.returnDateTime,
    this.status = false,
  });

  factory BorrowModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return BorrowModel(
      itemId: data['itemId'] ?? '',
      itemName: data['itemName'] ?? '',
      borrowerId: data['borrowerId'] ?? '',
      borrowerName: data['borrowerName'] ?? '',
      room: data['room'] ?? '',
      borrowDateTime: (data['borrowDateTime'] as Timestamp).toDate(),
      isReturned: data['isReturned'] ?? false,
      imageUrl: data['imageUrl'] ?? '',
      estimatedTime:
          data['estimatedTime'] is Timestamp
              ? (data['estimatedTime'] as Timestamp).toDate()
              : (data['estimatedTime'] is String
                  ? DateTime.tryParse(data['estimatedTime'])
                  : null),
      returnDateTime:
          data['returnDateTime'] is Timestamp
              ? (data['returnDateTime'] as Timestamp).toDate()
              : null,
      status: data['status'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'room': room,
      'borrowDateTime': Timestamp.fromDate(borrowDateTime),
      'isReturned': isReturned,
      'imageUrl': imageUrl,
      'estimatedTime':
          estimatedTime != null ? Timestamp.fromDate(estimatedTime!) : null,
      'returnDateTime':
          returnDateTime != null ? Timestamp.fromDate(returnDateTime!) : null,
      'status': status,
    };
  }
}
