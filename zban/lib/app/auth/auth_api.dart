import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/api_errors.dart';
import 'auth_models.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(ApiClient client) : _dio = client.dio;

  Future<AuthSession> signup({
    required String fullName,
    required String email,
    required String password,
    String? ageRange,
    String? gender,
    bool? hasLoan,
    bool? hasSavings,
    String? profileImageBase64,
    required List<String> incomeSources,
    required List<String> expenseSources,
    required List<String> customIncomeSources,
    required List<String> customExpenseSources,
    required String theme,
  }) async {
    try {
      final res = await _dio.post('/auth/signup', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'ageRange': ageRange,
        'gender': gender,
        'hasLoan': hasLoan,
        'hasSavings': hasSavings,
        'profileImageBase64': profileImageBase64,
        'incomeSources': incomeSources,
        'expenseSources': expenseSources,
        'customIncomeSources': customIncomeSources,
        'customExpenseSources': customExpenseSources,
        'theme': theme,
      });
      return AuthSession.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<AuthSession> login({required String email, required String password}) async {
    try {
      final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
      return AuthSession.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> me({required String token}) async {
    try {
      final res = await _dio.get('/auth/me', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

