import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUploadWidget extends StatelessWidget {
  final String? photo;
  final Function(String?) onChanged;

  const PhotoUploadWidget({
    super.key,
    required this.photo,
    required this.onChanged,
  });

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      onChanged(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Photo (Optional)"),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: pickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: photo != null
                ? Stack(
              children: [
                Image.file(
                  File(photo!),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => onChanged(null),
                    child: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
                : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                  SizedBox(height: 6),
                  Text("Tap to upload photo"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}