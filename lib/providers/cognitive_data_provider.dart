import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Manages cognitive assessment data for the dashboard.
class CognitiveDataProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _cognitiveHistory = [];
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;
  bool _isGeneratingReport = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get cognitiveHistory => _cognitiveHistory;
  Map<String, dynamic>? get reportData => _reportData;
  bool get isLoading => _isLoading;
  bool get isGeneratingReport => _isGeneratingReport;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCognitiveHistory(String patientId, int days) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.pullCognitiveHistory(patientId, days);

      if (result['success']) {
        _cognitiveHistory = List<Map<String, dynamic>>.from(
          result['data']['cognitive_history'] ?? [],
        );
        _errorMessage = null;
      } else {
        _errorMessage = result['error'];
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch data: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> generateReport(String patientId, int days) async {
    _isGeneratingReport = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.generateReport(patientId, days);

      if (result['success']) {
        _reportData = result['data'];
        _errorMessage = null;
      } else {
        _errorMessage = result['error'];
      }
    } catch (e) {
      _errorMessage = 'Failed to generate report: ${e.toString()}';
    }

    _isGeneratingReport = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearReport() {
    _reportData = null;
    notifyListeners();
  }
}