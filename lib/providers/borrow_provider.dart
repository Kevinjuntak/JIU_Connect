// // import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:jiu_connect/models/borrow_model.dart';

// class BorrowProvider with ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> submitBorrow({
//     required String itemId,
//     required String itemName,
//     required String variant,
//     required String room,
//     required String reason,
//     required DateTime estimatedDateTime,
//     required String imageUrl,
//     required String borrowerName,
//   }) async {
//     // Membuat objek BorrowModel
//     final borrow = BorrowModel(
//       itemId: itemId,
//       itemName: '$itemName $variant', // Gabungkan nama item dengan variant
//       borrowerId: '', // Tidak perlu terkait dengan user
//       borrowerName: borrowerName,
//       room: room,
//       borrowDateTime: estimatedDateTime,
//       isReturned: false, // Set status peminjaman awalnya 'belum dikembalikan'
//       imageUrl: imageUrl,
//     );

//     // Simpan data ke koleksi 'borrow_requests' global di Firestore
//     try {
//       await _firestore.collection('borrow_requests').add(borrow.toFirestore());
//     } catch (e) {
//       print("Error submitting borrow: $e");
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jiu_connect/models/borrow_model.dart';

class BorrowProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitBorrow({
    required String itemId,
    required String itemName,
    required String variant,
    required String room,
    required String reason,
    required DateTime estimatedDateTime,
    required String imageUrl,
    required String borrowerId, // tetap dipakai
    required String borrowerName,
  }) async {
    final borrow = BorrowModel(
      itemId: itemId,
      itemName: '$itemName $variant',
      borrowerId: borrowerId,
      borrowerName: borrowerName,
      room: room,
      borrowDateTime: DateTime.now(), // waktu submit sekarang
      isReturned: false,
      imageUrl: imageUrl,
      estimatedTime: estimatedDateTime,
      status: false, // false artinya belum disetujui (pending)
    );

    try {
      await _firestore.collection('borrow_requests').add(borrow.toFirestore());
      print("✅ Borrow request submitted as pending (status=false).");
    } catch (e) {
      print("❌ Error submitting borrow: $e");
    }
  }

  // Ambil semua request yang belum disetujui (status == false)
  Future<List<BorrowModel>> getPendingRequests() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('borrow_requests')
              .where('status', isEqualTo: false)
              .get();

      return querySnapshot.docs
          .map((doc) => BorrowModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("❌ Error fetching pending requests: $e");
      return [];
    }
  }

  // Admin menyetujui request -> set status jadi true
  Future<void> approveRequest(String requestId) async {
    try {
      await _firestore.collection('borrow_requests').doc(requestId).update({
        'status': true,
      });
      print("✅ Request approved (status=true).");
    } catch (e) {
      print("❌ Error approving request: $e");
    }
  }

  // Admin menolak request -> bisa set status tetap false, atau hapus dokumen, atau buat flag lain
  Future<void> rejectRequest(String requestId) async {
    try {
      // Misal tetap status false, atau bisa tambahkan field lain 'isRejected'
      // Berikut contoh hapus dokumen:
      await _firestore.collection('borrow_requests').doc(requestId).delete();
      print("❌ Request rejected and deleted.");
    } catch (e) {
      print("❌ Error rejecting request: $e");
    }
  }
}
