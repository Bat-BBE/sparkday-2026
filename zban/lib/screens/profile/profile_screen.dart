import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth/auth_controller.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/theme_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final session = ref.watch(authSessionProvider).valueOrNull;
    final user = session?.user;
    final name = user?.fullName ?? 'Хэрэглэгч';
    final email = user?.email ?? '';

    ImageProvider? avatar;
    final b64 = user?.profileImageBase64;
    if (b64 != null && b64.trim().isNotEmpty) {
      try {
        avatar = MemoryImage(base64Decode(b64));
      } catch (_) {
        avatar = null;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          Positioned(
              top: -90,
              left: -70,
              child:
                  _Blob(color: cs.primary.withValues(alpha: 0.45), size: 260)),
          Positioned(
              top: 60,
              right: -70,
              child: _Blob(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.22),
                  size: 220)),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox.shrink(),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0x0AFFFFFF),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: const Color(0x1AFFFFFF)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Color(0xCCFFFFFF), size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Профайл',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 18),
                _GlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [cs.primary, const Color(0xFF38BDF8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: cs.primary.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6))
                          ],
                        ),
                        child: ClipOval(
                          child: avatar != null
                              ? Image(image: avatar, fit: BoxFit.cover)
                              : Center(
                                  child: Text(
                                    name.trim().isEmpty
                                        ? 'AM'
                                        : name
                                            .trim()
                                            .split(' ')
                                            .take(2)
                                            .map((w) => w[0].toUpperCase())
                                            .join(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16)),
                            const SizedBox(height: 3),
                            Text(email,
                                style: const TextStyle(
                                    color: Color(0x70FFFFFF), fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border:
                              Border.all(color: cs.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          user?.theme ?? 'dark',
                          style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const _SectionTitle('Апп өнгө'),
                const SizedBox(height: 10),
                _GlassCard(
                  child: _ThemePicker(ref: ref),
                ),
                const SizedBox(height: 16),
                const _SectionTitle('Тохиргоо'),
                const SizedBox(height: 10),
                _GlassCard(
                  child: Column(
                    children: [
                      _RowAction(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Нууцлал',
                        subtitle: 'Хувийн мэдээллийн тохиргоо',
                        onTap: () {},
                        primary: cs.primary,
                      ),
                      const Divider(height: 1, color: Color(0x12FFFFFF)),
                      _RowAction(
                        icon: Icons.help_outline_rounded,
                        title: 'Тусламж',
                        subtitle: 'FAQ ба дэмжлэг',
                        onTap: () {},
                        primary: cs.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _GradientButton(
                  label: 'Гарах',
                  loading: false,
                  onPressed: () async {
                    await ref.read(authSessionProvider.notifier).logout();
                    if (context.mounted) context.go('/welcome');
                  },
                  primary: const Color(0xFFFB7185),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 10,
            color: Color(0x55FFFFFF),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600));
  }
}

class _RowAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color primary;
  const _RowAction(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      required this.primary});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withValues(alpha: 0.28)),
              ),
              child: Icon(icon, size: 18, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0x70FFFFFF),
                          fontWeight: FontWeight.w600,
                          fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0x66FFFFFF)),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x10FFFFFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x14FFFFFF)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  final WidgetRef ref;
  const _ThemePicker({required this.ref});

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(themeControllerProvider);
    return Row(
      children: AppThemeKey.values.map((k) {
        final selected = k == current;
        return GestureDetector(
          onTap: () => ref.read(themeControllerProvider.notifier).setTheme(k),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppThemes.seed(k),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppThemes.seed(k).withValues(alpha: 0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: selected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  final Color primary;
  const _GradientButton({
    required this.label,
    required this.loading,
    required this.onPressed,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, Color.lerp(primary, Colors.black, 0.18)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.30),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.2, color: Colors.white))
            : Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.3)),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

