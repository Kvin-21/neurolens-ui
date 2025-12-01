import 'package:flutter/material.dart';

/// Summary statistics cards showing key cognitive metrics at a glance.
class OverviewStats extends StatelessWidget {
  final List<Map<String, dynamic>> cognitiveHistory;

  const OverviewStats({super.key, required this.cognitiveHistory});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    if (cognitiveHistory.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No data available',
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

    final stats = _calculateStats();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 4,
              childAspectRatio: isMobile ? 1.5 : 1.2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Avg Speech Speed',
                  '${stats['avgSpeechSpeed'].toStringAsFixed(1)} wpm',
                  Icons.speed,
                  Colors.blue,
                  stats['speechSpeedTrend'],
                ),
                _buildStatCard(
                  'Avg Pauses',
                  '${stats['avgPauses'].toStringAsFixed(1)}',
                  Icons.pause,
                  Colors.orange,
                  stats['pausesTrend'],
                ),
                _buildStatCard(
                  'Vocab Richness',
                  '${(stats['avgVocabRichness'] * 100).toStringAsFixed(1)}%',
                  Icons.library_books,
                  Colors.green,
                  stats['vocabTrend'],
                ),
                _buildStatCard(
                  'Filler Words',
                  '${(stats['avgFillerRate'] * 100).toStringAsFixed(1)}%',
                  Icons.record_voice_over,
                  Colors.red,
                  stats['fillerTrend'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String trend) {
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
              Icon(icon, color: color, size: 24),
              _buildTrendIcon(trend, color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
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
    );
  }

  Widget _buildTrendIcon(String trend, Color color) {
    if (trend == 'up') {
      return Icon(Icons.trending_up, color: Colors.green, size: 20);
    } else if (trend == 'down') {
      return Icon(Icons.trending_down, color: Colors.red, size: 20);
    } else {
      return Icon(Icons.trending_flat, color: Colors.grey, size: 20);
    }
  }

  Map<String, dynamic> _calculateStats() {
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
    
    // Calculate trends (simplified)
    String speechSpeedTrend = 'stable';
    String pausesTrend = 'stable';
    String vocabTrend = 'stable';
    String fillerTrend = 'stable';

    if (cognitiveHistory.length >= 2) {
      final recent = cognitiveHistory.take(5).toList();
      final older = cognitiveHistory.skip(5).take(5).toList();
      
      if (recent.isNotEmpty && older.isNotEmpty) {
        final recentAvgSpeed = recent.map((e) => (e['features']?['speech_speed'] ?? e['speech_speed'] ?? 0.0).toDouble()).reduce((a, b) => a + b) / recent.length;
        final olderAvgSpeed = older.map((e) => (e['features']?['speech_speed'] ?? e['speech_speed'] ?? 0.0).toDouble()).reduce((a, b) => a + b) / older.length;
        
        if (recentAvgSpeed > olderAvgSpeed * 1.05) speechSpeedTrend = 'up';
        else if (recentAvgSpeed < olderAvgSpeed * 0.95) speechSpeedTrend = 'down';
      }
    }

    return {
      'avgSpeechSpeed': totalSpeechSpeed / count,
      'avgPauses': totalPauses / count,
      'avgVocabRichness': totalVocabRichness / count,
      'avgFillerRate': totalFillerRate / count,
      'speechSpeedTrend': speechSpeedTrend,
      'pausesTrend': pausesTrend,
      'vocabTrend': vocabTrend,
      'fillerTrend': fillerTrend,
    };
  }
}