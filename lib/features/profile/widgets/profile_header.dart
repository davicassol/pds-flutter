import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final File? localImage;
  final Function(File) onImagePicked;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.photoUrl,
    this.localImage,
    required this.onImagePicked,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 30, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: localImage != null
                      ? FileImage(localImage!) as ImageProvider
                      : (photoUrl != null ? NetworkImage(photoUrl!) as ImageProvider : null),
                  child: (localImage == null && photoUrl == null)
                      ? const Icon(Icons.person, size: 50, color: Colors.blue)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.blue),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
              name.isNotEmpty ? name : "Usuário",
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 4),
          Text(
              email,
              style: const TextStyle(color: Colors.white54, fontSize: 14)
          ),
        ],
      ),
    );
  }
}