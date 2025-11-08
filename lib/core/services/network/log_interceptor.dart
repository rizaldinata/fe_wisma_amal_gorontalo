import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
//import 'package:smartsiklon_mobile/core/utils/mixins/logger.dart' hide Logger;

class PrettyDioLogger extends Interceptor {
  var logger = Logger(
    filter: null, // Use the default LogFilter (-> only log in debug mode)
    printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
    output: null, // Use the default LogOutput (-> send everything to console)
  );

  final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i('''
\x1B[33m=== REQUEST ===\x1B[0m
➡️  [${options.method}] ${options.uri}
🔍 Query: ${_prettyJson(options.queryParameters)}')
🧾 Body : ${options.data}
\x1B[33m================\x1B[0m
''');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      logger.i('''
\x1B[32m=== RESPONSE ===\x1B[0m
✅ URL: ${response.requestOptions.uri}
📦 Status: ${response.statusCode}
🧾 Data: ${_prettyJson(response.data)}
\x1B[32m================\x1B[0m
      ''');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      logger.e('''
\x1B[31m=== ERROR ===\x1B[0m
❌ URL: ${err.requestOptions.uri}
🚨 Message: ${err.message}
📦 Status: ${err.response?.statusCode}
🧾 Data: ${_prettyJson(err.response?.data)}
\x1B[31m==============\x1B[0m
''');
    }
    super.onError(err, handler);
  }

  String _prettyJson(dynamic data) {
    try {
      if (data is String) {
        return _encoder.convert(json.decode(data));
      }
      return _encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }
}
