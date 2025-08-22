import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiu_connect/constants/app_theme.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nicknameController = TextEditingController();
  final _nameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  String? selectedImageUrl;
  bool _showImagePicker = false;

  final List<String> imageOptions = [
    'https://raw.githubusercontent.com/Kevinjuntak/JIU_Connect/refs/heads/main/Jeffrey.png',
    'https://raw.githubusercontent.com/Kevinjuntak/JIU_Connect/refs/heads/main/Meisam.png',
    'https://raw.githubusercontent.com/Kevinjuntak/JIU_Connect/refs/heads/main/kevin.png',
    'https://raw.githubusercontent.com/Kevinjuntak/JIU_Connect/refs/heads/main/Rafin.png',
    'https://raw.githubusercontent.com/Kevinjuntak/JIU_Connect/refs/heads/main/Edo.png',
    'https://raw.githubusercontent.com/Kevinjuntak/JIU_Connect/refs/heads/main/Ryan.png',
    'https://raw.githubusercontent.com/Kevinjuntak/JIU_Connect/refs/heads/main/Caca.png',
    'https://raw.githubusercontent.com/Kevinjuntak/JIU_Connect/refs/heads/main/Daniel.png',
    'https://raw.githubusercontent.com/Kevinjuntak/JIU_Connect/refs/heads/main/Clay.png',
    'https://raw.githubusercontent.com/Kevinjuntak/JIU_Connect/refs/heads/main/hegel.png',
    'https://raw.githubusercontent.com/Kevinjuntak/JIU_Connect/refs/heads/main/kelvindsdf.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    FirebaseFirestore.instance.collection('users').doc(user?.uid).get().then((
      doc,
    ) {
      if (doc.exists) {
        final data = doc.data()!;
        _nicknameController.text = data['nickname'] ?? '';
        _nameController.text = data['name'] ?? '';
        selectedImageUrl = data['profileImage'] ?? '';
        setState(() {});
      }
    });
  }

  Future<void> _updateProfile() async {
    if (_nicknameController.text.isEmpty || selectedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nickname dan gambar profil wajib diisi.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await user?.updateDisplayName(_nicknameController.text);
      await user?.updatePhotoURL(selectedImageUrl);
      await user?.reload();

      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'nickname': _nicknameController.text,
        'name': _nameController.text,
        'profileImage': selectedImageUrl,
        'uid': user?.uid,
        'email': user?.email,
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui profil: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.backgroundGradientStart,
                  AppColors.backgroundGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                color: AppColors.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: AppSizes.avatarRadius,
                          backgroundImage:
                              selectedImageUrl != null &&
                                      selectedImageUrl!.isNotEmpty
                                  ? NetworkImage(selectedImageUrl!)
                                  : null,
                          backgroundColor: Colors.grey.shade300,
                          child:
                              selectedImageUrl == null ||
                                      selectedImageUrl!.isEmpty
                                  ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showImagePicker = !_showImagePicker;
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: Text(
                            _showImagePicker ? 'Hide Profile' : 'Edit Profile',
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.formSpacing),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: AppSizes.formSpacing),
                      TextFormField(
                        controller: _nicknameController,
                        decoration: InputDecoration(
                          labelText: 'Nickname',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.tag),
                        ),
                      ),
                      const SizedBox(height: AppSizes.formSpacing),

                      if (_showImagePicker) ...[
                        const Text(
                          'Pilih Avatar:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children:
                              imageOptions.map((url) {
                                final isSelected = url == selectedImageUrl;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => selectedImageUrl = url);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? Colors.blue
                                                : Colors.transparent,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],

                      const SizedBox(height: AppSizes.formSpacing * 1.5),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.buttonVerticalPadding,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.buttonBorderRadius,
                              ),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Update Profile',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.buttonTextColor,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
