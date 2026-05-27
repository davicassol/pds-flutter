import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
          _localPhoto = file.path; // atualiza a caixinha na hora
        });
        widget.onChanged(file.path); // envia o caminho do ficheiro para o formulário salvar no Firebase
      }
    } catch (e) {
      debugPrint("Erro ao abrir a câmara ou capturar imagem: $e");
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
        const Text(
          "Foto do Alagamento",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _localPhoto == null ? _takePhotoDirectly : null,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: _localPhoto != null
                ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_localPhoto!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _removePhoto,
                    child: const CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 16,
                      child: Icon(Icons.close, color: Colors.white, size: 20),
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
                  Text("Toque para abrir a câmara", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}