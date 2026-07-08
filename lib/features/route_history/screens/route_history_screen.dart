import 'package:flutter/material.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';
import '../services/route_history_service.dart';
import '../widgets/route_history_card.dart';

class RouteHistoryScreen extends StatelessWidget {
  const RouteHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RouteHistoryService service = RouteHistoryService();

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        title: const Text(
          "Histórico de Rotas",
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.darkNavy),
        ),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkNavy),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.getUserRouteHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Erro ao carregar histórico.", style: TextStyle(color: AppColors.alertHigh)),
            );
          }

          final routesData = snapshot.data;

          if (routesData == null || routesData.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: routesData.length,
            itemBuilder: (context, index) {
              //passa o Map inteiro para o card desenhar
              return RouteHistoryCard(routeData: routesData[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.route_rounded, size: 64, color: AppColors.primaryBlue.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            const Text(
              "Nenhuma rota encontrada",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
            ),
            const SizedBox(height: 8),
            const Text(
              "Suas rotas de navegação salvas aparecerão aqui para você consultar depois.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGreyBlue, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}