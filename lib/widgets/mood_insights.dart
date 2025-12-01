import 'package:flutter/material.dart';

/// Widget showing mood analysis and emotional wellbeing insights.
class MoodInsights extends StatelessWidget {
  final Map<String, dynamic>? cognitiveData;

  const MoodInsights({super.key, this.cognitiveData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF8F9FA),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              Expanded(
                child: _buildInsightContent(constraints),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.psychology,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Mood & Engagement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightContent(BoxConstraints constraints) {
    if (cognitiveData == null) {
      return _buildDefaultInsights();
    }

    final activities = cognitiveData!['activities'] as List<dynamic>? ?? [];
    if (activities.isEmpty) {
      return _buildDefaultInsights();
    }

    return _buildDataBasedInsights(activities, constraints);
  }

  Widget _buildDefaultInsights() {
    return Column(
      children: [
        Expanded(
          child: _buildInsightRow(
            icon: Icons.sentiment_very_satisfied,
            color: const Color(0xFF4CAF50),
            title: 'Overall Mood',
            value: 'Positive',
            subtitle: 'Good engagement',
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildInsightRow(
            icon: Icons.trending_up,
            color: const Color(0xFF2196F3),
            title: 'Engagement',
            value: 'High',
            subtitle: 'Consistent participation',
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildInsightRow(
            icon: Icons.psychology,
            color: const Color(0xFF9C27B0),
            title: 'Response',
            value: 'Improving',
            subtitle: 'Positive trends',
          ),
        ),
      ],
    );
  }

  Widget _buildDataBasedInsights(List<dynamic> activities, BoxConstraints constraints) {
    // Calculate mood average
    double totalMood = 0;
    int moodCount = 0;
    Map<String, int> engagementCounts = {'High': 0, 'Medium': 0, 'Low': 0};

    for (var activity in activities.take(10)) {
      if (activity['mood_rating'] != null) {
        totalMood += activity['mood_rating'].toDouble();
        moodCount++;
      }
      
      final engagement = activity['engagement_level'] ?? 'Medium';
      engagementCounts[engagement] = (engagementCounts[engagement] ?? 0) + 1;
    }

    final avgMood = moodCount > 0 ? totalMood / moodCount : 6.0;
    final dominantEngagement = engagementCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return Column(
      children: [
        Expanded(
          child: _buildInsightRow(
            icon: _getMoodIcon(avgMood),
            color: _getMoodColor(avgMood),
            title: 'Avg Mood',
            value: '${avgMood.toStringAsFixed(1)}/10',
            subtitle: _getMoodDescription(avgMood),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildInsightRow(
            icon: Icons.trending_up,
            color: _getEngagementColor(dominantEngagement),
            title: 'Engagement',
            value: dominantEngagement,
            subtitle: 'Most common level',
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildInsightRow(
            icon: Icons.analytics,
            color: const Color(0xFF9C27B0),
            title: 'Activities',
            value: '${activities.length}',
            subtitle: 'Recent completed',
          ),
        ),
      ],
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF999999),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMoodIcon(double mood) {
    if (mood >= 8) return Icons.sentiment_very_satisfied;
    if (mood >= 6) return Icons.sentiment_satisfied;
    if (mood >= 4) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  Color _getMoodColor(double mood) {
    if (mood >= 8) return const Color(0xFF4CAF50);
    if (mood >= 6) return const Color(0xFF2196F3);
    if (mood >= 4) return const Color(0xFFFF9800);
    return const Color(0xFFE53E3E);
  }

  String _getMoodDescription(double mood) {
    if (mood >= 8) return 'Excellent mood';
    if (mood >= 6) return 'Good mood';
    if (mood >= 4) return 'Neutral mood';
    return 'Needs attention';
  }

  Color _getEngagementColor(String engagement) {
    switch (engagement) {
      case 'High':
        return const Color(0xFF4CAF50);
      case 'Medium':
        return const Color(0xFF2196F3);
      case 'Low':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF666666);
    }
  }
}