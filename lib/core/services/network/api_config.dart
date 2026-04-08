import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(milliseconds: 30000),
    this.receiveTimeout = const Duration(milliseconds: 30000),
    this.headers = const <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  });

  static const String PRODUCTION = 'production';
  static const String DEVELOP = 'develop';

  static const String currentMode = DEVELOP;

  factory ApiConfig.getServerUrl() {
    if (kReleaseMode) {
      return ApiConfig(baseUrl: 'https://api.wismaamal.com');
    } else {
      switch (currentMode) {
        case PRODUCTION:
          return ApiConfig(baseUrl: 'https://api.wismaamal.com');
        case DEVELOP:
          return ApiConfig(baseUrl: 'http://localhost');
        default:
          return ApiConfig(baseUrl: 'https://api.wismaamal.com');
      }
    }
  }

  factory ApiConfig.getUrl() {
    if (kReleaseMode) {
      return ApiConfig(baseUrl: 'https://api.wismaamal.com/api');
    } else {
      switch (currentMode) {
        case PRODUCTION:
          return ApiConfig(baseUrl: 'https://api.wismaamal.com/api');
        case DEVELOP:
          return ApiConfig(baseUrl: 'http://localhost/api');
        default:
          return ApiConfig(baseUrl: 'https://api.wismaamal.com/api');
      }
    }
  }

  factory ApiConfig.defaultConfig() =>
      const ApiConfig(baseUrl: 'https://localhost:8000/api');

  factory ApiConfig.development() =>
      const ApiConfig(baseUrl: 'http://localhost:8000/api');

  factory ApiConfig.production() =>
      const ApiConfig(baseUrl: 'https://api.wismaamal.com/api');

  static String getStorageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    final baseUrl = ApiConfig.getServerUrl().baseUrl;

    // Remove all whitespace, newlines, and invisible control characters/non-ASCII chars
    String cleanPath = path
        .replaceAll(RegExp(r'\s+'), '') // Remove all whitespace (including \n \r \t)
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '') // Remove non-printable/hidden characters
        .trim();

    if (cleanPath.startsWith('http')) return cleanPath;

    // Ensure single slash between base and path
    final hasSlash = cleanPath.startsWith('/');
    return '$baseUrl${hasSlash ? cleanPath : '/$cleanPath'}';
  }

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, dynamic> headers;
}
