import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_alagouai/features/report/services/report_service.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  // Função auxiliar para as cores dos níveis
  Color _getColor(String level) {
    String safeLevel = level.toLowerCase();
    if (safeLevel == 'low') return Colors.yellow.shade800;
    if (safeLevel == 'medium') return Colors.orange;
    return Colors.red;
  }

  // Função auxiliar para traduzir o nível
  String _translateLevel(String level) {
    String safeLevel = level.toLowerCase();
    if (safeLevel == 'low') return "Atenção (Baixo)";
    if (safeLevel == 'medium') return "Risco Médio";
    return "Crítico";
  }

  // Abre um alerta de segurança antes de apagar do banco
  void _confirmDelete(BuildContext context, String reportId, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Excluir reporte"),
        content: const Text(
          "Tem certeza que deseja apagar este reporte? Essa ação removerá o alerta do mapa para todos os usuários.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context); // Fecha o dialog

              // Chama o seu ReportService para deletar do Firestore e do Storage
              await ReportService().deleteReport(reportId, imageUrl);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reporte excluído com sucesso!")),
                );
              }
            },
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Meus Reportes", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🧠 Puxa apenas os reportes do usuário logado
        stream: ReportService().getUserReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Erro ao carregar seus reportes.", style: TextStyle(color: Colors.grey)),
            );
          }

          // 🛑 ESTADO VAZIO: Se não tiver reportes, mostra algo amigável!
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Você ainda não fez nenhum reporte.",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          // 🧠 LÓGICA DE ORDENAÇÃO: Do mais novo pro mais velho
          var sortedDocs = docs.toList();
          sortedDocs.sort((a, b) {
            var dataA = a.data() as Map<String, dynamic>;
            var dataB = b.data() as Map<String, dynamic>;

            Timestamp timeA = dataA['timestamp'] ?? Timestamp.now();
            Timestamp timeB = dataB['timestamp'] ?? Timestamp.now();

            // Compara o B com o A para a ordem ficar decrescente (o último em cima)
            return timeB.compareTo(timeA);
          });

          // 🛑 LISTA DE REPORTES
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDocs.length, // Usa a lista ordenada
            itemBuilder: (context, index) {
              var doc = sortedDocs[index]; // Usa o documento da lista ordenada
              var data = doc.data() as Map<String, dynamic>;

              String level = data['floodLevel'] ?? 'high';
              String street = data['streetName'] ?? 'Rua Desconhecida';
              String? imageUrl = data['imageUrl'];

              // Formatação da data que vem do Firestore
              String dateStr = "";
              if (data['timestamp'] != null) {
                DateTime date = (data['timestamp'] as Timestamp).toDate();
                dateStr = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // 📷 Miniatura da foto
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 80, height: 80, color: Colors.grey.shade100,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                            : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 📝 Textos do Card
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _translateLevel(level),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getColor(level),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              street,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateStr,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // 🗑️ Botão Excluir
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(context, doc.id, imageUrl),
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