import 'package:flutter/material.dart';

/// Grid of summary cards showing key cognitive metrics.
class OverviewCards extends StatelessWidget {
  final Map<String, dynamic>? cognitiveData;

  const OverviewCards({super.key, this.cognitiveData});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isMobile 
            ? constraints.maxWidth 
            : (constraints.maxWidth - 32) / 2; // Account for spacing
            
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildOverviewCard(
              'Memory Score',
              _getMemoryScore(),
              _getMemoryTrend(),
              Icons.psychology,
              const Color(0xFF4CAF50),
              cardWidth,
            ),
            _buildOverviewCard(
              'Attention Level',
              _getAttentionLevel(),
              _getAttentionTrend(),
              Icons.visibility,
              const Color(0xFF2196F3),
              cardWidth,
            ),
            _buildOverviewCard(
              'Processing Speed',
              _getProcessingSpeed(),
              _getProcessingTrend(),
              Icons.speed,
              const Color(0xFF9C27B0),
              cardWidth,
            ),
            _buildOverviewCard(
              'Daily Activities',
              _getDailyActivities(),
              _getActivitiesTrend(),
              Icons.checklist,
              const Color(0xFFFF9800),
              cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    String trend,
    IconData icon,
    Color color,
    double width,
  ) {
    return Container(
      width: width,
      height: 140, // Fixed height to prevent overflow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
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
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                _buildTrendIndicator(trend),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(String trend) {
    final isPositive = trend.contains('↑') || trend.toLowerCase().contains('improving');
    final isStable = trend.toLowerCase().contains('stable');
    
    Color trendColor;
    IconData trendIcon;
    
    if (isPositive) {
      trendColor = const Color(0xFF4CAF50);
      trendIcon = Icons.trending_up;
    } else if (isStable) {
      trendColor = const Color(0xFF2196F3);
      trendIcon = Icons.trending_flat;
    } else {
      trendColor = const Color(0xFFFF9800);
      trendIcon = Icons.trending_down;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trendIcon, size: 14, color: trendColor),
          const SizedBox(width: 4),
          Text(
            trend,
            style: TextStyle(
              fontSize: 12,
              color: trendColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getMemoryScore() {
    if (cognitiveData == null) return '85%';
    final activities = cognitiveData!['activities'] as List<dynamic>? ?? [];
    if (activities.isEmpty) return '85%';
    
    double totalMemory = 0;
    int memoryCount = 0;
    
    for (var activity in activities) {
      if (activity['cognitive_metrics'] != null) {
        final memory = activity['cognitive_metrics']['memory_score'];
        if (memory != null) {
          totalMemory += memory.toDouble();
          memoryCount++;
        }
      }
    }
    
    if (memoryCount == 0) return '85%';
    final avgMemory = (totalMemory / memoryCount);
    return '${avgMemory.toStringAsFixed(0)}%';
  }

  String _getMemoryTrend() {
    if (cognitiveData == null) return 'Stable';
    return 'Improving ↑';
  }

  String _getAttentionLevel() {
    if (cognitiveData == null) return '78%';
    final activities = cognitiveData!['activities'] as List<dynamic>? ?? [];
    if (activities.isEmpty) return '78%';
    
    double totalAttention = 0;
    int attentionCount = 0;
    
    for (var activity in activities) {
      if (activity['cognitive_metrics'] != null) {
        final attention = activity['cognitive_metrics']['attention_score'];
        if (attention != null) {
          totalAttention += attention.toDouble();
          attentionCount++;
        }
      }
    }
    
    if (attentionCount == 0) return '78%';
    final avgAttention = (totalAttention / attentionCount);
    return '${avgAttention.toStringAsFixed(0)}%';
  }

  String _getAttentionTrend() {
    return 'Stable';
  }

  String _getProcessingSpeed() {
    if (cognitiveData == null) return '92%';
    final activities = cognitiveData!['activities'] as List<dynamic>? ?? [];
    if (activities.isEmpty) return '92%';
    
    double totalProcessing = 0;
    int processingCount = 0;
    
    for (var activity in activities) {
      if (activity['cognitive_metrics'] != null) {
        final processing = activity['cognitive_metrics']['processing_speed'];
        if (processing != null) {
          totalProcessing += processing.toDouble();
          processingCount++;
        }
      }
    }
    
    if (processingCount == 0) return '92%';
    final avgProcessing = (totalProcessing / processingCount);
    return '${avgProcessing.toStringAsFixed(0)}%';
  }

  String _getProcessingTrend() {
    return 'Improving ↑';
  }

  String _getDailyActivities() {
    if (cognitiveData == null) return '12/15';
    final activities = cognitiveData!['activities'] as List<dynamic>? ?? [];
    final completed = activities.length;
    return '$completed/15';
  }

  String _getActivitiesTrend() {
    return 'Stable';
  }
}