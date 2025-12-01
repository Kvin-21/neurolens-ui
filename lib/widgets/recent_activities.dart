import 'package:flutter/material.dart';

/// List widget showing recent cognitive assessment activities.
class RecentActivities extends StatelessWidget {
  final Map<String, dynamic>? cognitiveData;

  const RecentActivities({super.key, this.cognitiveData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildActivitiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList() {
    if (cognitiveData == null) {
      return _buildDefaultActivities();
    }

    final activities = cognitiveData!['activities'] as List<dynamic>? ?? [];
    if (activities.isEmpty) {
      return _buildDefaultActivities();
    }

    return ListView.separated(
      itemCount: activities.length.clamp(0, 8), // Show max 8 activities
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityTile(activity);
      },
    );
  }

  Widget _buildDefaultActivities() {
    final defaultActivities = [
      {
        'activity_type': 'Memory Training',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'completion_status': 'Completed',
        'cognitive_metrics': {'memory_score': 85, 'attention_score': 78},
        'duration_minutes': 25,
      },
      {
        'activity_type': 'Attention Exercise',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'completion_status': 'Completed',
        'cognitive_metrics': {'memory_score': 82, 'attention_score': 88},
        'duration_minutes': 20,
      },
      {
        'activity_type': 'Problem Solving',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'completion_status': 'Partial',
        'cognitive_metrics': {'memory_score': 75, 'attention_score': 70},
        'duration_minutes': 30,
      },
    ];

    return ListView.separated(
      itemCount: defaultActivities.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return _buildActivityTile(defaultActivities[index]);
      },
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    final activityType = activity['activity_type'] ?? 'Unknown Activity';
    final timestamp = activity['timestamp'] ?? DateTime.now().toIso8601String();
    final completionStatus = activity['completion_status'] ?? 'Unknown';
    final duration = activity['duration_minutes'] ?? 0;
    final metrics = activity['cognitive_metrics'] as Map<String, dynamic>? ?? {};

    // Parse timestamp and format it
    DateTime date;
    try {
      date = DateTime.parse(timestamp);
    } catch (e) {
      date = DateTime.now();
    }

    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getActivityColor(activityType).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getActivityIcon(activityType),
          color: _getActivityColor(activityType),
          size: 20,
        ),
      ),
      title: Text(
        activityType,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(date),
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildStatusChip(completionStatus),
              const SizedBox(width: 8),
              Text(
                '${duration}min',
                style: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildMetricsGrid(metrics),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color colour;
    switch (status.toLowerCase()) {
      case 'completed':
        colour = const Color(0xFF4CAF50);
        break;
      case 'partial':
        colour = const Color(0xFFFF9800);
        break;
      default:
        colour = const Color(0xFF666666);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colour.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: colour,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> metrics) {
    if (metrics.isEmpty) {
      return const Text(
        'No detailed metrics available',
        style: TextStyle(
          color: Color(0xFF999999),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final metricEntries = metrics.entries.toList();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: metricEntries.length,
      itemBuilder: (context, index) {
        final entry = metricEntries[index];
        final value = entry.value;
        
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatMetricName(entry.key),
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value is num ? '${value.toStringAsFixed(0)}%' : value.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'memory training':
      case 'working memory':
        return Icons.psychology;
      case 'attention exercise':
        return Icons.visibility;
      case 'problem solving':
        return Icons.lightbulb;
      case 'language task':
        return Icons.chat;
      case 'visual processing':
        return Icons.remove_red_eye;
      case 'motor skills':
        return Icons.pan_tool;
      default:
        return Icons.assignment;
    }
  }

  Color _getActivityColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'memory training':
      case 'working memory':
        return const Color(0xFF4CAF50);
      case 'attention exercise':
        return const Color(0xFF2196F3);
      case 'problem solving':
        return const Color(0xFFFF9800);
      case 'language task':
        return const Color(0xFF9C27B0);
      case 'visual processing':
        return const Color(0xFF00BCD4);
      case 'motor skills':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF666666);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[date.weekday - 1]} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatMetricName(String name) {
    return name
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}