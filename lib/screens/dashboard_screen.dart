import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cognitive_data_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/overview_stats.dart';
import '../widgets/cognitive_metrics_card.dart';
import '../widgets/cognitive_trends_chart.dart';
import '../widgets/speech_metrics_chart.dart';
import '../widgets/cognitive_performance_chart.dart';
import '../widgets/report_dialog.dart';

/// Main dashboard screen showing cognitive health metrics.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _days = 30; // Selected time period in days (-1 = all time)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    if (auth.patientId == null) return;
    context.read<CognitiveDataProvider>().fetchCognitiveHistory(auth.patientId!, _days);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final data = context.watch<CognitiveDataProvider>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Theme.of(context).primaryColor, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NeuroLens', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  'Patient ${auth.patientId ?? "Unknown"}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: theme.toggleTheme,
            icon: Icon(theme.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
          const SizedBox(width: 8),
          _buildReportButton(data, isMobile),
          const SizedBox(width: 8),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: auth.logout,
                child: const Row(
                  children: [Icon(Icons.logout), SizedBox(width: 12), Text('Logout')],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildPeriodSelector(),
              const SizedBox(height: 24),
              _buildContent(data, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportButton(CognitiveDataProvider data, bool isMobile) {
    return ElevatedButton.icon(
      onPressed: data.isGeneratingReport ? null : () => _showReportDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: data.isGeneratingReport
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.assessment, size: 18),
      label: Text(
        isMobile ? 'Report' : 'Generate Report',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildContent(CognitiveDataProvider data, bool isMobile) {
    if (data.isLoading) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()),
      );
    }

    if (data.errorMessage != null) return _buildErrorCard(data.errorMessage!);

    return Column(
      children: [
        OverviewStats(cognitiveHistory: data.cognitiveHistory),
        const SizedBox(height: 24),
        CognitiveMetricsCard(cognitiveHistory: data.cognitiveHistory),
        const SizedBox(height: 24),
        _buildCharts(data, isMobile),
      ],
    );
  }

  Widget _buildCharts(CognitiveDataProvider data, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          CognitiveTrendsChart(cognitiveHistory: data.cognitiveHistory),
          const SizedBox(height: 24),
          SpeechMetricsChart(cognitiveHistory: data.cognitiveHistory),
          const SizedBox(height: 24),
          CognitivePerformanceChart(cognitiveHistory: data.cognitiveHistory),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              CognitiveTrendsChart(cognitiveHistory: data.cognitiveHistory),
              const SizedBox(height: 24),
              SpeechMetricsChart(cognitiveHistory: data.cognitiveHistory),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(child: CognitivePerformanceChart(cognitiveHistory: data.cognitiveHistory)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dashboard, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cognitive Dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Real-time cognitive performance monitoring',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Period',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
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
    final isSelected = _days == days;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (!selected) return;
        setState(() => _days = days);
        _loadData();
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).cardColor,
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Loading Data',
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(error, style: TextStyle(color: Colors.red.shade600)),
                ],
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

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ReportDialog(
        patientId: context.read<AuthProvider>().patientId ?? '',
        selectedPeriod: _days,
      ),
    );
  }
}