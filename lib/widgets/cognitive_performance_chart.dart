import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Pie chart displaying performance distribution across categories.
class CognitivePerformanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> cognitiveHistory;

  const CognitivePerformanceChart({super.key, required this.cognitiveHistory});

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
                Icon(Icons.pie_chart, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Performance Distribution',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _generatePieSections(),
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceIndicators(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections() {
    final averages = _calculateAverages();
    
    // Normalize values to create meaningful pie chart sections
    final speechSpeedScore = (averages['speech_speed']! / 150 * 100).clamp(0, 100).toDouble(); // Assuming 150 wpm is excellent
    final pauseScore = (100 - (averages['pauses']! / 30 * 100)).clamp(0, 100).toDouble(); // Fewer pauses is better, max 30
    final vocabScore = (averages['vocab_richness']! * 100).toDouble();
    final fillerScore = (100 - (averages['filler_word_rate']! * 100 * 10)).clamp(0, 100).toDouble(); // Fewer fillers is better

    return [
      PieChartSectionData(
        value: speechSpeedScore,
        color: Colors.blue,
        title: '${speechSpeedScore.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: pauseScore,
        color: Colors.orange,
        title: '${pauseScore.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: vocabScore,
        color: Colors.green,
        title: '${vocabScore.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: fillerScore,
        color: Colors.red,
        title: '${fillerScore.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildPerformanceIndicators() {
    return Column(
      children: [
        Row(
          children: [
            _buildIndicator('Speech Fluency', Colors.blue),
            const SizedBox(width: 20),
            _buildIndicator('Pause Control', Colors.orange),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildIndicator('Vocabulary', Colors.green),
            const SizedBox(width: 20),
            _buildIndicator('Clarity', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildIndicator(String label, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
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
              Icon(Icons.pie_chart, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No performance data available', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, double> _calculateAverages() {
    if (cognitiveHistory.isEmpty) {
      return {'speech_speed': 0, 'pauses': 0, 'vocab_richness': 0, 'filler_word_rate': 0};
    }

    double totalSpeed = 0, totalPauses = 0, totalVocab = 0, totalFiller = 0;

    for (final entry in cognitiveHistory) {
      final f = entry['features'] ?? entry;
      totalSpeed += (f['speech_speed'] ?? 0).toDouble();
      totalPauses += (f['pauses'] ?? 0).toDouble();
      totalVocab += (f['vocab_richness'] ?? 0).toDouble();
      totalFiller += (f['filler_word_rate'] ?? 0).toDouble();
    }

    final n = cognitiveHistory.length;
    return {
      'speech_speed': totalSpeed / n,
      'pauses': totalPauses / n,
      'vocab_richness': totalVocab / n,
      'filler_word_rate': totalFiller / n,
    };
  }
}