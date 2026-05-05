import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_form.dart';
import '../widgets/profile_stats.dart';
import '../widgets/logout_button.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isEditing = false;

  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        name = user.displayName ?? "Usuário";
        email = user.email ?? "Sem e-mail cadastrado";
      });
    }
  }

  void handleSave() {
    setState(() => isEditing = false);
  }

  Future<void> handleLogout() async {
    try {
      // Desconecta o usuário no servidor do Firebase
      await FirebaseAuth.instance.signOut();

      // Verifica se a tela ainda existe antes de tentar navegar
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/login",
              (route) => false,
        );
      }
    } catch (e) {
      // Se der erro avisa o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao sair da conta. Verifique sua conexão e tente novamente."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(name: name, email: email),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ProfileForm(
                    isEditing: isEditing,
                    name: name,
                    email: email,
                    onEdit: () => setState(() => isEditing = !isEditing),
                    onSave: handleSave,
                    onNameChanged: (v) => name = v,
                    onEmailChanged: (v) => email = v,
                  ),

                  const SizedBox(height: 16),

                  const ProfileStats(),

                  const SizedBox(height: 16),

                  LogoutButton(onLogout: handleLogout),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}