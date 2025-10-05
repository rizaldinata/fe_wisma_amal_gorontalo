import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor();


  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Sebelum request dikirim
      print("Request: ${options.method} ${options.path}");

      // Misalnya inject access token dari memory
      final token = AccessTokenMemory.instance.token;
      if (token != null) {
        options.headers["Authorization"] = "Bearer $token";
      }

      return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Setelah response diterima
    print("Response: ${response.statusCode} ${response.requestOptions.path}");
    return handler.next(response);
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