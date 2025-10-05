import 'package:dio/dio.dart';
import 'package:dio/browser.dart'; // untuk web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend/core/services/network/api_config.dart';
import 'package:frontend/core/services/network/interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  

  DioClient({
    required this.apiConfig,
    required SharedPreferences SharedPreferences,
    required Dio dio,
  })  : _dio = dio,
        apiInterceptor = ApiInterceptor(SharedPreferences) {
    _setupDio();
  }



  final Dio _dio;
  final ApiConfig apiConfig;
  final ApiInterceptor apiInterceptor;

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: apiConfig.baseUrl,
      connectTimeout: apiConfig.connectTimeout,
      receiveTimeout: apiConfig.receiveTimeout,
      headers: apiConfig.headers,
    );

    _dio.interceptors.clear();
    _dio.interceptors.add(apiInterceptor);
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }



}


