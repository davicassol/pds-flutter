import 'package:flutter/material.dart';

class ProfileForm extends StatelessWidget {
  final bool isEditing;
  final String name;
  final String email;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final Function(String) onNameChanged;
  final Function(String) onEmailChanged;

  const ProfileForm({
    super.key,
    required this.isEditing,
    required this.name,
    required this.email,
    required this.onEdit,
    required this.onSave,
    required this.onNameChanged,
    required this.onEmailChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Personal Information"),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              )
            ],
          ),

          TextField(
            enabled: isEditing,
            decoration: const InputDecoration(labelText: "Name"),
            controller: TextEditingController(text: name),
            onChanged: onNameChanged,
          ),

          TextField(
            enabled: isEditing,
            decoration: const InputDecoration(labelText: "Email"),
            controller: TextEditingController(text: email),
            onChanged: onEmailChanged,
          ),

          if (isEditing)
            ElevatedButton(
              onPressed: onSave,
              child: const Text("Save Changes"),
            )
        ],
      ),
    );
  }
}