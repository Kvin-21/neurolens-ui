import 'package:flutter/material.dart';

/// Screen for viewing and generating patient reports.
class PatientReportsScreen extends StatelessWidget {
  const PatientReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Reports'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Report Generation Coming Soon',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('This will generate detailed patient reports in PDF format.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}