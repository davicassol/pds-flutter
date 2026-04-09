import 'package:flutter/material.dart';
import '../widgets/risk_gauge.dart';
import '../widgets/risk_bar.dart';
import '../widgets/alert_card.dart';
import '../widgets/weather_factors.dart';
import '../widgets/action_buttons.dart';

class FloodRiskScreen extends StatelessWidget {
  const FloodRiskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const riskLevel = "high"; // mock

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Flood Risk Prediction"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            RiskGauge(riskLevel: riskLevel),
            SizedBox(height: 16),
            RiskBar(),
            SizedBox(height: 16),
            AlertCard(riskLevel: riskLevel),
            SizedBox(height: 16),
            WeatherFactors(),
            SizedBox(height: 16),
            ActionButtons(),
            SizedBox(height: 16),
            Text(
              "Last updated: 2 minutes ago",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}