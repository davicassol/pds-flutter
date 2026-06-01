import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool autoLocation = true;
  bool rainForecast = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Carrega as configurações salvas no celular
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Se não existir nada salvo, o padrão é o que está depois do '??'
      notifications = prefs.getBool('notifications') ?? true;
      autoLocation = prefs.getBool('autoLocation') ?? true;
      rainForecast = prefs.getBool('rainForecast') ?? false;
    });
  }

  //Salva a configuração no momento do clique
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Configurações", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SettingsSection(
              icon: Icons.notifications,
              title: "Notificações",
              subtitle: "Gerencie seus alertas de segurança",
              children: [
                SettingsToggle(
                  title: "Alertas de Alagamento",
                  subtitle: "Receba avisos de áreas de risco próximas",
                  value: notifications,
                  onChanged: (value) {
                    setState(() => notifications = value);
                    _saveSetting('notifications', value); // Salva no celular
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            SettingsSection(
              icon: Icons.location_on,
              title: "Localização",
              subtitle: "Uso do GPS e precisão do mapa",
              children: [
                SettingsToggle(
                  title: "Localização Automática",
                  subtitle: "Usar o GPS para focar o mapa em você",
                  value: autoLocation,
                  onChanged: (value) {
                    setState(() => autoLocation = value);
                    _saveSetting('autoLocation', value); // Salva no celular
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            SettingsSection(
              icon: Icons.cloud,
              title: "Clima e Previsão",
              subtitle: "Preferências de visualização no mapa",
              children: [
                SettingsToggle(
                  title: "Mostrar Previsão de Chuva",
                  subtitle: "Exibir alertas meteorológicos no mapa",
                  value: rainForecast,
                  onChanged: (value) {
                    setState(() => rainForecast = value);
                    _saveSetting('rainForecast', value); // Salva no celular
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Suas preferências são salvas automaticamente no dispositivo.",
                      style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const SettingsToggle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      activeColor: Colors.blue,
      contentPadding: EdgeInsets.zero,
    );
  }
}