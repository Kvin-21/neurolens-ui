import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cognitive_data_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/cognitive_metrics_card.dart';
import '../widgets/cognitive_chart.dart';

/// Caregiver dashboard showing patient cognitive data overview.
class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  int _selectedPeriod = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.patientId != null) {
        context.read<CognitiveDataProvider>().fetchCognitiveHistory(auth.patientId!, _selectedPeriod);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final cognitiveData = context.watch<CognitiveDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('NeuroLens - Patient ${auth.patientId ?? "Unknown"}'),
        actions: [
          IconButton(
            onPressed: themeProvider.toggleTheme,
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          IconButton(
            onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (auth.patientId != null) {
            await cognitiveData.fetchCognitiveHistory(auth.patientId!, _selectedPeriod);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(),
              const SizedBox(height: 20),
              if (cognitiveData.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (cognitiveData.errorMessage != null)
                _buildErrorCard(cognitiveData.errorMessage!)
              else ...[
                CognitiveMetricsCard(cognitiveHistory: cognitiveData.cognitiveHistory),
                const SizedBox(height: 20),
                CognitiveChart(cognitiveHistory: cognitiveData.cognitiveHistory),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Period',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildPeriodChip(7, '7 Days'),
                _buildPeriodChip(30, '30 Days'),
                _buildPeriodChip(90, '90 Days'),
                _buildPeriodChip(-1, 'All Time'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(int days, String label) {
    final isSelected = _selectedPeriod == days;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPeriod = days);
          final auth = context.read<AuthProvider>();
          if (auth.patientId != null) {
            context.read<CognitiveDataProvider>().fetchCognitiveHistory(auth.patientId!, days);
          }
        }
      },
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
            IconButton(
              onPressed: () => context.read<CognitiveDataProvider>().clearError(),
              icon: Icon(Icons.close, color: Colors.red.shade600),
            ),
          ],
        ),
      ),
    );
  }
}