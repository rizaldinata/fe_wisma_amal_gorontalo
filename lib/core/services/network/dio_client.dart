import 'package:dio/dio.dart';
import 'package:frontend/core/services/network/api_config.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/core/services/network/interceptor.dart';
import 'package:frontend/core/services/network/log_interceptor.dart';
import 'package:frontend/core/services/storage/secure_storage.dart';

class DioClient {
  DioClient({
    required this.apiConfig,
    required SecureStorageService secureStorage,
    required Dio dio,
  }) : _dio = dio,
       apiInterceptor = ApiInterceptor(secureStorage) {
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
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: false,
        responseBody: false,
      ),
    );
    _dio.interceptors.add(PrettyDioLogger());
  }

  // =====================
  // Generic HTTP methods
  // =====================

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      // Ambil AppException dari error interceptor
      if (e.error is AppException) throw e.error!;
      throw AppException.fromDioError(e);
    } catch (e) {
      throw AppException.other(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw AppException.fromDioError(e);
    } catch (e) {
      throw AppException.other(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw AppException.fromDioError(e);
    } catch (e) {
      throw AppException.other(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw AppException.fromDioError(e);
    } catch (e) {
      throw AppException.other(e);
    }
  }

  // =====================
  // HTTP methods without exception handling
  // =====================

  Future<Response<T>> getWithoutException<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParams,
      options: options,
    );
  }

  Future<Response<T>> postWithoutException<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParams,
      options: options,
    );
  }

  Future<Response<T>> putWithoutException<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParams,
      options: options,
    );
  }

  Future<Response<T>> deleteWithoutException<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParams,
      options: options,
    );
  }
}
