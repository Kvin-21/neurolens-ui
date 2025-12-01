import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'patient_reports_screen.dart';
import 'cognitive_charts_screen.dart';

/// Home screen for caregivers showing patient overview and quick actions.
class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  Map<String, dynamic>? _data;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final data = await auth.getCognitiveHistory(auth.patientId!, 30);

    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _showLogoutDialog(context)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.medical_services, size: 40, color: Color(0xFF2196F3)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome, Caregiver',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Monitoring patient: ${auth.patientId}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Patient status card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Patient Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (_loading)
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_data != null && _data!['cognitive_history'] != null)
                        _buildStatusFromData()
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('Status', 'No Data', Colors.grey),
                            _buildStatItem('Records', '0', Colors.grey),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text('Analytics & Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              SizedBox(
                height: 200,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildActionCard(
                      context,
                      'Cognitive Charts',
                      'View detailed analytics',
                      Icons.show_chart,
                      const Color(0xFF2196F3),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CognitiveChartsScreen(cognitiveData: _data)),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Generate Report',
                      'Create cognitive reports',
                      Icons.assessment,
                      Colors.green,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientReportsScreen())),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_data != null && _data!['cognitive_history'] != null)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recent Data Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text('Latest Entry: ${_getLatestEntryDate()}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Total Records: ${_data!['cognitive_history'].length}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          'Last Updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} today',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFromData() {
    final history = _data!['cognitive_history'] as List;
    final recordCount = history.length;
    final lastEntry = history.isNotEmpty ? history.first : null;

    String status = 'No Data';
    Color statusColour = Colors.grey;

    if (lastEntry != null) {
      final entryDate = DateTime.parse(lastEntry['date']);
      final hoursSinceLastEntry = DateTime.now().difference(entryDate).inHours;

      if (hoursSinceLastEntry < 24) {
        status = 'Recent';
        statusColour = Colors.green;
      } else if (hoursSinceLastEntry < 72) {
        status = 'OK';
        statusColour = Colors.orange;
      } else {
        status = 'Overdue';
        statusColour = Colors.red;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Last Check-in', status, statusColour),
        _buildStatItem('Total Records', recordCount.toString(), Colors.blue),
      ],
    );
  }

  String _getLatestEntryDate() {
    final history = _data!['cognitive_history'] as List;
    if (history.isEmpty) return 'No data';

    final latestEntry = history.first;
    final date = DateTime.parse(latestEntry['date']);
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatItem(String label, String value, Color colour) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colour)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color colour,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: colour),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthProvider>().logout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}