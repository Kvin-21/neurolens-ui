import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Line chart displaying cognitive score trends over time.
class CognitiveTrendsChart extends StatelessWidget {
  final List<Map<String, dynamic>> cognitiveHistory;

  const CognitiveTrendsChart({super.key, required this.cognitiveHistory});

  @override
  Widget build(BuildContext context) {
    if (cognitiveHistory.isEmpty) return _buildEmptyState();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Speech Speed Trends',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < cognitiveHistory.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Day ${index + 1}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateSpeechSpeedSpots(),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
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

  List<FlSpot> _generateSpeechSpeedSpots() {
    final spots = <FlSpot>[];
    for (int i = 0; i < cognitiveHistory.length; i++) {
      final data = cognitiveHistory[cognitiveHistory.length - 1 - i]; // Reverse order for chronological display
      double speechSpeed = 0.0;
      
      if (data.containsKey('features')) {
        speechSpeed = (data['features']['speech_speed'] ?? 0.0).toDouble();
      } else {
        speechSpeed = (data['speech_speed'] ?? 0.0).toDouble();
      }
      
      spots.add(FlSpot(i.toDouble(), speechSpeed));
    }
    return spots;
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.show_chart, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No trend data available', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}