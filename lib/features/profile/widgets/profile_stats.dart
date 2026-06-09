import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../report/screens/my_reports_screen.dart';
import '../../report/services/report_service.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          //streambuilder fica escutando o banco
          child: StreamBuilder<QuerySnapshot>(
            stream: ReportService().getUserReports(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _Item(value: "-", label: "Reports", onTap: () {});
              }
              if (snapshot.hasError) {
                print("ERRO DO FIRESTORE: ${snapshot.error}");
                return _Item(value: "Erro", label: "Reports", onTap: () {});
              }
              String reportCount = "0";
              if (snapshot.hasData) {
                reportCount = snapshot.data!.docs.length.toString();
              }

              return _Item(
                value: reportCount,
                label: "Reports",
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

        const SizedBox(width: 10),

        Expanded(
          child: _Item(
            value: "0",
            label: "Routes",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("O histórico de rotas estará disponível em breve!"),
                ),
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
  final VoidCallback? onTap;

  const _Item({
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, 
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}