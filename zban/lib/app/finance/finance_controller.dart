import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../network/api_errors.dart';
import 'finance_api.dart';
import 'finance_models.dart';

final financeApiProvider = Provider<FinanceApi>((ref) => FinanceApi(ref.watch(apiClientProvider)));
final financeLastErrorProvider = StateProvider<ApiFailure?>((ref) => null);

final financeProvider =
    StateNotifierProvider<FinanceController, AsyncValue<FinanceSnapshot>>((ref) {
  return FinanceController(ref);
});

class FinanceController extends StateNotifier<AsyncValue<FinanceSnapshot>> {
  final Ref ref;
  FinanceController(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  String? get _token => ref.read(authSessionProvider).valueOrNull?.token;

  Future<void> load() async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = const AsyncValue.data(
          FinanceSnapshot(accounts: [], transactions: [], debts: []));
      return;
    }
    state = const AsyncValue.loading();
    try {
      final api = ref.read(financeApiProvider);
      final accounts = await api.getAccounts(token);
      final transactions = await api.getTransactions(token);
      final debts = await api.getDebts(token);
      ref.read(financeLastErrorProvider.notifier).state = null;
      state = AsyncValue.data(
          FinanceSnapshot(accounts: accounts, transactions: transactions, debts: debts));
    } catch (e, st) {
      final failure = e is ApiFailure ? e : mapDioError(e);
      ref.read(financeLastErrorProvider.notifier).state = failure;
      state = AsyncValue.error(failure, st);
    }
  }

  Future<void> addAccount({
    required String name,
    required String type,
    required int balance,
  }) async {
    final token = _token;
    if (token == null) return;
    await ref.read(financeApiProvider).createAccount(
          token: token,
          name: name,
          type: type,
          balance: balance,
        );
    await load();
  }

  Future<void> addTransaction({
    required String accountId,
    required String type,
    required int amount,
    String? category,
    String? note,
  }) async {
    final token = _token;
    if (token == null) return;
    await ref.read(financeApiProvider).createTransaction(
          token: token,
          accountId: accountId,
          type: type,
          amount: amount,
          category: category,
          note: note,
        );
    await load();
  }

  Future<void> addDebt({
    required String kind,
    required String counterparty,
    required int amount,
    String? note,
  }) async {
    final token = _token;
    if (token == null) return;
    await ref.read(financeApiProvider).createDebt(
          token: token,
          kind: kind,
          counterparty: counterparty,
          amount: amount,
          note: note,
        );
    await load();
  }
}

