import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget displaying medication tracking and adherence insights.
class MedicationInsights extends StatelessWidget {
  final Map<String, dynamic>? cognitiveData;

  const MedicationInsights({super.key, this.cognitiveData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.pills,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Medication Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsList() {
    final insights = _generateMedicationInsights();
    
    return Column(
      children: insights.map((insight) => _buildInsightItem(insight)).toList(),
    );
  }

  Widget _buildInsightItem(Map<String, dynamic> insight) {
    final type = insight['type'] as String;
    final title = insight['title'] as String;
    final description = insight['description'] as String;
    final confidence = insight['confidence'] as String;
    
    Color iconColor;
    IconData iconData;
    
    switch (type) {
      case 'positive':
        iconColor = Colors.green;
        iconData = Icons.trending_up;
        break;
      case 'warning':
        iconColor = Colors.orange;
        iconData = Icons.warning;
        break;
      case 'critical':
        iconColor = Colors.red;
        iconData = Icons.error;
        break;
      default:
        iconColor = Colors.blue;
        iconData = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: iconColor.shade700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  confidence,
                  style: TextStyle(
                    fontSize: 10,
                    color: iconColor.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateMedicationInsights() {
    if (cognitiveData == null || cognitiveData!['cognitive_history'] == null) {
      return [
        {
          'type': 'info',
          'title': 'No Data Available',
          'description': 'Insufficient data to generate medication insights. More assessment sessions are needed.',
          'confidence': 'N/A',
        }
      ];
    }

    final history = cognitiveData!['cognitive_history'] as List;
    if (history.isEmpty) {
      return [
        {
          'type': 'info',
          'title': 'No Assessment Data',
          'description': 'No cognitive assessments found to analyze medication effects.',
          'confidence': 'N/A',
        }
      ];
    }

    // Analyze recent trends for medication insights
    final insights = <Map<String, dynamic>>[];

    // Speech clarity analysis
    final recentEntries = history.take(7).toList();
    if (recentEntries.length >= 3) {
      final jitterValues = recentEntries.map((e) {
        final features = e['features'] as Map<String, dynamic>? ?? {};
        return features['jitter_local_perc'] as double? ?? 0.0;
      }).toList();
      
      final avgJitter = jitterValues.reduce((a, b) => a + b) / jitterValues.length;
      
      if (avgJitter < 0.5) {
        insights.add({
          'type': 'positive',
          'title': 'Speech Clarity Stable',
          'description': 'Voice quality indicators suggest current medication regimen is maintaining speech clarity effectively.',
          'confidence': 'High',
        });
      } else if (avgJitter > 1.5) {
        insights.add({
          'type': 'warning',
          'title': 'Speech Quality Concern',
          'description': 'Increased voice tremor may indicate medication adjustment needed. Consider consulting with neurologist.',
          'confidence': 'Medium',
        });
      }
    }

    // Cognitive performance trends
    final cognitiveScores = history.take(14).map((e) => e['cognitive_score'] as double? ?? 0.0).toList();
    if (cognitiveScores.length >= 5) {
      final recentAvg = cognitiveScores.take(7).reduce((a, b) => a + b) / 7;
      final olderAvg = cognitiveScores.skip(7).take(7).reduce((a, b) => a + b) / 7;
      
      if (recentAvg > olderAvg + 0.1) {
        insights.add({
          'type': 'positive',
          'title': 'Cognitive Improvement',
          'description': 'Recent cognitive scores show improvement. Current medication appears to be having positive effects.',
          'confidence': 'High',
        });
      } else if (recentAvg < olderAvg - 0.15) {
        insights.add({
          'type': 'critical',
          'title': 'Cognitive Decline Detected',
          'description': 'Declining cognitive performance may indicate need for medication review or dosage adjustment.',
          'confidence': 'High',
        });
      }
    }

    // Speech rate analysis
    if (recentEntries.length >= 3) {
      final speechRates = recentEntries.map((e) {
        final features = e['features'] as Map<String, dynamic>? ?? {};
        return features['articulation_rate_sps'] as double? ?? 0.0;
      }).toList();
      
      final avgRate = speechRates.reduce((a, b) => a + b) / speechRates.length;
      
      if (avgRate < 2.0) {
        insights.add({
          'type': 'warning',
          'title': 'Slow Speech Rate',
          'description': 'Speech rate below normal range may indicate motor symptoms affecting speech production. Consider medication timing optimization.',
          'confidence': 'Medium',
        });
      } else if (avgRate > 6.0) {
        insights.add({
          'type': 'warning',
          'title': 'Rapid Speech Rate',
          'description': 'Unusually fast speech may indicate medication side effects or anxiety. Monitor for other symptoms.',
          'confidence': 'Medium',
        });
      }
    }

    // Add general recommendations if no specific insights
    if (insights.isEmpty) {
      insights.add({
        'type': 'info',
        'title': 'Stable Performance',
        'description': 'Speech and cognitive metrics appear stable. Continue current medication regimen and regular monitoring.',
        'confidence': 'Medium',
      });
    }

    // Add medication adherence reminder
    insights.add({
      'type': 'info',
      'title': 'Medication Adherence',
      'description': 'Consistent medication timing is crucial for optimal cognitive function. Use pill organizers or reminders to maintain schedule.',
      'confidence': 'High',
    });

    return insights;
  }
}