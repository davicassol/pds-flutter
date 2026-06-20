import 'package:flutter/material.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const SettingsToggle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.darkNavy)
      ),
      subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textGreyBlue, fontWeight: FontWeight.w500)
      ),
      activeColor: AppColors.primaryBlue,
      contentPadding: EdgeInsets.zero,
    );
  }
}