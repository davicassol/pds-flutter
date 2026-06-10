import 'package:flutter/material.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Sobre o Projeto", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.darkNavy)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkNavy),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AboutHero(),
                  const SizedBox(height: 24),

                  const AboutSection(
                    title: "Sobre o Aplicativo",
                    content:
                    "O AlagouAí foi desenvolvido para ajudar moradores e motoristas a navegarem com segurança durante eventos de inundação, combinando monitoramento colaborativo em tempo real com rotas inteligentes.",
                  ),

                  const AboutSection(
                    title: "Nosso Propósito",
                    content:
                    "Fornecer informações precisas e seguras para a população de Torres/RS durante períodos de chuvas intensas, minimizando os riscos de danos materiais e preservando vidas.",
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Tecnologias Utilizadas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkNavy),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  const TechList(),

                  const SizedBox(height: 40),
                  const VersionInfo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AboutHero extends StatelessWidget {
  const AboutHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF4DB5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(Icons.water_drop_rounded, color: AppColors.primaryBlue, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            AppColors.appName,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            "Mobilidade Segura em Torres",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  final String title;
  final String content;

  const AboutSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.darkNavy),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(color: AppColors.textGreyBlue, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class TechList extends StatelessWidget {
  const TechList({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: const [
        _TechChip("Flutter & Dart", Icons.phone_android_rounded),
        _TechChip("Firebase", Icons.cloud_done_rounded),
        _TechChip("Google Maps API", Icons.map_rounded),
        _TechChip("Open Meteo API", Icons.thunderstorm_rounded),
      ],
    );
  }
}

class _TechChip extends StatelessWidget {
  final String title;
  final IconData icon;

  const _TechChip(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: AppColors.primaryBlue, size: 18),
      label: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkNavy, fontSize: 13)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE2EFFF), width: 1.5), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}

class VersionInfo extends StatelessWidget {
  const VersionInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.code_rounded, color: AppColors.textGreyBlue),
        const SizedBox(height: 8),
        const Text(
          "Versão 1.0.0",
          style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          "Desenvolvido com 💙 para a comunidade",
          style: const TextStyle(color: AppColors.textGreyBlue, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}