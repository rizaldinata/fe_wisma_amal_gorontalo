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

  // static const String localURl = 'http://localhost:8000';
  static const String localURl = 'https://api.wismaamal.com';
  static const String productionURL = 'https://alfian.taild9066e.ts.net/be';

  factory ApiConfig.getServerUrl() {
    if (kReleaseMode) {
      return ApiConfig(baseUrl: productionURL);
    } else {
      switch (currentMode) {
        case PRODUCTION:
          return ApiConfig(baseUrl: productionURL);
        case DEVELOP:
          return ApiConfig(baseUrl: localURl);
        default:
          return ApiConfig(baseUrl: productionURL);
      }
    }
  }

  factory ApiConfig.getUrl() {
    if (kReleaseMode) {
      return ApiConfig(baseUrl: "$productionURL/api");
    } else {
      switch (currentMode) {
        case PRODUCTION:
          return ApiConfig(baseUrl: "$productionURL/api");
        case DEVELOP:
          return ApiConfig(baseUrl: "$localURl/api");
        default:
          return ApiConfig(baseUrl: "$productionURL/api");
      }
    }
  }

  static String getStorageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    final baseUrl = ApiConfig.getServerUrl().baseUrl;

    String cleanPath = path
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
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
