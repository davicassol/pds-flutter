import 'package:flutter/material.dart';
import '../widgets/stats_cards.dart';
import '../widgets/rainfall_line_chart.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/insights_card.dart';

class RainStatisticsScreen extends StatelessWidget {
  const RainStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _Header(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  StatsCards(),
                  SizedBox(height: 16),
                  RainfallLineChart(),
                  SizedBox(height: 16),
                  MonthlyBarChart(),
                  SizedBox(height: 16),
                  InsightsCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rain Statistics", style: TextStyle(fontSize: 22)),
          SizedBox(height: 4),
          Text(
            "Historical data and analysis",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}