import 'package:flutter/material.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String time;
  final String severity;
  final String location;
  final String? imageUrl;

  const NotificationCard({
    super.key,
    required this.title,
    required this.time,
    required this.severity,
    required this.location,
    this.imageUrl, //é nulo se não houver foto
  });

  String getSeverityText() {
    switch (severity.toLowerCase()) {
      case "high": return "ALTO RISCO";
      case "medium": return "MÉDIO";
      case "low": return "BAIXO";
      default: return "DESCONHECIDO";
    }
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = AppColors.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8)
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //img ou icone de gota
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            // mostra a imagem ou icone de gota
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.water_drop_rounded,
                    color: cardColor,
                    size: 30
                ),
              ),
            )
                : const Icon(
                Icons.water_drop_rounded,
                color: cardColor, //gota azul
                size: 30
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                        time,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                //tag de severidade
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    getSeverityText(),
                    style: const TextStyle(
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
        ],
      ),
    );
  }
}