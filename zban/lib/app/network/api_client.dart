import 'package:dio/dio.dart';

import '../constants.dart';

class ApiClient {
  final Dio dio;

  ApiClient({String? baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? apiBaseUrl(),
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: const {'Content-Type': 'application/json'},
          ),
        );
}

