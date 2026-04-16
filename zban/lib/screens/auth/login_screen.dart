import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth/auth_controller.dart';
import '../../app/network/api_errors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  late final AnimationController _entryCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await ref.read(authSessionProvider.notifier).login(
            email: _email.text.trim(),
            password: _password.text,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (!mounted) return;
      final failure = e is ApiFailure ? e : null;
      final msg =
          failure?.messageMn ?? 'Нэвтрэлт амжилтгүй. Дахин оролдоно уу ?';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isLoading = ref.watch(authSessionProvider).isLoading;
    final lastError = ref.watch(lastAuthErrorProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Animated background similar to WelcomeScreen
          _AnimatedLoginBg(primary: cs.primary),

          // Subtle floating blobs
          ..._buildBlobs(cs.primary, screenSize),

          // Blur effect overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: const SizedBox.shrink(),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: ScaleTransition(
                      scale: _scale,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            _GlassHeader(primary: cs.primary),
                            const SizedBox(height: 40),
                            _GlassCard(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (lastError != null) ...[
                                      _ErrorBanner(
                                        failure: lastError,
                                        onSignup: () => context.go('/signup'),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                    _FieldLabel('И-мэйл хаяг'),
                                    const SizedBox(height: 8),
                                    _GlassTextField(
                                      controller: _email,
                                      hint: 'hello@amon.mn',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) =>
                                          (v == null || !v.contains('@'))
                                              ? 'Зөв и-мэйл хаяг оруулна уу'
                                              : null,
                                    ),
                                    const SizedBox(height: 20),
                                    _FieldLabel('Нууц үг'),
                                    const SizedBox(height: 8),
                                    _GlassTextField(
                                      controller: _password,
                                      hint: '••••••••',
                                      prefixIcon: Icons.lock_outline,
                                      obscure: _obscure,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 18,
                                          color: Colors.white54,
                                        ),
                                        onPressed: () => setState(
                                            () => _obscure = !_obscure),
                                      ),
                                      validator: (v) => (v == null ||
                                              v.length < 6)
                                          ? 'Нууц үг хамгийн багадаа 6 тэмдэгт байх ёстой'
                                          : null,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          foregroundColor: cs.primary,
                                        ),
                                        child: Text(
                                          'Нууц үг мартсан уу?',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white
                                                  .withOpacity(0.6)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _LoginButton(
                                      loading: isLoading,
                                      onPressed: _submit,
                                      primary: cs.primary,
                                    ),
                                    const SizedBox(height: 28),
                                    _Divider(),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _GlassSocialButton(
                                            label: 'Google',
                                            icon: Icons.g_mobiledata_rounded,
                                            onPressed: () {},
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _GlassSocialButton(
                                            label: 'Apple',
                                            icon: Icons.apple_rounded,
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Шинэ хэрэглэгч үү?',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.go('/signup'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: cs.primary,
                                  ),
                                  child: Text(
                                    'Бүртгүүлэх',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _ThemeSelectorDots(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBlobs(Color primary, Size screenSize) {
    return [
      _LoginBlob(
        color: primary.withOpacity(0.2),
        size: 300,
        top: -120,
        left: -80,
        duration: 20,
      ),
      _LoginBlob(
        color: const Color(0xFF38BDF8).withOpacity(0.12),
        size: 250,
        top: screenSize.height * 0.3,
        right: -100,
        duration: 25,
      ),
      _LoginBlob(
        color: const Color(0xFF22C55E).withOpacity(0.08),
        size: 280,
        bottom: -80,
        right: -50,
        duration: 18,
      ),
      _LoginBlob(
        color: const Color(0xFFA855F7).withOpacity(0.1),
        size: 220,
        bottom: screenSize.height * 0.2,
        left: -60,
        duration: 22,
      ),
    ];
  }
}

// Animated Background
class _AnimatedLoginBg extends StatefulWidget {
  final Color primary;
  const _AnimatedLoginBg({required this.primary});

  @override
  State<_AnimatedLoginBg> createState() => _AnimatedLoginBgState();
}

class _AnimatedLoginBgState extends State<_AnimatedLoginBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(_animation.value * 0.2 - 0.1, 0),
              radius: 1.4,
              colors: [
                widget.primary.withOpacity(0.12),
                const Color(0xFF0A0A0F),
                const Color(0xFF050508),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// Animated Blob
class _LoginBlob extends StatefulWidget {
  final Color color;
  final double size;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final int duration;

  const _LoginBlob({
    required this.color,
    required this.size,
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.duration,
  });

  @override
  State<_LoginBlob> createState() => _LoginBlobState();
}

class _LoginBlobState extends State<_LoginBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotateAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0),
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Glassmorphic Header
class _GlassHeader extends StatelessWidget {
  final Color primary;
  const _GlassHeader({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(45),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Image.asset(
              'assets/branding/amon_logo.png',
              fit: BoxFit.contain,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.8),
              primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Тавтай морил',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'Нэвтрэх мэдээллээ оруулна уу ?',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// Glassmorphic Card
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }
}

// Glassmorphic TextField
class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _GlassTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscure = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
        ),
        prefixIcon: Icon(
          prefixIcon,
          size: 20,
          color: Colors.white.withOpacity(0.5),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}

// Animated Login Button
class _LoginButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onPressed;
  final Color primary;
  const _LoginButton({
    required this.loading,
    required this.onPressed,
    required this.primary,
  });

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(_ctrl);
    _glow = Tween<double>(begin: 0.0, end: 0.4).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (!widget.loading) widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.primary,
                  widget.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.primary.withOpacity(_glow.value),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Нэвтрэх',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Эсвэл',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}

// Glassmorphic Social Button
class _GlassSocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _GlassSocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final ApiFailure failure;
  final VoidCallback onSignup;
  const _ErrorBanner({required this.failure, required this.onSignup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF991B1B).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF991B1B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Color(0xFFF87171),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              failure.messageMn,
              style: const TextStyle(
                color: Color(0xFFFCA5A5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSelectorDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF6358DC),
      const Color(0xFF14B8A6),
      const Color(0xFFF43F5E),
      const Color(0xFFF59E0B),
      const Color(0xFF38BDF8),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors.map((color) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
