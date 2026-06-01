import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_form.dart';
import '../widgets/profile_stats.dart';
import '../widgets/logout_button.dart';

// ⚠️ ATENÇÃO: Ajuste este caminho se o seu user_service.dart estiver em outra pasta!
import '../services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isEditing = false;
  bool isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  String email = "";
  String? photoUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.displayName ?? "";
        email = user.email ?? "Sem e-mail cadastrado";
        photoUrl = user.photoURL;
      });
    }
  }

  Future<void> handleSave() async {
    setState(() => isLoading = true);

    String? erro = await UserService().updateUserProfile(
      name: _nameController.text.trim(),
      imageFile: _selectedImage,
    );

    if (!mounted) return;
    setState(() {
      isLoading = false;
      isEditing = false;
    });

    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil atualizado com sucesso!"), backgroundColor: Colors.green),
      );
      _loadUserData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao sair da conta."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              name: _nameController.text,
              email: email,
              photoUrl: photoUrl,
              localImage: _selectedImage,
              onImagePicked: (File image) {
                setState(() {
                  _selectedImage = image;
                  isEditing = true;
                });
              },
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  isLoading
                      ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  )
                      : ProfileForm(
                    isEditing: isEditing,
                    email: email,
                    nameController: _nameController,
                    onEdit: () {
                      setState(() {
                        isEditing = !isEditing;
                        if (!isEditing) _selectedImage = null;
                      });
                    },
                    onSave: handleSave,
                  ),

                  const SizedBox(height: 24),
                  const ProfileStats(),
                  const SizedBox(height: 32),
                  LogoutButton(onLogout: handleLogout),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}