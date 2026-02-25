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

  static const String currentMode = PRODUCTION;

  factory ApiConfig.getServerUrl() {
    if (kReleaseMode) {
      return ApiConfig(baseUrl: 'https://api.wismaamal.com');
    } else {
      switch (currentMode) {
        case PRODUCTION:
          return ApiConfig(baseUrl: 'https://api.wismaamal.com');
        case DEVELOP:
          return ApiConfig(baseUrl: 'http://127.0.0.1:8000');
        default:
          return ApiConfig(baseUrl: 'https://api.wismaamal.com');
      }
    }
  }

  ApiConfig getUrl() {
    if (kReleaseMode) {
      return ApiConfig(baseUrl: 'https://api.wismaamal.com/api');
    } else {
      switch (currentMode) {
        case PRODUCTION:
          return ApiConfig(baseUrl: 'https://api.wismaamal.com/api');
        case DEVELOP:
          return ApiConfig(baseUrl: 'http://127.0.0.1:8000/api');
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

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, dynamic> headers;
}
