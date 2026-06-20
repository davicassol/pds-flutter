import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

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
      padding: const EdgeInsets.only(top: 60, bottom: 32, left: 24, right: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF4DB5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
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
                      ? const Icon(Icons.person_rounded, size: 50, color: AppColors.primaryBlue)
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
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.primaryBlue),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
              name.isNotEmpty ? name : "Usuário",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)
          ),
          const SizedBox(height: 4),
          Text(
              email,
              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14, fontWeight: FontWeight.w600)
          ),
        ],
      ),
    );
  }
}