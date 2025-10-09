import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  /// Factory utama untuk mengonversi error Dio jadi AppException
  factory AppException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AppException("Connection timeout. Please try again.", code: 408);

      case DioExceptionType.receiveTimeout:
        return AppException("Receive timeout. Server took too long to respond.", code: 408);

      case DioExceptionType.sendTimeout:
        return AppException("Send timeout. Please check your connection.", code: 408);

      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        final data = response?.data;
        final msg = _parseServerMessage(data, statusCode);
        return AppException(msg, code: statusCode, details: data);

      case DioExceptionType.connectionError:
        return AppException("No Internet connection detected. Please check your network.", code: 503);

      case DioExceptionType.cancel:
        return AppException("Request cancelled by user.");

      default:
        return AppException("Unexpected error: ${error.message ?? 'Unknown'}");
    }
  }

  /// Factory tambahan untuk error non-Dio (misalnya parsing, logic, dll)
  factory AppException.other(dynamic error) {
    if (error is FormatException) {
      return AppException("Data format error: ${error.message}");
    } else if (error is TypeError) {
      return AppException("Type mismatch: ${error.toString()}");
    } else {
      return AppException(error.toString());
    }
  }

  static String _parseServerMessage(dynamic data, int? statusCode) {
    // Kalau response-nya JSON dari API, coba ekstrak pesan error-nya
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('error')) return data['error'].toString();
      if (data.containsKey('errors')) {
        // Kalau bentuknya {"errors": {"email": ["Already taken"]}}
        final errors = data['errors'];
        if (errors is Map) {
          return errors.values.first is List
              ? (errors.values.first as List).first.toString()
              : errors.values.first.toString();
        }
      }
    }

    // Fallback berdasarkan status code umum
    switch (statusCode) {
      case 400:
        return "Bad request — please check your input.";
      case 401:
        return "Unauthorized — please login again.";
      case 403:
        return "Access denied — you don't have permission.";
      case 404:
        return "Resource not found.";
      case 409:
        return "Conflict — resource already exists.";
      case 422:
        return "Validation error — please check your data.";
      case 500:
        return "Server error — please try again later.";
      case 503:
        return "Service unavailable — please try again later.";
      default:
        return "Unexpected server response (${statusCode ?? 'unknown'}).";
    }
  }

  @override
  String toString() => "AppException($code): $message";
}
