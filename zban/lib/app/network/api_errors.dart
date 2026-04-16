import 'package:dio/dio.dart';

class ApiFailure implements Exception {
  final int? statusCode;
  final String code;
  final String messageMn;

  const ApiFailure({
    required this.code,
    required this.messageMn,
    this.statusCode,
  });

  @override
  String toString() => 'ApiFailure($statusCode, $code): $messageMn';
}

ApiFailure mapDioError(Object e) {
  if (e is DioException) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final code = (data['error'] ?? 'ERROR') as String;
      final msg = (data['messageMn'] ?? 'Алдаа гарлаа. Дахин оролдоно уу.') as String;
      return ApiFailure(code: code, messageMn: msg, statusCode: status);
    }
    return ApiFailure(
      code: 'NETWORK_ERROR',
      messageMn: 'Сүлжээний алдаа. Интернэт/серверээ шалгана уу.',
      statusCode: status,
    );
  }
  return const ApiFailure(code: 'ERROR', messageMn: 'Алдаа гарлаа. Дахин оролдоно уу.');
}

