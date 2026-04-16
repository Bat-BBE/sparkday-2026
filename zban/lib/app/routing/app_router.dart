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
  final session = ref.watch(authSessionProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _GoRouterRefresh(ref),
    redirect: (context, state) {
      final loc = state.uri.path;
      final isLoading = session.isLoading;
      final isAuthed = session.valueOrNull != null;

      // Splash screen while auth is resolving
      if (isLoading && loc != '/splash') return '/splash';

      // Let splash handle its own navigation
      if (loc == '/splash') return null;

      // Unauthenticated users can only stay on auth pages
      if (!isAuthed && (loc == '/welcome' || loc == '/login' || loc == '/signup')) {
        return null;
      }
      if (!isAuthed) return '/welcome';

      // Authenticated users shouldn't go back to auth pages
      if (isAuthed && (loc == '/welcome' || loc == '/login' || loc == '/signup')) {
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
