import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Interactive chart for exploring different cognitive feature metrics.
class FeaturesChart extends StatefulWidget {
  final Map<String, dynamic>? cognitiveData;

  const FeaturesChart({super.key, this.cognitiveData});

  @override
  State<FeaturesChart> createState() => _FeaturesChartState();
}

class _FeaturesChartState extends State<FeaturesChart> {
  String _selectedMetric = 'memory_score';
  int _days = 7;

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
              _buildControls(),
              const SizedBox(height: 12),
              Expanded(
                child: _buildChart(constraints),
              ),
              const SizedBox(height: 12),
              _buildInsights(),
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
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.analytics,
            color: Color(0xFF2196F3),
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Performance Trends',
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

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            'Metric',
            _selectedMetric,
            [
              {'value': 'memory_score', 'label': 'Memory'},
              {'value': 'attention_score', 'label': 'Attention'},
              {'value': 'processing_speed', 'label': 'Processing'},
              {'value': 'overall_performance', 'label': 'Overall'},
            ],
            (value) => setState(() => _selectedMetric = value!),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown(
            'Period',
            _days.toString(),
            [
              {'value': '7', 'label': '7 Days'},
              {'value': '30', 'label': '30 Days'},
              {'value': '90', 'label': '90 Days'},
            ],
            (value) => setState(() => _days = int.parse(value!)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<Map<String, String>> items,
    Function(String?) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2196F3).withOpacity(0.1),
            const Color(0xFF667eea).withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            isExpanded: true,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF2196F3),
              size: 16,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(item['label']!),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BoxConstraints constraints) {
    final chartData = _getChartData();
    
    if (chartData.isEmpty) {
      return _buildNoDataMessage();
    }

    final metricColor = _getMetricColor(_selectedMetric);

    return SizedBox(
      height: constraints.maxHeight - 120,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= chartData.length) return const Text('');
                  
                  // Show every 2nd or 3rd label to avoid overlap
                  final step = chartData.length > 10 ? 3 : 2;
                  if (index % step != 0 && index != chartData.length - 1) {
                    return const Text('');
                  }
                  
                  return Text(
                    chartData[index]['label'] ?? '',
                    style: const TextStyle(fontSize: 8),
                  );
                },
                reservedSize: 20,
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 8),
                  );
                },
                reservedSize: 30,
                interval: 20,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          minX: 0,
          maxX: (chartData.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: chartData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value['value']?.toDouble() ?? 0.0);
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [metricColor, metricColor.withOpacity(0.7)],
              ),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: metricColor,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    metricColor.withOpacity(0.2),
                    metricColor.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMetricColor(String metric) {
    switch (metric) {
      case 'memory_score':
        return const Color(0xFF2196F3); // Blue
      case 'attention_score':
        return const Color(0xFF4CAF50); // Green
      case 'processing_speed':
        return const Color(0xFF9C27B0); // Purple
      case 'overall_performance':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF2196F3);
    }
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete activities to see trends',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    final insights = _getInsights();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getMetricColor(_selectedMetric).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getMetricColor(_selectedMetric).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Insights',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          ...insights.take(2).map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 4,
                  color: _getMetricColor(_selectedMetric),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getChartData() {
    if (widget.cognitiveData == null) {
      return _getDefaultChartData();
    }

    final activities = widget.cognitiveData!['activities'] as List<dynamic>? ?? [];
    if (activities.isEmpty) {
      return _getDefaultChartData();
    }

    final filteredActivities = _filterActivitiesByPeriod(activities, _days);
    final processedData = <Map<String, dynamic>>[];
    
    // Create proper date-based labels
    final now = DateTime.now();
    for (int i = _days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayActivities = filteredActivities.where((activity) {
        try {
          final activityDate = DateTime.parse(activity['timestamp']);
          return activityDate.day == date.day && 
                 activityDate.month == date.month &&
                 activityDate.year == date.year;
        } catch (e) {
          return false;
        }
      }).toList();

      double value = 0;
      if (dayActivities.isNotEmpty) {
        final scores = dayActivities.map((a) => 
          (a['cognitive_metrics'] as Map<String, dynamic>?)?[_selectedMetric] ?? 0
        ).cast<num>();
        value = scores.isNotEmpty ? scores.reduce((a, b) => a + b) / scores.length : 0;
      }

      processedData.add({
        'label': '${date.day}/${date.month}',
        'value': value.toDouble(),
      });
    }

    return processedData;
  }

  List<dynamic> _filterActivitiesByPeriod(List<dynamic> activities, int days) {
    if (days <= 0) return activities;
    
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return activities.where((activity) {
      try {
        final timestamp = activity['timestamp'] as String?;
        if (timestamp == null) return false;
        final activityDate = DateTime.parse(timestamp);
        return activityDate.isAfter(cutoffDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> _getDefaultChartData() {
    final data = <Map<String, dynamic>>[];
    final baseValue = _selectedMetric == 'memory_score' ? 75.0 : 
                     _selectedMetric == 'attention_score' ? 70.0 : 
                     _selectedMetric == 'processing_speed' ? 80.0 : 75.0;

    final now = DateTime.now();
    for (int i = _days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      data.add({
        'label': '${date.day}/${date.month}',
        'value': baseValue + (i * 1.5) + (i % 3 == 0 ? 5 : -2),
      });
    }

    return data;
  }

  List<String> _getInsights() {
    final metricName = _selectedMetric.replaceAll('_', ' ').split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    if (widget.cognitiveData != null) {
      final activities = widget.cognitiveData!['activities'] as List<dynamic>? ?? [];
      final filteredActivities = _filterActivitiesByPeriod(activities, _days);
      
      if (filteredActivities.isNotEmpty) {
        final scores = filteredActivities.map((a) => 
          (a['cognitive_metrics'] as Map<String, dynamic>?)?[_selectedMetric] ?? 0
        ).cast<num>().toList();
        
        final avgScore = scores.isNotEmpty ? scores.reduce((a, b) => a + b) / scores.length : 0;
        final trend = scores.length > 1 && scores.first < scores.last ? 'improving' : 'stable';
        
        return [
          '$metricName average: ${avgScore.toStringAsFixed(1)}%',
          'Trend over $_days days: $trend',
          'Based on ${filteredActivities.length} activities',
        ];
      }
    }

    return [
      '$metricName trending upward consistently',
      'Performance peaks on activity days',
      'Recommend maintaining schedule',
    ];
  }
}