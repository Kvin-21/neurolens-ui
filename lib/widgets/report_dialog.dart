import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cognitive_data_provider.dart';

/// Dialog for generating cognitive health reports.
class ReportDialog extends StatefulWidget {
  final String patientId;
  final int selectedPeriod;

  const ReportDialog({super.key, required this.patientId, required this.selectedPeriod});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  int _days = 30;

  @override
  void initState() {
    super.initState();
    _days = widget.selectedPeriod;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<CognitiveDataProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Generate Report',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Select report period:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                _buildPeriodChip(7, '7 Days'),
                _buildPeriodChip(30, '30 Days'),
                _buildPeriodChip(90, '90 Days'),
                _buildPeriodChip(-1, 'All Time'),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The report will include cognitive trends, performance analysis, and recommendations for Patient ${widget.patientId}.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (data.reportData != null) ...[
              _buildReportPreview(data.reportData!),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: data.isGeneratingReport ? null : () => _generate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: data.isGeneratingReport
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Generate Report'),
                ),
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
        if (selected) setState(() => _days = days);
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildReportPreview(Map<String, dynamic> report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Text(
                'Report Generated Successfully',
                style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Report for ${report['patient_name'] ?? widget.patientId}', style: TextStyle(color: Colors.green.shade600)),
          Text('Period: ${report['report_period'] ?? 'Unknown'}', style: TextStyle(color: Colors.green.shade600)),
          Text('Generated: ${DateTime.now().toString().substring(0, 16)}', style: TextStyle(color: Colors.green.shade600)),
        ],
      ),
    );
  }

  void _generate(BuildContext context) async {
    await context.read<CognitiveDataProvider>().generateReport(widget.patientId, _days);

    final data = context.read<CognitiveDataProvider>();
    if (data.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data.errorMessage!), backgroundColor: Colors.red),
      );
      data.clearError();
    }
  }
}