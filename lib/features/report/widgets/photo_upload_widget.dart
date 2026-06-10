import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class PhotoUploadWidget extends StatefulWidget {
  final String? photo;
  final Function(String?) onChanged;

  const PhotoUploadWidget({
    super.key,
    required this.photo,
    required this.onChanged,
  });

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  String? _localPhoto;

  @override
  void initState() {
    super.initState();
    _localPhoto = widget.photo;
  }

  @override
  void didUpdateWidget(covariant PhotoUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photo != oldWidget.photo && widget.photo != null) {
      setState(() {
        _localPhoto = widget.photo;
      });
    }
  }

  Future<void> _takePhotoDirectly() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (file != null) {
        setState(() {
          _localPhoto = file.path;
        });
        widget.onChanged(file.path);
      }
    } catch (e) {
      debugPrint("Erro ao abrir a câmera ou capturar imagem: $e");
    }
  }

  void _removePhoto() {
    setState(() {
      _localPhoto = null;
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            "Foto do Alagamento",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.darkNavy),
          ),
        ),
        GestureDetector(
          onTap: _localPhoto == null ? _takePhotoDirectly : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: _localPhoto != null ? Colors.black : AppColors.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _localPhoto != null ? Colors.transparent : AppColors.primaryBlue.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: _localPhoto != null
                ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    File(_localPhoto!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                //botão de excluir
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _removePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Icon(Icons.delete_rounded, color: AppColors.alertHigh, size: 22),
                    ),
                  ),
                ),
              ],
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //icone flutuante
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, size: 28, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Toque para abrir a câmera",
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Opcional, mas ajuda muito a comunidade.",
                    style: TextStyle(color: AppColors.textGreyBlue, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}