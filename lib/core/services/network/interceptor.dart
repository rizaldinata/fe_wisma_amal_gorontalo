import 'package:dio/dio.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:shared_preferences/src/shared_preferences_legacy.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor(this._sharedPrefsStorage);

  SharedPrefsStorage _sharedPrefsStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
   final String? token = await _sharedPrefsStorage.getToken() ;

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    print('HEADER ${options.headers}');

    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // delete stored token
      AccessTokenMemory.instance.clear();
    }

    return handler.next(err);
  }
}

class AccessTokenMemory {
  static final AccessTokenMemory instance = AccessTokenMemory._();
  AccessTokenMemory._();

  String? token; // simpan access token hanya di memory (tidak persistent)

  void clear() {
    token = null;
  }
}