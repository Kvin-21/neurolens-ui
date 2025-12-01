import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Chart widget displaying speech speed trends over time.
class CognitiveChart extends StatelessWidget {
  final List<Map<String, dynamic>> cognitiveHistory;

  const CognitiveChart({super.key, required this.cognitiveHistory});

  @override
  Widget build(BuildContext context) {
    if (cognitiveHistory.isEmpty) return _buildEmptyState();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Speech Speed Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < cognitiveHistory.length) {
                            return Text('Day ${index + 1}', style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _buildSpots(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No chart data available', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    final spots = <FlSpot>[];
    for (int i = 0; i < cognitiveHistory.length; i++) {
      final data = cognitiveHistory[i];
      final speed = data.containsKey('features')
          ? (data['features']['speech_speed'] ?? 0.0).toDouble()
          : (data['speech_speed'] ?? 0.0).toDouble();
      spots.add(FlSpot(i.toDouble(), speed));
    }
    return spots.reversed.toList();
  }
}