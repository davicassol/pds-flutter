import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';
import '../../report/screens/my_reports_screen.dart';
import '../../report/services/report_service.dart';
import 'package:tcc_alagouai/features/route_history/screens/route_history_screen.dart';
import 'package:tcc_alagouai/features/route_history/services/route_history_service.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //reportes
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: ReportService().getUserReports(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _Item(value: "-", label: "Reportes", icon: Icons.waves_rounded, onTap: () {});
              }
              if (snapshot.hasError) {
                return _Item(value: "!", label: "Reportes", icon: Icons.waves_rounded, onTap: () {});
              }
              String reportCount = "0";
              if (snapshot.hasData) {
                reportCount = snapshot.data!.docs.length.toString();
              }

              return _Item(
                value: reportCount,
                label: "Reportes",
                icon: Icons.waves_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyReportsScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(width: 16),

        //histórico de rotas
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: RouteHistoryService().getUserRouteHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _Item(
                  value: "-",
                  label: "Rotas",
                  icon: Icons.alt_route_rounded,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RouteHistoryScreen()));
                  },
                );
              }

              if (snapshot.hasError) {
                return _Item(
                  value: "!",
                  label: "Rotas",
                  icon: Icons.alt_route_rounded,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RouteHistoryScreen()));
                  },
                );
              }

              String routeCount = "0";
              if (snapshot.hasData) {
                routeCount = snapshot.data!.length.toString();
              }

              return _Item(
                value: routeCount,
                label: "Rotas",
                icon: Icons.alt_route_rounded,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RouteHistoryScreen()));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _Item({
    required this.value,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 24),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGreyBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}