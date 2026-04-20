import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/welcome/welcome_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _GoRouterRefresh(ref),
    redirect: (context, state) {
      final session = ref.read(authSessionProvider);
      final loc = state.uri.path;
      final isAuthed = session.valueOrNull != null;

      final isAuthPage =
          loc == '/welcome' || loc == '/login' || loc == '/signup';

      if (loc == '/splash') return null;

      if (session.isLoading) return null;

      if (!isAuthed) {
        return isAuthPage ? null : '/welcome';
      }

      if (isAuthed && isAuthPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
});

class _GoRouterRefresh extends ChangeNotifier {
  _GoRouterRefresh(this.ref) {
    ref.listen<AsyncValue<dynamic>>(
      authSessionProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref ref;
}
