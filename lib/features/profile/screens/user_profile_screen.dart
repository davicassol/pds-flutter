import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_form.dart';
import '../widgets/profile_stats.dart';
import '../widgets/logout_button.dart';
import '../services/user_service.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

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
        SnackBar(
          content: const Text("Perfil atualizado com sucesso!", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _loadUserData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    isLoading
                        ? const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: AppColors.primaryBlue),
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

                    const SizedBox(height: 20),
                    const ProfileStats(),
                    const SizedBox(height: 28),
                    LogoutButton(onLogout: handleLogout),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}