import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

/// Handles all API communication with the NeuroLens backend.
class ApiService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, String?>> getStoredCredentials() async {
    return {
      'access_token': await _storage.read(key: 'access_token'),
      'refresh_token': await _storage.read(key: 'refresh_token'),
      'patient_id': await _storage.read(key: 'patient_id'),
      'role': await _storage.read(key: 'role'),
    };
  }

  Future<void> saveCredentials(
    String accessToken,
    String refreshToken,
    String patientId,
    String role,
  ) async {
    await Future.wait([
      _storage.write(key: 'access_token', value: accessToken),
      _storage.write(key: 'refresh_token', value: refreshToken),
      _storage.write(key: 'patient_id', value: patientId),
      _storage.write(key: 'role', value: role),
    ]);
  }

  Future<void> clearStorage() async {
    await _storage.deleteAll();
  }

  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    int retryCount = 0,
  }) async {
    final stored = await getStoredCredentials();
    final accessToken = stored['access_token'];

    if (accessToken == null) throw Exception('No access token available');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      http.Response response;
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      if (method == 'GET') {
        response = await http.get(uri, headers: headers)
            .timeout(ApiConfig.requestTimeout);
      } else {
        response = await http.post(
          uri,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        ).timeout(ApiConfig.requestTimeout);
      }

      // Retry once on auth failure
      if (response.statusCode == 401 && retryCount < 2) {
        final refreshed = await refreshToken();
        if (refreshed) {
          return _makeRequest(method, endpoint, body: body, retryCount: retryCount + 1);
        }
        throw Exception('Authentication failed - unable to refresh token');
      }

      return response;
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout - server may be unavailable');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Network error - please check connection');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(
    String patientId,
    String password,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_id': patientId,
          'password': password,
          'role': role,
        }),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveCredentials(
          data['access_token'],
          data['refresh_token'],
          patientId,
          role,
        );
        return {'success': true, 'data': data};
      }

      final errorData = json.decode(response.body);
      return {'success': false, 'error': errorData['error'] ?? 'Login failed'};
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return {'success': false, 'error': 'Login timeout - server may be unavailable'};
      } else if (e.toString().contains('SocketException')) {
        return {'success': false, 'error': 'Network error - please check connection'};
      }
      return {'success': false, 'error': 'Connection error'};
    }
  }

  Future<bool> refreshToken() async {
    try {
      final stored = await getStoredCredentials();
      final token = stored['refresh_token'];
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveCredentials(
          data['access_token'],
          data['refresh_token'] ?? token,
          stored['patient_id']!,
          stored['role']!,
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> pullCognitiveHistory(
    String patientId,
    int days,
  ) async {
    try {
      final response = await _makeRequest(
        'POST',
        ApiConfig.pullCognitiveHistoryEndpoint,
        body: {'patient_id': patientId, 'days': days},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      }

      final errorData = json.decode(response.body);
      return {
        'success': false,
        'error': errorData['error'] ?? 'Failed to fetch cognitive history',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> processPatientData(
    Map<String, dynamic> patientData,
  ) async {
    try {
      final response = await _makeRequest(
        'POST',
        ApiConfig.processPatientDataEndpoint,
        body: patientData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      }

      final errorData = json.decode(response.body);
      return {
        'success': false,
        'error': errorData['error'] ?? 'Failed to process patient data',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// SingPass authentication (kept for legacy support).
  Future<Map<String, dynamic>> singpassInit() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/singpass/init'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      }
      return {'success': false, 'error': 'SingPass initialisation failed'};
    } catch (_) {
      return {'success': false, 'error': 'SingPass service unavailable'};
    }
  }

  /// Report generation (kept for legacy support).
  Future<Map<String, dynamic>> generateReport(String patientId, int days) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/generate_report',
        body: {'patient_id': patientId, 'days': days},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      }

      final errorData = json.decode(response.body);
      return {
        'success': false,
        'error': errorData['error'] ?? 'Failed to generate report',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}