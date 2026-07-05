import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    //pega o usuário atual logado
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? "Usuário";
    final String displayEmail = user?.email ?? "email@naologado.com";
    final String? photoUrl = user?.photoURL; // URL da foto do Firebase

    return Drawer(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      child: Container(
        margin: const EdgeInsets.only(top: 30, bottom: 30, right: 80),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 20,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //foto de perfil
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceWhite,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.surfaceWhite,
                        //se houver URL no Firebase exibe a imagem ,caso contrário mostra o ícone de pessoa padrão
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? const Icon(Icons.person, size: 36, color: AppColors.primaryBlue)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    //nome do usuário
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    //email do usuário
                    Text(
                      displayEmail,
                      style: TextStyle(
                        color: AppColors.textWhite.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Divider(color: AppColors.textWhite.withOpacity(0.2), thickness: 1),
              ),
              const SizedBox(height: 16),
              _buildMenuItem(context, Icons.person_outline, "Meu Perfil", '/profile'),
              _buildMenuItem(context, Icons.settings_outlined, "Configurações", '/settings'),
              _buildMenuItem(context, Icons.info_outline, "Sobre o App", '/about'),

              const Spacer(),

              //botão de logout
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.textWhite, size: 26),
                title: const Text(
                  "Sair",
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                splashColor: AppColors.textWhite.withOpacity(0.1),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textWhite, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: () {
        Navigator.pop(context);
        if (routeName.isNotEmpty) {
          Navigator.pushNamed(context, routeName);
        }
      },
      splashColor: AppColors.textWhite.withOpacity(0.1),
      hoverColor: AppColors.transparent,
    );
  }
}