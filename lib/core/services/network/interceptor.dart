import 'package:dio/dio.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/storage/secure_storage.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';

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
      // Dispatch session expired event to AuthBloc
      serviceLocator<AuthBloc>().add(const SessionExpiredEvent());
    }

    return handler.next(err);
  }
}
