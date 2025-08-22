import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jiu_connect/constants/urls.dart';

final Map<String, String> itemImageUrls = {
  'Extension Cable': extensioncable,
  'Projector': projector,
  'Speaker': speaker,
  'Pointer': pointer,
  'HDMI Cable': hdmicable,
  'Coaster Tray': coastertray,
  'Tablecloth': tablecloth,
};

class BorrowScreen extends StatefulWidget {
  const BorrowScreen({super.key});

  @override
  State<BorrowScreen> createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final Map<String, List<String>> itemVariants = {
    'Extension Cable': ['001', '002', '003', '004', '005'],
    'Projector': ['001', '002', '003', '004', '005'],
    'Speaker': ['001', '002', '003', '004', '005'],
    'Pointer': ['001', '002', '003', '004', '005'],
    'HDMI Cable': ['001', '002', '003', '004', '005'],
    'Coaster Tray': ['001', '002', '003', '004', '005'],
    'Tablecloth': ['001', '002', '003', '004', '005'],
  };

  String? selectedItem;
  String? selectedVariant;
  final TextEditingController roomController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  DateTime? estimatedDateTime;
  Map<String, bool> itemAvailability = {};
  bool isCheckingAvailability = false;

  Future<void> _checkItemAvailability(String itemName) async {
    setState(() {
      isCheckingAvailability = true;
      itemAvailability = {};
    });

    final itemNumbers = itemVariants[itemName]!;
    for (String number in itemNumbers) {
      final fullItemName = '$itemName $number';
      final snapshot =
          await FirebaseFirestore.instance
              .collection('borrow_requests')
              .where('itemName', isEqualTo: fullItemName)
              .where('isReturned', isEqualTo: false)
              .get();

      itemAvailability[number] = snapshot.docs.isNotEmpty;
    }

    setState(() {
      isCheckingAvailability = false;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && estimatedDateTime != null) {
      setState(() => _isSubmitting = true);

      final fullItemName = '${selectedItem!} ${selectedVariant!}';
      final room = roomController.text;
      final reason = reasonController.text;
      final estimate = estimatedDateTime;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final borrowRef = FirebaseFirestore.instance.collection(
          'borrow_requests',
        );

        final querySnapshot =
            await borrowRef
                .where('itemName', isEqualTo: fullItemName)
                .where('isReturned', isEqualTo: false)
                .where('status', isEqualTo: 'approved')
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$fullItemName sedang dipinjam')),
          );
          return;
        }

        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        final nickname = userDoc.data()?['nickname'] ?? 'Unknown';

        await borrowRef.add({
          'itemName': fullItemName,
          'itemId': selectedVariant ?? '',
          'room': room,
          'reason': reason,
          'estimatedTime': Timestamp.fromDate(estimate!),
          'borrowDateTime': FieldValue.serverTimestamp(),
          'isReturned': false,
          'returnDateTime': null,
          'uid': user.uid,
          'borrowerName': nickname,
          'borrowerId': user.uid,
          'imageUrl': '',
          'notes': null,
          'status': 'pending',
          'requestDate': Timestamp.now(),
        });

        setState(() {
          _isSubmitting = false;
          selectedItem = null;
          selectedVariant = null;
          estimatedDateTime = null;
          roomController.clear();
          reasonController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Form submitted successfully. Menunggu persetujuan admin.',
            ),
          ),
        );
      } else {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final todayAt5PM = DateTime(now.year, now.month, now.day, 17);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now,
    );

    if (selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    final pickedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (pickedDateTime.isAfter(todayAt5PM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waktu maksimal hanya sampai jam 5 sore hari ini'),
        ),
      );
      return;
    }

    setState(() {
      estimatedDateTime = pickedDateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrow Item')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Borrow Item Form',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          DropdownButtonFormField<String>(
                            value: selectedItem,
                            decoration: const InputDecoration(
                              labelText: 'Select Item',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                itemVariants.keys.map((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                            onChanged: (value) async {
                              setState(() {
                                selectedItem = value;
                                selectedVariant = null;
                              });
                              if (value != null) {
                                await _checkItemAvailability(value);
                              }
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select an item'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          if (selectedItem != null &&
                              itemImageUrls.containsKey(selectedItem!))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  itemImageUrls[selectedItem!]!,
                                  height: 180,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.broken_image,
                                            size: 100,
                                          ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          if (selectedItem != null)
                            isCheckingAvailability
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : DropdownButtonFormField<String>(
                                  value: selectedVariant,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Item Number',
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      itemVariants[selectedItem!]!.map((
                                        variant,
                                      ) {
                                        final isBorrowed =
                                            itemAvailability[variant] ?? false;
                                        return DropdownMenuItem(
                                          value: variant,
                                          enabled: !isBorrowed,
                                          child: Row(
                                            children: [
                                              Text('$selectedItem $variant'),
                                              if (isBorrowed) ...[
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.block,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  '(Dipinjam)',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedVariant = value;
                                    });
                                  },
                                  validator:
                                      (value) =>
                                          value == null
                                              ? 'Please select item number'
                                              : null,
                                ),
                          if (selectedItem != null) const SizedBox(height: 16),

                          TextFormField(
                            controller: roomController,
                            decoration: const InputDecoration(
                              labelText: 'Class / Room',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter room/class'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: reasonController,
                            decoration: const InputDecoration(
                              labelText: 'Reason for borrowing',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter reason'
                                        : null,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: _pickDateTime,
                            child: Text(
                              estimatedDateTime == null
                                  ? 'Select Estimated Time'
                                  : 'Selected: ${estimatedDateTime.toString()}',
                            ),
                          ),
                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            child:
                                _isSubmitting
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
