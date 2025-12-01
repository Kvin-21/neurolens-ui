import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Manages authentication state for the application.
class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _patientId;
  String? _role;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get patientId => _patientId;
  String? get role => _role;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    final credentials = await _api.getStoredCredentials();
    if (credentials['access_token'] == null) return;

    _isAuthenticated = true;
    _patientId = credentials['patient_id'];
    _role = credentials['role'];
    notifyListeners();
  }

  Future<bool> login(String patientId, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.login(patientId, password, role);

      if (result['success']) {
        _isAuthenticated = true;
        _patientId = patientId;
        _role = role;
        _errorMessage = null;
      } else {
        _errorMessage = result['error'];
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return _isAuthenticated;
  }

  Future<bool> singpassLogin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.singpassInit();

      if (result['success']) {
        // Simulated SingPass authentication
        _isAuthenticated = true;
        _patientId = 'P001';
        _role = 'caregiver';
        _errorMessage = null;
      } else {
        _errorMessage = result['error'];
      }
    } catch (e) {
      _errorMessage = 'SingPass login failed: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return _isAuthenticated;
  }

  Future<void> logout() async {
    await _api.clearStorage();
    _isAuthenticated = false;
    _patientId = null;
    _role = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}