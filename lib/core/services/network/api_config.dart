import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(milliseconds: 30000),
    this.receiveTimeout = const Duration(milliseconds: 30000),
    this.headers = const <String, String>{'Content-Type': 'application/json',},
  });

  static const String PRODUCTION = 'production';
  static const String DEVELOP = 'develop';


  // Set mode yang ingin digunakan
  static const String currentMode = DEVELOP;

  ApiConfig getUrl() {
    if (kReleaseMode) {
       return ApiConfig(baseUrl: 'https://api.wismaamalgorontalo.site/api');
    } else {
      switch (currentMode) {
      case PRODUCTION:
        return ApiConfig(baseUrl: 'https://api.wismaamalgorontalo.site/api');
      case DEVELOP:
        return ApiConfig(baseUrl: 'http://localhost:8000/api');
      default:
        return ApiConfig(baseUrl: 'https://api.wismaamalgorontalo.site/api');
    }
    }

    
  }

  factory ApiConfig.defaultConfig() =>
      const ApiConfig(baseUrl: 'https://localhost:8000/api');

  factory ApiConfig.development() => const ApiConfig(
    baseUrl: 'http://localhost:8000/api',
  );

  factory ApiConfig.production() =>
      const ApiConfig(baseUrl: 'https://api.wismaamalgorontalo.site/api');

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, dynamic> headers;
}