import 'package:flutter/material.dart';

class AppColors {
  //Cores Principais da Identidade Visual
  static const Color primaryBlue = Color(0xFF1E6FD9);     //Azul Royal vibrante
  static const Color darkNavy = Color(0xFF0F2042);        //Azul Marinho Profundo dos títulos
  static const Color textGreyBlue = Color(0xFF6B82A4);    //azul acinzentado dos subtítulos

  //Cores do Fundo Gradiente das Telas
  static const Color gradientStart = Color(0xFFE2EFFF);   //Topo esquerdo do gradiente
  static const Color gradientEnd = Color(0xFFF4F9FF);     //Baixo direita do gradiente

  //Cores dos Níveis de Alagamento
  static const Color alertLow = Color(0xFF00B4D8);        //Ciano (Baixo Risco)
  static const Color alertMedium = Color(0xFFFF9F1C);     //Laranja Vibrante (Médio Risco)
  static const Color alertHigh = Color(0xFFFF006E);       //Rosa/Vermelho Neon (Alto Risco)

  //Nome do app
  static const String appName = "AlagouAí";
}






//ainda não aplicadas
class AppConstants {
  static const double maxNotificationDistance = 5000.0; //Raio de 5km das notificações
  static const double detourToleranceMeters = 80.0;     //Tolerância do radar de rotas
}