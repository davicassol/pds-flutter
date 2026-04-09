import 'package:flutter/material.dart';
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

  String name = "João Silva";
  String email = "joao@email.com";

  void handleSave() {
    setState(() => isEditing = false);
  }

  void handleLogout() {
    Navigator.pushReplacementNamed(context, "/login");
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