import 'package:flutter/material.dart';

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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Informações Pessoais", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              )
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            enabled: isEditing,
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Nome",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          //email apenas visualização
          TextField(
            enabled: false,
            controller: TextEditingController(text: email),
            decoration: InputDecoration(
              labelText: "E-mail (Não alterável)",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          if (isEditing) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onSave,
                child: const Text("Salvar Alterações", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ]
        ],
      ),
    );
  }
}