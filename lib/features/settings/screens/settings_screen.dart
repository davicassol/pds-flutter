import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_toggle.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool rainForecast = false;
  // bool autoLocation = true; //variável desativada temporariamente

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notifications = prefs.getBool('notifications') ?? true;
      rainForecast = prefs.getBool('rainForecast') ?? false;
      // autoLocation = prefs.getBool('autoLocation') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Configurações", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.darkNavy)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.darkNavy),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            children: [
              SettingsSection(
                icon: Icons.notifications_active_rounded,
                title: "Notificações",
                subtitle: "Gerencie seus alertas de segurança",
                children: [
                  SettingsToggle(
                    title: "Alertas de Alagamento",
                    subtitle: "Receba avisos de áreas de risco próximas",
                    value: notifications,
                    onChanged: (value) {
                      setState(() => notifications = value);
                      _saveSetting('notifications', value);
                    },
                  ),
                ],
              ),

              /* // TODO: funcionalidade desativada no momento
              //motivo: evitar conflito de estados com a permissão nativa do SO.
              //o controle de localização deve ser gerido apenas pelas configurações do aparelho.
              SettingsSection(
                icon: Icons.location_on_rounded,
                title: "Localização",
                subtitle: "Uso do GPS e precisão do mapa",
                children: [
                  SettingsToggle(
                    title: "Localização Automática",
                    subtitle: "Usar o GPS para focar o mapa em você",
                    value: autoLocation,
                    onChanged: (value) async {
                    },
                  ),
                ],
              ),
              */

              SettingsSection(
                icon: Icons.cloud_rounded,
                title: "Clima e Previsão",
                subtitle: "Preferências de visualização no mapa",
                children: [
                  SettingsToggle(
                    title: "Mostrar Estatísticas de Chuva",
                    subtitle: "Exibir dados meteorológicos de chuva no status",
                    value: rainForecast,
                    onChanged: (value) {
                      setState(() => rainForecast = value);
                      _saveSetting('rainForecast', value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryBlue, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Suas preferências são aplicadas e salvas imediatamente no dispositivo.",
                        style: TextStyle(color: AppColors.textGreyBlue, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}