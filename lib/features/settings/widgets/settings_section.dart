import 'package:flutter/material.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 22),
              const SizedBox(width: 12),
              Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.darkNavy)
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textGreyBlue, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2EFFF)),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}