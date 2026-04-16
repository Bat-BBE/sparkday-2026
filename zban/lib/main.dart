import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app/routing/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final key = ref.watch(themeControllerProvider);
        final GoRouter router = ref.watch(routerProvider);
        return MaterialApp.router(
          title: 'AMON',
          theme: AppThemes.light(key),
          darkTheme: AppThemes.light(key),
          themeMode: ThemeMode.light,
          routerConfig: router,
        );
      },
    );
  }
}
