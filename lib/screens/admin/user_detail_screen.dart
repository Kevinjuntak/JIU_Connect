import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getUserData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getUserBorrowHistory() {
    return FirebaseFirestore.instance
        .collection('borrow_requests')
        .where('uid', isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getUserReports() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('reports')
        .snapshots();
  }

  Future<void> _showBorrowForm(
    BuildContext context, {
    DocumentSnapshot? doc,
  }) async {
    final isEdit = doc != null;
    final data = doc?.data() as Map<String, dynamic>?;

    final itemNameController = TextEditingController(
      text: data?['itemName'] ?? '',
    );
    final itemIdController = TextEditingController(text: data?['itemId'] ?? '');
    final roomController = TextEditingController(text: data?['room'] ?? '');
    final reasonController = TextEditingController(text: data?['reason'] ?? '');

    DateTime borrowDate =
        data?['borrowDateTime'] != null
            ? (data!['borrowDateTime'] as Timestamp).toDate()
            : DateTime.now();
    DateTime estimatedTime =
        data?['estimatedTime'] != null
            ? (data!['estimatedTime'] as Timestamp).toDate()
            : DateTime.now().add(const Duration(hours: 3));

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEdit ? 'Edit Borrow Record' : 'Add Borrow Record'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    controller: itemNameController,
                    label: 'Item Name',
                  ),
                  _buildTextField(
                    controller: itemIdController,
                    label: 'Item ID',
                  ),
                  _buildTextField(controller: roomController, label: 'Room'),
                  _buildTextField(
                    controller: reasonController,
                    label: 'Reason',
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      "Borrow Date: ${borrowDate.toLocal().toString().split(' ')[0]}",
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: borrowDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) borrowDate = picked;
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      "Estimated Return: ${estimatedTime.toLocal().toString().split(' ')[0]}",
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: estimatedTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) estimatedTime = picked;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final newData = {
                    'itemName': itemNameController.text.trim(),
                    'itemId': itemIdController.text.trim(),
                    'room': roomController.text.trim(),
                    'reason': reasonController.text.trim(),
                    'borrowDateTime': borrowDate,
                    'estimatedTime': estimatedTime,
                    'returnDateTime': null,
                    'isReturned': false,
                    'requestDate': now,
                    'imageUrl': '',
                    'status': 'approved',
                    'uid': userId,
                    'borrowerId': userId,
                    'borrowerName': '',
                    'notes': null,
                  };

                  if (isEdit) {
                    await FirebaseFirestore.instance
                        .collection('borrow_requests')
                        .doc(doc!.id)
                        .update(newData);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('borrow_requests')
                        .add(newData);
                  }

                  Navigator.pop(context);
                },
                child: Text(isEdit ? 'Save Changes' : 'Add'),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Detail')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBorrowForm(context),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _getUserData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final data = snapshot.data!.data();
                if (data == null) return const Text("User data not found.");

                return _buildSectionCard(
                  title: "User Information",
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(data['nickname'] ?? 'No Name'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${data['email'] ?? '-'}"),
                        Text("Full Name: ${data['name'] ?? '-'}"),
                        Text("User ID: $userId"),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Borrow History
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getUserBorrowHistory(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildSectionCard(
                    title: "Borrow History",
                    child: const Text("No borrow records found."),
                  );
                }

                return _buildSectionCard(
                  title: "Borrow History",
                  child: Column(
                    children:
                        snapshot.data!.docs.map((doc) {
                          final data = doc.data();
                          return Card(
                            elevation: 1,
                            child: ListTile(
                              title: Text(data['itemName'] ?? 'Item'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Room: ${data['room'] ?? '-'}"),
                                  Text(
                                    "Borrow Date: ${(data['borrowDateTime'] as Timestamp).toDate().toLocal()}",
                                  ),
                                  Text(
                                    "Estimated Return: ${(data['estimatedTime'] as Timestamp).toDate().toLocal()}",
                                  ),
                                  Text(
                                    "Return Date: ${data['returnDateTime'] != null ? (data['returnDateTime'] as Timestamp).toDate().toLocal() : '-'}",
                                  ),
                                  Text("Status: ${data['status'] ?? '-'}"),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    await _showBorrowForm(context, doc: doc);
                                  } else if (value == 'delete') {
                                    await FirebaseFirestore.instance
                                        .collection('borrow_requests')
                                        .doc(doc.id)
                                        .delete();
                                  }
                                },
                                itemBuilder:
                                    (context) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),

            // Reports
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getUserReports(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildSectionCard(
                    title: "Damage Reports",
                    child: const Text("No reports found."),
                  );
                }

                return _buildSectionCard(
                  title: "Damage Reports",
                  child: Column(
                    children:
                        snapshot.data!.docs.map((doc) {
                          final data = doc.data();
                          return Card(
                            elevation: 1,
                            child: ListTile(
                              title: Text(data['itemName'] ?? 'Item'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Description: ${data['description'] ?? '-'}",
                                  ),
                                  Text("Location: ${data['location'] ?? '-'}"),
                                  Text(
                                    "Timestamp: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toLocal() : '-'}",
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
