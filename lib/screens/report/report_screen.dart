import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiu_connect/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  Uint8List? _imageBytes;

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_itemNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final userId = user?.uid;
      if (userId != null) {
        final reportData = {
          'itemName': _itemNameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'location': _locationController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'uid': userId,
          // Image upload not implemented in this demo
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('reports')
            .add(reportData);

        _itemNameController.clear();
        _descriptionController.clear();
        _locationController.clear();
        setState(() {
          _imageBytes = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit report: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    Color fillColor =
        themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white;
    Color borderColor =
        themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey;
    Color iconColor =
        themeProvider.isDarkMode ? Colors.white70 : Colors.grey[700]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Broken Item'),
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.blue,
        foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.white,
        elevation: 4,
      ),
      backgroundColor:
          themeProvider.isDarkMode ? Colors.black : Colors.blueGrey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Item Name
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                filled: true,
                fillColor: fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(Icons.inventory_2_outlined, color: iconColor),
                labelStyle: TextStyle(color: iconColor),
              ),
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description of Damage',
                filled: true,
                fillColor: fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(Icons.description_outlined, color: iconColor),
                labelStyle: TextStyle(color: iconColor),
              ),
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Location
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                filled: true,
                fillColor: fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(Icons.location_on_outlined, color: iconColor),
                labelStyle: TextStyle(color: iconColor),
              ),
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 25),

            // Image Upload Section
            Text(
              "Upload Damage Photo (Demo only, not saved)",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        themeProvider.isDarkMode
                            ? Colors.deepPurple.shade700
                            : Colors.deepPurple.shade200,
                    width: 2,
                  ),
                  image:
                      _imageBytes != null
                          ? DecorationImage(
                            image: MemoryImage(_imageBytes!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    _imageBytes == null
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 48,
                                color:
                                    themeProvider.isDarkMode
                                        ? Colors.deepPurple.shade300
                                        : Colors.deepPurple.shade300,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to select an image',
                                style: TextStyle(
                                  color:
                                      themeProvider.isDarkMode
                                          ? Colors.deepPurple.shade300
                                          : Colors.deepPurple.shade300,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    themeProvider.isDarkMode ? Colors.deepPurple : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              label: const Text('Submit Report'),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          themeProvider.toggleTheme(!themeProvider.isDarkMode);
        },
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.blue,
        child: Icon(
          themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
          color: Colors.white,
        ),
      ),
    );
  }
}
