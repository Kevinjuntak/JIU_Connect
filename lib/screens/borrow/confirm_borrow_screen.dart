import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ConfirmBorrowScreen extends StatefulWidget {
  const ConfirmBorrowScreen({super.key});

  @override
  State<ConfirmBorrowScreen> createState() => _UploadFotoScreenState();
}

class _UploadFotoScreenState extends State<ConfirmBorrowScreen> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    ); // atau camera

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submitDemo() {
    if (_image != null) {
      Navigator.pop(context, true); // kirim "true" ke halaman sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih foto terlebih dahulu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Foto Barang')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Placeholder(fallbackHeight: 200),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo),
              label: const Text('Pilih Foto'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitDemo,
              child: const Text('Lanjutkan (Demo)'),
            ),
          ],
        ),
      ),
    );
  }
}
