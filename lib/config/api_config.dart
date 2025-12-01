/// API configuration for the NeuroLens backend.
class ApiConfig {
  static const String baseUrl = 'http://localhost:6767';

  static const String loginEndpoint = '/auth/login';
  static const String refreshEndpoint = '/auth/refresh';
  static const String processPatientDataEndpoint = '/process_patient_data';
  static const String pullCognitiveHistoryEndpoint = '/pull_cognitive_history';

  static const Duration requestTimeout = Duration(seconds: 30);
}