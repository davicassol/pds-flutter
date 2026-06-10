import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_alagouai/features/report/services/report_service.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});
  Color _getColor(String level) {
    String safeLevel = level.toLowerCase();
    if (safeLevel == 'low') return AppColors.alertLow;
    if (safeLevel == 'medium') return Colors.orangeAccent;
    return AppColors.alertHigh;
  }

  String _translateLevel(String level) {
    String safeLevel = level.toLowerCase();
    if (safeLevel == 'low') return "BAIXO RISCO";
    if (safeLevel == 'medium') return "MÉDIO RISCO";
    return "ALTO RISCO";
  }

  void _confirmDelete(BuildContext context, String reportId, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text("Excluir reporte", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Tem certeza que deseja apagar este reporte? Essa ação removerá o alerta do mapa para todos os usuários.",
          style: TextStyle(color: AppColors.textGreyBlue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ReportService().deleteReport(reportId, imageUrl);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Reporte excluído com sucesso!", style: TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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
      extendBodyBehindAppBar: true, //para o gradiente vazar por trás da AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkNavy), //seta de voltar
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 10, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Meus Reportes",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Gerencie o seu histórico de alertas",
                      style: TextStyle(
                        color: AppColors.textGreyBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              //lista de peportes
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: ReportService().getUserReports(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                    }

                    if (snapshot.hasError) {
                      return _buildEmptyState("Erro ao carregar seus reportes.", Icons.cloud_off_rounded);
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState("Você ainda não fez nenhum reporte.", Icons.history_toggle_off_rounded);
                    }

                    final docs = snapshot.data!.docs;
                    var sortedDocs = docs.toList();
                    sortedDocs.sort((a, b) {
                      var dataA = a.data() as Map<String, dynamic>;
                      var dataB = b.data() as Map<String, dynamic>;
                      Timestamp timeA = dataA['timestamp'] ?? Timestamp.now();
                      Timestamp timeB = dataB['timestamp'] ?? Timestamp.now();
                      return timeB.compareTo(timeA);
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      itemCount: sortedDocs.length,
                      itemBuilder: (context, index) {
                        var doc = sortedDocs[index];
                        var data = doc.data() as Map<String, dynamic>;

                        String level = data['floodLevel'] ?? 'high';
                        String street = data['streetName'] ?? 'Rua Desconhecida';
                        String? imageUrl = data['imageUrl'];
                        String dateStr = "";

                        if (data['timestamp'] != null) {
                          DateTime date = (data['timestamp'] as Timestamp).toDate();
                          dateStr = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                        }

                        const cardColor = AppColors.primaryBlue;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: cardColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              //miniatura da foto ou icone
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.water_drop_rounded,
                                      color: cardColor,
                                      size: 30,
                                    ),
                                  ),
                                )
                                    : const Icon(
                                  Icons.water_drop_rounded,
                                  color: cardColor,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),

                              //textos
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      street,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    //tag de severidade
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _translateLevel(level),
                                        style: TextStyle(
                                          color: cardColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //botão de excluir
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                                  onPressed: () => _confirmDelete(context, doc.id, imageUrl),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:  AppColors.primaryBlue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.primaryBlue.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textGreyBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}