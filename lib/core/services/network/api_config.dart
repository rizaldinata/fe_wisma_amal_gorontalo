class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(milliseconds: 30000),
    this.receiveTimeout = const Duration(milliseconds: 30000),
    this.headers = const <String, String>{'Content-Type': 'application/json'},
  });

  factory ApiConfig.defaultConfig() =>
      const ApiConfig(baseUrl: 'https://localhost:8000/api');

  factory ApiConfig.development() => const ApiConfig(
    baseUrl: 'https://localhost:8000/api',
  );

  factory ApiConfig.production() =>
      const ApiConfig(baseUrl: 'https://localhost:8000/api');

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, dynamic> headers;
}