import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
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
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Animated background gradient
          _AnimatedRadialBg(primary: cs.primary),

          // Floating blobs with animation
          ..._buildAnimatedBlobs(cs.primary, screenSize),

          // Main blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: const SizedBox.shrink(),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 32),
                        child: Column(
                          children: [
                            const Spacer(flex: 2),
                            _buildHeroLogo(cs),
                            const SizedBox(height: 32),
                            _buildTitleText(),
                            const SizedBox(height: 12),
                            _buildSubtitleText(),
                            const SizedBox(height: 24),
                            _Dots(primary: cs.primary),
                            const Spacer(flex: 3),
                            _buildActionButtons(cs),
                            const SizedBox(height: 20),
                            _buildTermsText(),
                            const SizedBox(height: 20),
                            _ThemeSelectorDots(),
                            const Spacer(flex: 1),
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

  Widget _buildHeroLogo(ColorScheme cs) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.15),
            cs.primary.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Image.asset(
        'assets/branding/amon_hero.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitleText() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Colors.white,
          Colors.white.withValues(alpha: 0.8),
          const Color(0xFF38BDF8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: const Text(
        'AMON-д тавтай морил',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildSubtitleText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        'Өнөөдрийг удирд. Маргаашийг бүтээ.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.white.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: _AnimatedPillButton(
            label: 'Бүртгүүлэх',
            filled: true,
            primary: cs.primary,
            onTap: () => context.go('/signup'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _AnimatedPillButton(
            label: 'Нэвтрэх',
            filled: false,
            primary: cs.primary,
            onTap: () => context.go('/login'),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.security_outlined,
            size: 12, color: Colors.white.withValues(alpha: 0.3)),
        const SizedBox(width: 6),
        Text(
          'Үргэлжлүүлснээр та үйлчилгээний нөхцөлтэй танилцсан гэж үзнэ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.35),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAnimatedBlobs(Color primary, Size screenSize) {
    return [
      _AnimatedBlob(
        color: primary.withValues(alpha: 0.25),
        size: 350,
        top: -150,
        left: -100,
        duration: 20,
      ),
      _AnimatedBlob(
        color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
        size: 280,
        top: screenSize.height * 0.3,
        right: -120,
        duration: 25,
      ),
      _AnimatedBlob(
        color: const Color(0xFF22C55E).withValues(alpha: 0.12),
        size: 320,
        bottom: -100,
        right: -50,
        duration: 18,
      ),
      _AnimatedBlob(
        color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
        size: 260,
        bottom: screenSize.height * 0.2,
        left: -80,
        duration: 22,
      ),
      _AnimatedBlob(
        color: const Color(0xFFA855F7).withValues(alpha: 0.08),
        size: 200,
        top: screenSize.height * 0.6,
        right: screenSize.width * 0.2,
        duration: 30,
      ),
    ];
  }
}

class _AnimatedRadialBg extends StatefulWidget {
  final Color primary;
  const _AnimatedRadialBg({required this.primary});

  @override
  State<_AnimatedRadialBg> createState() => _AnimatedRadialBgState();
}

class _AnimatedRadialBgState extends State<_AnimatedRadialBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.4).animate(
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
              center: Alignment(_animation.value * 0.3 - 0.2, 0),
              radius: 1.5,
              colors: [
                widget.primary.withValues(alpha: 0.15),
                const Color(0xFF0A0A0F),
                const Color(0xFF050508),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedBlob extends StatefulWidget {
  final Color color;
  final double size;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final int duration;

  const _AnimatedBlob({
    required this.color,
    required this.size,
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.duration,
  });

  @override
  State<_AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<_AnimatedBlob>
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.1).animate(
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
                      widget.color.withValues(alpha: 0),
                    ],
                    stops: const [0.3, 1.0],
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

class _AnimatedPillButton extends StatefulWidget {
  final String label;
  final bool filled;
  final Color primary;
  final VoidCallback onTap;

  const _AnimatedPillButton({
    required this.label,
    required this.filled,
    required this.primary,
    required this.onTap,
  });

  @override
  State<_AnimatedPillButton> createState() => _AnimatedPillButtonState();
}

class _AnimatedPillButtonState extends State<_AnimatedPillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),

                // 🔥 FILLED BUTTON
                gradient: widget.filled
                    ? LinearGradient(
                        colors: [
                          widget.primary,
                          widget.primary.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,

                // 🌫 OUTLINE BUTTON BACKGROUND
                color: widget.filled ? null : widget.primary.withOpacity(0.06),

                border: Border.all(
                  color: widget.filled
                      ? Colors.transparent
                      : widget.primary.withOpacity(0.25),
                  width: 1.4,
                ),

                // ✨ SOFT GLOW
                boxShadow: widget.filled
                    ? [
                        BoxShadow(
                          color:
                              widget.primary.withOpacity(_glowAnimation.value),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 120),
                  style: TextStyle(
                    color: widget.filled ? Colors.white : widget.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                    letterSpacing: 0.4,
                  ),
                  child: Text(widget.label),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final Color primary;
  const _Dots({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: _AnimatedDot(
            active: index == 0,
            primary: primary,
            index: index,
          ),
        );
      }),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final bool active;
  final Color primary;
  final int index;
  const _AnimatedDot({
    required this.active,
    required this.primary,
    required this.index,
  });

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AnimatedDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            gradient: widget.active
                ? LinearGradient(
                    colors: [
                      widget.primary,
                      widget.primary.withValues(alpha: 0.6),
                    ],
                  )
                : null,
            color: widget.active ? null : const Color(0x22FFFFFF),
            borderRadius: BorderRadius.circular(99),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: widget.primary
                          .withValues(alpha: 0.5 + _controller.value * 0.3),
                      blurRadius: 10 + _controller.value * 5,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        );
      },
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
