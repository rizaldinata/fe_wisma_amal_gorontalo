import 'package:dio/dio.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/services/storage/secure_storage.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor(this.secureStorageService);

  final SecureStorageService secureStorageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final List<String> publicRoutes = [
      '/login',
      '/register',
      '/forgot-password',
    ];

    bool isPublicEndpoint = publicRoutes.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (!isPublicEndpoint) {
      print('Fetching token for protected endpoint...');
      final String? token = await secureStorageService.get(
        StorageConstant.token,
      );
      print('Token: $token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    print('REQUEST: ${options.method} ${options.path}');
    print('HEADERS: ${options.headers}');

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    //handle jika token expired -> lalu hapus token & redirect ke login
    if (err.response?.statusCode == 401) {
      await secureStorageService.delete(StorageConstant.token);

      //memanggil logout yang nantinya merubah login status, sehingga go_router akan otomatis redirect ke login
      // _authController.logout();
    }

    return handler.next(err);
  }
}
