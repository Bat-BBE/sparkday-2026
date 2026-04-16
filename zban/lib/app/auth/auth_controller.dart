import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_errors.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'auth_api.dart';
import 'auth_models.dart';
import 'auth_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(apiClientProvider)));
final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

final lastAuthErrorProvider = StateProvider<ApiFailure?>((ref) => null);

final authSessionProvider = StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  final Ref ref;
  AuthController(this.ref) : super(const AsyncValue.loading()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = await ref.read(authStorageProvider).readToken();
    if (token == null || token.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }
    try {
      final me = await ref.read(authApiProvider).me(token: token);
      final user = AuthUser.fromJson((me['user'] ?? const <String, dynamic>{}) as Map<String, dynamic>);
      final session = AuthSession(token: token, user: user);
      await ref.read(themeControllerProvider.notifier).setTheme(AppThemes.fromWire(user.theme));
      state = AsyncValue.data(session);
    } catch (e, st) {
      await ref.read(authStorageProvider).clear();
      state = AsyncValue.error(e, st);
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final session = await ref.read(authApiProvider).login(email: email, password: password);
      await ref.read(authStorageProvider).saveToken(session.token);
      await ref.read(themeControllerProvider.notifier).setTheme(AppThemes.fromWire(session.user.theme));
      ref.read(lastAuthErrorProvider.notifier).state = null;
      state = AsyncValue.data(session);
    } catch (e, st) {
      final failure = e is ApiFailure ? e : mapDioError(e);
      ref.read(lastAuthErrorProvider.notifier).state = failure;
      state = AsyncValue.error(failure, st);
      state = const AsyncValue.data(null);
      throw failure;
    }
  }

  Future<void> signup({
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
    required AppThemeKey theme,
  }) async {
    state = const AsyncValue.loading();
    try {
      final session = await ref.read(authApiProvider).signup(
            fullName: fullName,
            email: email,
            password: password,
            ageRange: ageRange,
            gender: gender,
            hasLoan: hasLoan,
            hasSavings: hasSavings,
            profileImageBase64: profileImageBase64,
            incomeSources: incomeSources,
            expenseSources: expenseSources,
            customIncomeSources: customIncomeSources,
            customExpenseSources: customExpenseSources,
            theme: AppThemes.toWire(theme),
          );
      await ref.read(authStorageProvider).saveToken(session.token);
      await ref.read(themeControllerProvider.notifier).setTheme(AppThemes.fromWire(session.user.theme));
      ref.read(lastAuthErrorProvider.notifier).state = null;
      state = AsyncValue.data(session);
    } catch (e, st) {
      final failure = e is ApiFailure ? e : mapDioError(e);
      ref.read(lastAuthErrorProvider.notifier).state = failure;
      state = AsyncValue.error(failure, st);
      state = const AsyncValue.data(null);
      throw failure;
    }
  }

  Future<void> logout() async {
    await ref.read(authStorageProvider).clear();
    state = const AsyncValue.data(null);
  }
}

