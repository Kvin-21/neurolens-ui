import 'package:flutter/material.dart';

/// Screen displaying detailed cognitive analysis charts.
class CognitiveChartsScreen extends StatelessWidget {
  final Map<String, dynamic>? cognitiveData;
  
  const CognitiveChartsScreen({super.key, this.cognitiveData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cognitive Charts'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cognitive Data Overview',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (cognitiveData != null && cognitiveData!['cognitive_history'] != null)
                      _buildDataSummary()
                    else
                      const Text('No cognitive data available.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSummary() {
    final history = cognitiveData!['cognitive_history'] as List;
    
    if (history.isEmpty) {
      return const Text('No records found.');
    }

    final latestEntry = history.first;
    final features = latestEntry['features'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total Records: ${history.length}'),
        const SizedBox(height: 12),
        const Text('Latest Metrics:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...features.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key.replaceAll('_', ' ').toUpperCase()),
              Text(entry.value.toStringAsFixed(2)),
            ],
          ),
        )).toList(),
        const SizedBox(height: 16),
        const Text(
          'Charts visualization will be implemented with a charting library.',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}