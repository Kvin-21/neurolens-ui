import 'package:flutter/material.dart';

/// Card displaying detailed cognitive metrics in a grid layout.
class CognitiveMetricsCard extends StatelessWidget {
  final List<Map<String, dynamic>> cognitiveHistory;

  const CognitiveMetricsCard({super.key, required this.cognitiveHistory});

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
                Icon(Icons.analytics_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No cognitive data available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final latestData = cognitiveHistory.first;
    final metrics = _extractMetrics(latestData);

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
                  Icons.analytics,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Latest Cognitive Metrics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildMetricTile(
                  'Speech Speed',
                  metrics['speech_speed'],
                  'wpm',
                  Icons.speed,
                  Colors.blue,
                ),
                _buildMetricTile(
                  'Pauses',
                  metrics['pauses'],
                  'count',
                  Icons.pause,
                  Colors.orange,
                ),
                _buildMetricTile(
                  'Vocab Richness',
                  (metrics['vocab_richness'] * 100),
                  '%',
                  Icons.library_books,
                  Colors.green,
                ),
                _buildMetricTile(
                  'Filler Words',
                  (metrics['filler_word_rate'] * 100),
                  '%',
                  Icons.record_voice_over,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, dynamic value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${value?.toStringAsFixed(1) ?? 'N/A'} $unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _extractMetrics(Map<String, dynamic> data) {
    if (data.containsKey('features')) {
      return data['features'];
    }
    return {
      'speech_speed': data['speech_speed'] ?? 0.0,
      'pauses': data['pauses'] ?? 0,
      'vocab_richness': data['vocab_richness'] ?? 0.0,
      'filler_word_rate': data['filler_word_rate'] ?? 0.0,
    };
  }
}