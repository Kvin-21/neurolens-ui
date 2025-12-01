import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Bar chart comparing speech metrics (speed, pauses, vocab, filler words).
class SpeechMetricsChart extends StatelessWidget {
  final List<Map<String, dynamic>> cognitiveHistory;

  const SpeechMetricsChart({super.key, required this.cognitiveHistory});

  @override
  Widget build(BuildContext context) {
    if (cognitiveHistory.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No speech metrics data available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Speech Metrics Comparison',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue() * 1.2,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Speech\nSpeed', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                              );
                            case 1:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Pauses', style: TextStyle(fontSize: 10)),
                              );
                            case 2:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Vocab\nRichness', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                              );
                            case 3:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Filler\nWords', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                              );
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  barGroups: _generateBarGroups(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    final averages = _calculateAverages();
    
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: averages['speech_speed']!,
            color: Colors.blue,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: averages['pauses']!,
            color: Colors.orange,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: averages['vocab_richness']! * 100, // Convert to percentage
            color: Colors.green,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: averages['filler_word_rate']! * 100, // Convert to percentage
            color: Colors.red,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Speech Speed (wpm)', Colors.blue),
        _buildLegendItem('Pauses (count)', Colors.orange),
        _buildLegendItem('Vocab Richness (%)', Colors.green),
        _buildLegendItem('Filler Words (%)', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Map<String, double> _calculateAverages() {
    if (cognitiveHistory.isEmpty) {
      return {
        'speech_speed': 0.0,
        'pauses': 0.0,
        'vocab_richness': 0.0,
        'filler_word_rate': 0.0,
      };
    }

    double totalSpeechSpeed = 0;
    double totalPauses = 0;
    double totalVocabRichness = 0;
    double totalFillerRate = 0;

    for (final entry in cognitiveHistory) {
      final features = entry['features'] ?? entry;
      totalSpeechSpeed += (features['speech_speed'] ?? 0.0).toDouble();
      totalPauses += (features['pauses'] ?? 0.0).toDouble();
      totalVocabRichness += (features['vocab_richness'] ?? 0.0).toDouble();
      totalFillerRate += (features['filler_word_rate'] ?? 0.0).toDouble();
    }

    final count = cognitiveHistory.length;
    return {
      'speech_speed': totalSpeechSpeed / count,
      'pauses': totalPauses / count,
      'vocab_richness': totalVocabRichness / count,
      'filler_word_rate': totalFillerRate / count,
    };
  }

  double _getMaxValue() {
    final averages = _calculateAverages();
    final values = [
      averages['speech_speed']!,
      averages['pauses']!,
      averages['vocab_richness']! * 100,
      averages['filler_word_rate']! * 100,
    ];
    return values.reduce((a, b) => a > b ? a : b);
  }
}