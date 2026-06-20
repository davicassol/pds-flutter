import 'package:flutter/material.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class ProfileForm extends StatelessWidget {
  final bool isEditing;
  final String email;
  final TextEditingController nameController;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  const ProfileForm({
    super.key,
    required this.isEditing,
    required this.email,
    required this.nameController,
    required this.onEdit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Informações Pessoais",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.darkNavy),
              ),
              IconButton(
                icon: Icon(isEditing ? Icons.close_rounded : Icons.edit_rounded, color: AppColors.primaryBlue),
                onPressed: onEdit,
              )
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            enabled: isEditing,
            controller: nameController,
            style: const TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: "Nome",
              labelStyle: const TextStyle(color: AppColors.textGreyBlue, fontWeight: FontWeight.w500),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            enabled: false,
            controller: TextEditingController(text: email),
            style: const TextStyle(color: AppColors.textGreyBlue, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: "E-mail (Não alterável)",
              labelStyle: const TextStyle(color: AppColors.textGreyBlue),
              filled: true,
              fillColor: Colors.grey.shade50,
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
            ),
          ),
          if (isEditing) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.primaryBlue.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onSave,
                child: const Text("Salvar Alterações", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            )
          ]
        ],
      ),
    );
  }
}