import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiu_connect/screens/admin/edit_user_screen.dart';
import 'package:jiu_connect/screens/admin/user_detail_screen.dart';
import 'package:badges/badges.dart' as badges;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildBorrowRequests() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('borrow_requests')
              .where('status', isEqualTo: 'pending')
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
          return const Center(child: Text('There is no request yet :).'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Request Pending: ${docs.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data()! as Map<String, dynamic>;
                  final docId = doc.id;

                  return Dismissible(
                    key: Key(docId),
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      String action =
                          direction == DismissDirection.startToEnd
                              ? 'Accept'
                              : 'Reject';
                      return await showDialog(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: Text('$action Request?'),
                              content: Text(
                                direction == DismissDirection.startToEnd
                                    ? 'Are you sure to approve this one?'
                                    : 'Are you sure to rejected this one?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Ya'),
                                ),
                              ],
                            ),
                      );
                    },
                    onDismissed: (direction) async {
                      final docRef = FirebaseFirestore.instance
                          .collection('borrow_requests')
                          .doc(docId);

                      if (direction == DismissDirection.startToEnd) {
                        // ACC / Approve
                        try {
                          await docRef.update({
                            'status': 'approved',
                            'isReturned': false,
                          });
                          print(
                            'Request approved and isReturned=false updated',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Peminjaman disetujui'),
                            ),
                          );
                        } catch (e) {
                          print('Failed to approve request: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menyetujui: $e')),
                          );
                        }
                      } else {
                        // TOLAK / Reject
                        print('Reject request id: $docId');
                        try {
                          await docRef.update({
                            'status': 'rejected',
                            'isReturned': true,
                          });
                          print('Update rejected and isReturned=true success');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Peminjaman ditolak dan isReturned diupdate',
                              ),
                            ),
                          );
                        } catch (e) {
                          print('Failed to update rejection: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal update reject: $e')),
                          );
                        }
                      }
                    },

                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(data['itemName'] ?? 'No Item'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("User: ${data['borrowerName'] ?? ''}"),
                            Text("Ruangan: ${data['room'] ?? ''}"),
                            Text("Status: ${data['status'] ?? 'pending'}"),
                            if (data['reason'] != null)
                              Text("Reason: ${data['reason']}"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildApprovedRequests() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('borrow_requests')
              .where('status', isEqualTo: 'approved')
              .orderBy('borrowDateTime', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        // Debug: Tampilkan jumlah dokumen approved
        print("Approved Requests count: ${docs.length}");

        if (docs.isEmpty) {
          return const Center(
            child: Text('Belum ada peminjaman yang disetujui.'),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data()! as Map<String, dynamic>;

            final itemName = data['itemName'] ?? 'No Item';
            final borrowerName = data['borrowerName'] ?? '';
            final room = data['room'] ?? '';
            final status = data['status'] ?? 'approved';
            final notes = data['notes'];
            final estimatedTime =
                data['estimatedTime'] != null
                    ? (data['estimatedTime'] as Timestamp)
                        .toDate()
                        .toLocal()
                        .toString()
                    : '-';
            final borrowDateTime =
                data['borrowDateTime'] != null
                    ? (data['borrowDateTime'] as Timestamp)
                        .toDate()
                        .toLocal()
                        .toString()
                    : '-';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(itemName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("User: $borrowerName"),
                    Text("Room: $room"),
                    Text("Status: $status"),
                    if (notes != null) Text("Notes: $notes"),
                    Text("Estiminated time: $estimatedTime"),
                    Text("Borrow time: $borrowDateTime"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDamageReports() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('reports')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .handleError((error) {
            print('Firestore stream error: $error');
          }),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Firestore error: ${snapshot.error}');
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        final reports = snapshot.data?.docs ?? [];

        print("Total laporan kerusakan ditemukan: ${reports.length}");
        for (var doc in reports) {
          print("Report data: ${doc.data()}");
          print("Path dokumen: ${doc.reference.path}");
        }

        if (reports.isEmpty) {
          return const Center(child: Text('Belum ada laporan kerusakan.'));
        }

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final data = reports[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.report_problem, color: Colors.red),
                title: Text(data['itemName'] ?? 'Item tidak dikenal'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Deskripsi: ${data['description'] ?? '-'}"),
                    Text("Lokasi: ${data['location'] ?? '-'}"),
                    if (data['timestamp'] != null)
                      Text(
                        "Dilaporkan: ${(data['timestamp'] as Timestamp).toDate().toLocal()}",
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserControlTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data?.docs ?? [];

        if (users.isEmpty) {
          return const Center(child: Text('Tidak ada pengguna.'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final doc = users[index];
            final data = doc.data() as Map<String, dynamic>;
            final userId = doc.id;

            final name = data['nickname'] ?? 'No name';
            final email = data['email'] ?? '-';
            final role = data['role'] ?? 'user';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("Email: $email"), Text("Role: $role")],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(doc.id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User berhasil dihapus")),
                      );
                    } else if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => EditUserScreen(
                                userId: doc.id,
                                currentNickname: name,
                                currentRole: role,
                                userEmail: email,
                              ),
                        ),
                      );
                    } else {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(doc.id)
                          .update({'role': value});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Role diubah menjadi $value")),
                      );
                    }
                  },
                  itemBuilder:
                      (context) => [
                        // // const PopupMenuItem(
                        // //   value: 'user',
                        // //   child: Text('Ubah jadi: User'),
                        // // ),
                        // // const PopupMenuItem(
                        // //   value: 'admin',
                        // //   child: Text('Ubah jadi: Admin'),
                        // ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit User'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Hapus User'),
                        ),
                      ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserDetailScreen(userId: userId),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Manangement User'),

            // Tab Requests dengan badge jumlah pending
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('borrow_requests')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
              builder: (context, snapshot) {
                int count = snapshot.data?.docs.length ?? 0;

                return Tab(
                  child: badges.Badge(
                    showBadge: count > 0,
                    badgeContent: Text(
                      count.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    position: badges.BadgePosition.topEnd(top: -12, end: -20),
                    child: const Text('Requests'),
                  ),
                );
              },
            ),

            const Tab(text: 'Approved'),
            const Tab(text: 'Damage Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserControlTab(), // 👈 NEW
          _buildBorrowRequests(),
          _buildApprovedRequests(),
          _buildDamageReports(), // 👈 Tambah ini
        ],
      ),
    );
  }
}
