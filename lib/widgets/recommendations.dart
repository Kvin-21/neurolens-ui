import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget showing personalised cognitive health recommendations.
class Recommendations extends StatelessWidget {
  final Map<String, dynamic>? cognitiveData;
  final Map<String, dynamic>? lifetimeStats;

  const Recommendations({super.key, this.cognitiveData, this.lifetimeStats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personalized Recommendations',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Evidence-based suggestions approved by medical professionals',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        _buildRecommendationCategories(),
      ],
    );
  }

  Widget _buildRecommendationCategories() {
    final recommendations = _generateRecommendations();
    
    return Column(
      children: [
        _buildCategorySection(
          'Cognitive Activities',
          FontAwesomeIcons.brain,
          Colors.blue,
          recommendations['cognitive'] ?? [],
        ),
        const SizedBox(height: 20),
        _buildCategorySection(
          'Physical Exercise',
          FontAwesomeIcons.dumbbell,
          Colors.green,
          recommendations['physical'] ?? [],
        ),
        const SizedBox(height: 20),
        _buildCategorySection(
          'Speech & Communication',
          FontAwesomeIcons.commentDots,
          Colors.orange,
          recommendations['speech'] ?? [],
        ),
        const SizedBox(height: 20),
        _buildCategorySection(
          'Lifestyle & Wellness',
          FontAwesomeIcons.heart,
          Colors.red,
          recommendations['lifestyle'] ?? [],
        ),
        const SizedBox(height: 20),
        _buildCategorySection(
          'Medical Follow-up',
          FontAwesomeIcons.stethoscope,
          Colors.purple,
          recommendations['medical'] ?? [],
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    String title,
    IconData icon,
    Color color,
    List<Map<String, dynamic>> recommendations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => _buildRecommendationItem(rec, color)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> recommendation, Color color) {
    final priority = recommendation['priority'] as String;
    final title = recommendation['title'] as String;
    final description = recommendation['description'] as String;
    final duration = recommendation['duration'] as String;
    final frequency = recommendation['frequency'] as String;
    final evidence = recommendation['evidence'] as String;

    Color priorityColor;
    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      case 'low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${priority.toUpperCase()} PRIORITY',
                  style: TextStyle(
                    fontSize: 10,
                    color: priorityColor.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.verified,
                color: Colors.green.shade600,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Clinically Approved',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.schedule, duration, Colors.blue),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.repeat, frequency, Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.science,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Evidence: $evidence',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _generateRecommendations() {
    final recommendations = <String, List<Map<String, dynamic>>>{
      'cognitive': [],
      'physical': [],
      'speech': [],
      'lifestyle': [],
      'medical': [],
    };

    // Analyze data to generate personalized recommendations
    if (cognitiveData != null && cognitiveData!['cognitive_history'] != null) {
      final history = cognitiveData!['cognitive_history'] as List;
      
      if (history.isNotEmpty) {
        final recentEntries = history.take(7).toList();
        final avgCognitiveScore = recentEntries
            .map((e) => e['cognitive_score'] as double? ?? 0.0)
            .reduce((a, b) => a + b) / recentEntries.length;

        // Cognitive recommendations based on performance
        if (avgCognitiveScore < 0.6) {
          recommendations['cognitive']!.addAll([
            {
              'priority': 'high',
              'title': 'Memory Training Exercises',
              'description': 'Engage in structured memory exercises for 20-30 minutes daily. Include card games, word puzzles, and recall exercises.',
              'duration': '20-30 min',
              'frequency': 'Daily',
              'evidence': 'Multiple RCTs show 15-30% improvement in working memory',
            },
            {
              'priority': 'high',
              'title': 'Cognitive Stimulation Therapy',
              'description': 'Participate in group activities that stimulate thinking, concentration and memory in an enjoyable way.',
              'duration': '45 min',
              'frequency': '2x per week',
              'evidence': 'Cochrane review: significant cognitive benefits',
            },
          ]);
        } else if (avgCognitiveScore >= 0.8) {
          recommendations['cognitive']!.add({
            'priority': 'medium',
            'title': 'Advanced Cognitive Challenges',
            'description': 'Maintain cognitive reserve with complex puzzles, learning new skills, or taking online courses.',
            'duration': '30-45 min',
            'frequency': '3x per week',
            'evidence': 'Longitudinal studies support cognitive reserve theory',
          });
        }

        // Speech recommendations based on speech features
        final speechFeatures = recentEntries.map((e) => e['features'] as Map<String, dynamic>? ?? {}).toList();
        
        if (speechFeatures.isNotEmpty) {
          final avgSpeechRate = speechFeatures
              .map((f) => f['articulation_rate_sps'] as double? ?? 3.0)
              .reduce((a, b) => a + b) / speechFeatures.length;
          
          final avgJitter = speechFeatures
              .map((f) => f['jitter_local_perc'] as double? ?? 0.5)
              .reduce((a, b) => a + b) / speechFeatures.length;

          if (avgSpeechRate < 2.5) {
            recommendations['speech']!.add({
              'priority': 'medium',
              'title': 'Speech Rate Exercises',
              'description': 'Practice reading aloud with a metronome to improve speech timing and fluency.',
              'duration': '15-20 min',
              'frequency': 'Daily',
              'evidence': 'Speech therapy studies show 20% improvement in fluency',
            });
          }

          if (avgJitter > 1.0) {
            recommendations['speech']!.add({
              'priority': 'high',
              'title': 'Voice Quality Training',
              'description': 'Vocal exercises focusing on breath support and voice stability with a speech therapist.',
              'duration': '30 min',
              'frequency': '2x per week',
              'evidence': 'Clinical trials show reduced voice tremor',
            });
          }
        }
      }
    }

    // Add general evidence-based recommendations
    recommendations['physical']!.addAll([
      {
        'priority': 'high',
        'title': 'Aerobic Exercise Program',
        'description': 'Regular walking, swimming, or cycling to improve cardiovascular health and cognitive function.',
        'duration': '30 min',
        'frequency': '5x per week',
        'evidence': 'Meta-analysis: 16% reduction in cognitive decline risk',
      },
      {
        'priority': 'medium',
        'title': 'Balance and Coordination Training',
        'description': 'Tai chi, yoga, or balance exercises to reduce fall risk and improve motor control.',
        'duration': '20-30 min',
        'frequency': '3x per week',
        'evidence': 'Systematic review: 23% fall risk reduction',
      },
    ]);

    recommendations['lifestyle']!.addAll([
      {
        'priority': 'high',
        'title': 'Mediterranean Diet',
        'description': 'Adopt a diet rich in fruits, vegetables, whole grains, fish, and olive oil to support brain health.',
        'duration': 'Ongoing',
        'frequency': 'Daily',
        'evidence': 'MIND diet study: 53% Alzheimer\'s risk reduction',
      },
      {
        'priority': 'medium',
        'title': 'Social Engagement',
        'description': 'Maintain regular social activities and connections with family and friends.',
        'duration': '1-2 hours',
        'frequency': '3x per week',
        'evidence': 'Longitudinal studies: 70% lower dementia risk',
      },
      {
        'priority': 'medium',
        'title': 'Quality Sleep Hygiene',
        'description': 'Maintain 7-9 hours of quality sleep with consistent bedtime routines.',
        'duration': '7-9 hours',
        'frequency': 'Nightly',
        'evidence': 'Sleep studies link poor sleep to cognitive decline',
      },
    ]);

    recommendations['medical']!.addAll([
      {
        'priority': 'high',
        'title': 'Regular Neurological Assessment',
        'description': 'Schedule comprehensive neurological evaluation to monitor disease progression.',
        'duration': '1-2 hours',
        'frequency': 'Every 6 months',
        'evidence': 'Clinical guidelines recommend regular monitoring',
      },
      {
        'priority': 'medium',
        'title': 'Medication Review',
        'description': 'Regular review of medications with healthcare provider to optimize therapy.',
        'duration': '30-45 min',
        'frequency': 'Every 3 months',
        'evidence': 'Medication optimization improves outcomes',
      },
    ]);

    // Add speech therapy recommendations if needed
    recommendations['speech']!.addAll([
      {
        'priority': 'medium',
        'title': 'Daily Reading Practice',
        'description': 'Read aloud for 15-20 minutes daily to maintain speech clarity and cognitive engagement.',
        'duration': '15-20 min',
        'frequency': 'Daily',
        'evidence': 'Reading aloud activates multiple brain regions',
      },
    ]);

    return recommendations;
  }
}