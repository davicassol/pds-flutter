import 'package:flutter/material.dart';

class AppColors {
  // Cores Principais da Identidade Visual
  static const Color primaryBlue = Color(0xFF1E6FD9);     // Azul Royal
  static const Color primaryDark = Color(0xFF1E3A8A);     // Tom escuro pro degradê da Splash
  static const Color darkNavy = Color(0xFF0F2042);        // Azul Marinho Profundo dos títulos
  static const Color textGreyBlue = Color(0xFF6B82A4);    // Azul acinzentado dos subtítulos

  // Cores do Fundo Gradiente das Telas
  static const Color gradientStart = Color(0xFFE2EFFF);   // Topo esquerdo do gradiente
  static const Color gradientEnd = Color(0xFFF4F9FF);     // Baixo direita do gradiente

  // Cores dos Níveis de Alagamento
  static const Color alertLow = Color(0xFF0EA5E9); // Azul Claro
  static const Color alertMedium = Color(0xFFD97706); // Âmbar
  static const Color alertHigh = Color(0xFFDC2626); // Vermelho Alerta

  // CORES: COMPONENTES E UI
  static const Color actionCancel = Colors.redAccent;     // Botões de cancelar/sair
  static const Color surfaceWhite = Colors.white;         // Fundo de cards claros
  static const Color surfaceDark = Color(0xFF0F1E44);     // Fundo dos cards escuros (Azul Marinho)
  static const Color textWhite = Colors.white;            // Textos em fundos escuros
  static const Color textBlack = Colors.black87;          // Textos principais escuros
  static const Color shadowColor = Colors.black12;        // Sombras suaves
  static const Color transparent = Colors.transparent;

  // Escala de Cinzas (Divisórias, Ícones, Textos Secundários)
  static const Color textGreyLight = Color(0xFFBDBDBD);
  static const Color textGreyMedium = Color(0xFF757575);
  static const Color iconGrey = Colors.grey;
  static const Color dividerGrey = Color(0xFFE0E0E0);
  static const Color surfaceGrey = Color(0xFFF5F5F5);

  // Cores de Status (Cards de Rota)
  static const Color successMain = Colors.green;
  static const Color successBackground = Color(0xFFE8F5E9);
  static const Color successText = Color(0xFF388E3C);

  static const Color warningMain = Colors.orange;
  static const Color warningBackground = Color(0xFFFFF3E0);
  static const Color warningText = Color(0xFFEF6C00);

  //cores feedback
  static const Color buttonFeedbackActive = Color(0xFF3B82F6); // Azul (Ainda está / Água)
  static const Color buttonFeedbackResolved = Color(0xFF10B981); // Verde (Já secou / Caminho Livre)

  // Nome do app
  static const String appName = "FloodWatch";
}

class AppConstants {
  static const double maxNotificationDistance = 5000.0; // Raio de 5km das notificações
  static const double detourToleranceMeters = 80.0;     // Tolerância do radar de rotas
}