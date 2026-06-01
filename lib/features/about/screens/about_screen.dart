import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Sobre o Projeto", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              AboutHero(),
              SizedBox(height: 24),

              AboutSection(
                title: "Sobre o Aplicativo",
                content:
                "O AlagouAí foi desenvolvido para ajudar moradores e motoristas a navegarem com segurança durante eventos de inundação, combinando monitoramento colaborativo em tempo real com rotas inteligentes.",
              ),

              AboutSection(
                title: "Nosso Propósito",
                content:
                "Fornecer informações precisas e seguras para a população de Torres/RS durante períodos de chuvas intensas, minimizando os riscos de danos materiais e preservando vidas.",
              ),

              SizedBox(height: 16),
              Text(
                "Tecnologias Utilizadas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              TechList(),

              SizedBox(height: 40),
              VersionInfo(),
            ],
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
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // 🛑 CORRIGIDO: O const desceu para cá e a cor agora é Colors.white54
      child: const Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(Icons.water_drop, color: Colors.blue, size: 36),
          ),
          SizedBox(height: 16),
          Text(
            "AlagouAí",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "Mobilidade Segura em Torres",
            style: TextStyle(color: Colors.white54, fontSize: 14),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(color: Colors.black54, fontSize: 15, height: 1.4),
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
        _TechChip("Flutter & Dart", Icons.phone_android),
        _TechChip("Firebase", Icons.cloud_done),
        _TechChip("Google Maps API", Icons.map),
        _TechChip("Radar Octogonal", Icons.psychology),
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
      avatar: Icon(icon, color: Colors.blue[700], size: 18),
      label: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: Colors.blue.shade50,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class VersionInfo extends StatelessWidget {
  const VersionInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.code, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        const Text(
          "Versão 1.0.0 (TCC)",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Desenvolvido com 💙 para a comunidade",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }
}