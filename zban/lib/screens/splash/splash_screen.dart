import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth/auth_controller.dart';
import '../../app/network/api_errors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const _minSplashDuration = Duration(milliseconds: 2000);

  late final AnimationController _mainCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _ringsScale;

  late final AnimationController _pulseCtrl;

  late final AnimationController _particleCtrl;
  late final List<Animation<double>> _particleAnimations;

  ProviderSubscription<AsyncValue<dynamic>>? _authSub;
  bool _authResolved = false;
  dynamic _session;
  bool _navigated = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _mainCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    _logoScale = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _mainCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0, end: 1.0)
        .animate(CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOut));

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOutCubic));
    _textFade = Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
        parent: _mainCtrl, curve: Curves.easeOut, reverseCurve: Curves.easeIn));

    _ringsScale = Tween<double>(begin: 0.5, end: 1.2)
        .animate(CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOutQuad));

    _mainCtrl.forward();

    // Pulsing animation for the core
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

    // Particle animations
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();

    _particleAnimations = List.generate(8, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _particleCtrl,
          curve: Interval(
            index * 0.125,
            1.0,
            curve: Curves.easeInOutSine,
          ),
        ),
      );
    });

    _authSub = ref.listenManual<AsyncValue<dynamic>>(
      authSessionProvider,
      (_, next) {
        next.when(
          loading: () {},
          data: (session) {
            _authResolved = true;
            _session = session;
            _tryNavigate();
          },
          error: (error, stack) {
            _authResolved = true;
            _session = null;

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  error is ApiFailure
                      ? (error.messageMn ?? 'Нэвтрэлт амжилтгүй.')
                      : 'Алдаа гарлаа. Дахин оролдоно уу.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );

            _tryNavigate();
          },
        );
      },
      fireImmediately: true,
    );

    _timer = Timer(_minSplashDuration, _tryNavigate);
  }

  void _tryNavigate() {
    if (_navigated || !mounted) return;
    if (!_authResolved) return;
    if (_timer?.isActive ?? false) return;

    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(_session == null ? '/welcome' : '/home');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authSub?.close();
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Animated gradient background
          _AnimatedGradientBackground(primary: cs.primary),

          // Floating particles
          ..._buildParticles(cs.primary),

          // Animated rings
          _AnimatedRings(animation: _ringsScale, primary: cs.primary),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with pulsing effect
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_logoScale, _logoFade, _pulseCtrl]),
                  builder: (context, _) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoFade.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring
                            Container(
                              width: 140 + 10 * _pulseCtrl.value,
                              height: 140 + 10 * _pulseCtrl.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    cs.primary.withValues(alpha: 0.3),
                                    cs.primary.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.3, 1.0],
                                ),
                              ),
                            ),
                            // Logo container
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    cs.primary,
                                    cs.primary.withValues(alpha: 0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Image.asset(
                                  'assets/branding/amon_logo.png',
                                  fit: BoxFit.contain,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                // App name with slide animation
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [cs.primary, Colors.white, cs.primary],
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds),
                          child: const Text(
                            'AMON',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Төсөвлө. Хяна. Өсгө.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Futuristic loading indicator
                _FuturisticLoader(primary: cs.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles(Color primary) {
    return List.generate(8, (index) {
      final angle = (index * 45) * (3.14159 / 180);
      final radius = 150.0;
      final dx = radius * cos(angle);
      final dy = radius * sin(angle);

      return AnimatedBuilder(
        animation: _particleAnimations[index],
        builder: (context, child) {
          final progress = _particleAnimations[index].value;
          final offset = 50 * progress;
          return Positioned(
            left: MediaQuery.of(context).size.width / 2 +
                dx -
                4 +
                (dx > 0 ? offset : -offset),
            top: MediaQuery.of(context).size.height / 2 +
                dy -
                4 +
                (dy > 0 ? offset : -offset),
            child: Opacity(
              opacity: (1 - progress) * 0.6,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.8 - progress * 0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class _AnimatedGradientBackground extends StatelessWidget {
  final Color primary;
  const _AnimatedGradientBackground({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            primary.withValues(alpha: 0.15),
            const Color(0xFF0A0A0F),
            const Color(0xFF050508),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class _AnimatedRings extends StatelessWidget {
  final Animation<double> animation;
  final Color primary;
  const _AnimatedRings({required this.animation, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Transform.scale(
            scale: animation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                ),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                ),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FuturisticLoader extends StatelessWidget {
  final Color primary;
  const _FuturisticLoader({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 2,
          child: LinearProgressIndicator(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(primary),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FuturisticDot(active: true, color: primary),
            const SizedBox(width: 8),
            _FuturisticDot(active: false, color: primary),
            const SizedBox(width: 8),
            _FuturisticDot(active: false, color: primary),
          ],
        ),
      ],
    );
  }
}

class _FuturisticDot extends StatelessWidget {
  final bool active;
  final Color color;
  const _FuturisticDot({required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: active ? 24 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? color : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}
