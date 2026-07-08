import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class RouteHistoryCard extends StatelessWidget {
  final Map<String, dynamic> routeData;

  const RouteHistoryCard({super.key, required this.routeData});

  @override
  Widget build(BuildContext context) {
    //extrai dados do map direto do fb
    final Timestamp? timestamp = routeData['data_criacao'];
    final DateTime dataCriacao = timestamp != null ? timestamp.toDate() : DateTime.now();
    final String formattedDate = DateFormat('dd/MM/yyyy • HH:mm').format(dataCriacao);

    final String enderecoInicio = routeData['endereco_inicio'] ?? 'Local desconhecido';
    final String enderecoFim = routeData['endereco_fim'] ?? 'Local desconhecido';
    final bool cruzouAlagamento = routeData['cruzou_alagamento'] ?? false;
    final String nivelSeveridade = routeData['nivel_severidade'] ?? 'nenhum';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 12, color: AppColors.textGreyBlue, fontWeight: FontWeight.bold),
              ),
              _buildSafetyTag(cruzouAlagamento, nivelSeveridade),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.dividerGrey, height: 1),
          ),
          _buildLocationRow(Icons.my_location_rounded, AppColors.primaryBlue, "Origem", enderecoInicio),
          const SizedBox(height: 12),
          _buildLocationRow(Icons.location_on_rounded, AppColors.alertHigh, "Destino", enderecoFim),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGreyBlue, fontWeight: FontWeight.bold)),
              Text(
                address,
                style: const TextStyle(fontSize: 14, color: AppColors.darkNavy, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyTag(bool cruzouAlagamento, String nivelSeveridade) {
    if (!cruzouAlagamento) {
      return _tagLayout(Icons.check_circle_rounded, "100% Segura", Colors.green);
    }

    Color tagColor;
    String tagText;

    switch (nivelSeveridade.toLowerCase()) {
      case 'alto':
        tagColor = AppColors.alertHigh;
        tagText = "Risco Alto";
        break;
      case 'medio':
        tagColor = Colors.orange;
        tagText = "Risco Médio";
        break;
      default:
        tagColor = Colors.amber;
        tagText = "Risco Baixo";
    }

    return _tagLayout(Icons.warning_rounded, tagText, tagColor);
  }

  Widget _tagLayout(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}