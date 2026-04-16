import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/api_errors.dart';
import 'finance_models.dart';

class FinanceApi {
  final Dio _dio;
  FinanceApi(ApiClient client) : _dio = client.dio;

  Options _auth(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<FinanceAccount>> getAccounts(String token) async {
    try {
      final res = await _dio.get('/accounts', options: _auth(token));
      final items = (res.data['items'] as List? ?? const []);
      return items
          .map((e) => FinanceAccount.fromJson((e ?? const <String, dynamic>{}) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<FinanceTransaction>> getTransactions(String token) async {
    try {
      final res = await _dio.get('/transactions', options: _auth(token));
      final items = (res.data['items'] as List? ?? const []);
      return items
          .map((e) => FinanceTransaction.fromJson((e ?? const <String, dynamic>{}) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<FinanceDebt>> getDebts(String token) async {
    try {
      final res = await _dio.get('/debts', options: _auth(token));
      final items = (res.data['items'] as List? ?? const []);
      return items
          .map((e) => FinanceDebt.fromJson((e ?? const <String, dynamic>{}) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> createAccount({
    required String token,
    required String name,
    required String type,
    required int balance,
  }) async {
    try {
      await _dio.post('/accounts',
          options: _auth(token), data: {'name': name, 'type': type, 'balance': balance});
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> createTransaction({
    required String token,
    required String accountId,
    required String type,
    required int amount,
    String? category,
    String? note,
  }) async {
    try {
      await _dio.post('/transactions',
          options: _auth(token),
          data: {
            'accountId': accountId,
            'type': type,
            'amount': amount,
            'category': category,
            'note': note,
          });
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> createDebt({
    required String token,
    required String kind,
    required String counterparty,
    required int amount,
    String? note,
  }) async {
    try {
      await _dio.post('/debts',
          options: _auth(token),
          data: {
            'kind': kind,
            'counterparty': counterparty,
            'amount': amount,
            'note': note,
          });
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

