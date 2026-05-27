import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  // Função auxiliar para mudar a cor do texto baseada no nível do alagamento
  Color _getLevelColor(String level) {
    switch (level) {
      case 'Flood': return Colors.red;
      case 'Warning': return Colors.orange;
      default: return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Reportes", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ReportService().getUserReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Você ainda não realizou nenhum reporte.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final reportes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final item = reportes[index];
              final data = item.data() as Map<String, dynamic>;
              final String reportId = item.id;
              final String? imageUrl = data['imageUrl'];

              // Converte o timestamp do Firebase para data legível
              String formattedDate = "Data desconhecida";
              if (data['timestamp'] != null) {
                DateTime dateTime = (data['timestamp'] as Timestamp).toDate();
                formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(dateTime);
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Se houver imagem, mostra uma miniatura redonda, se não, mostra um ícone de mapa
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null
                            ? Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover)
                            : Container(
                          color: Colors.blue.withValues(alpha: 0.1),
                          width: 70,
                          height: 70,
                          child: const Icon(Icons.location_on, color: Colors.blue),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['streetName'] ?? "Rua Desconhecida",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Nível: ${data['floodLevel']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getLevelColor(data['floodLevel']),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // Botão de excluir reporte
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          // Exibe um diálogo de confirmação antes de apagar
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Excluir Reporte?"),
                              content: const Text("Esta ação removerá o aviso do mapa e apagará a foto permanentemente."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await ReportService().deleteReport(reportId, imageUrl);
                                  },
                                  child: const Text("Excluir", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}