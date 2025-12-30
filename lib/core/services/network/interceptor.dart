import 'package:dio/dio.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor(this._sharedPrefsStorage);

  final SharedPrefsStorage _sharedPrefsStorage;
  

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {

  final List<String> publicRoutes = ['/login', '/register', '/forgot-password'];
  
  bool isPublicEndpoint = publicRoutes.any((endpoint) => options.path.contains(endpoint));
  
  print('Is public endpoint: $isPublicEndpoint');
  print('Request path: ${options.path}');

  if (!isPublicEndpoint) {
    print('Fetching token for protected endpoint...');
    final String? token =  _sharedPrefsStorage.getToken();
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
      
      await _sharedPrefsStorage.clearToken();

      //memanggil logout yang nantinya merubah login status, sehingga go_router akan otomatis redirect ke login
      // _authController.logout();
    }

    return handler.next(err);
  }
}
