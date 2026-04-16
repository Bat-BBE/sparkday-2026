import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/auth/auth_controller.dart';
import '../../app/network/api_errors.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/theme_controller.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _page = PageController();
  int _step = 0;
  static const _totalSteps = 7;

  late final AnimationController _entryCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  // Step 0
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  // Step 1
  String? _ageRange;
  String? _gender;

  // Step 2-3
  final Set<String> _income = {};
  final Set<String> _expense = {};
  final _customIncome = TextEditingController();
  final _customExpense = TextEditingController();
  final List<String> _customIncomeList = [];
  final List<String> _customExpenseList = [];

  // Step 4
  bool _hasLoan = false;
  bool _hasSavings = false;

  // Step 5
  XFile? _profile;

  static const _incomeOptions = [
    'Цалин',
    'Тэтгэвэр',
    'Бизнес',
    'Гэрээт ажил',
    'Урамшуулал',
    'Хүү/ноогдол',
    'Түрээс',
    'Бэлэг/тусламж',
    'Тэтгэлэг',
    'Бусад',
  ];
  static const _expenseOptions = [
    'Хоол хүнс',
    'Тээвэр',
    'Түрээс/ипотек',
    'Тог/ус/интернет',
    'Зээл/хүү',
    'Эрүүл мэнд',
    'Боловсрол',
    'Зугаа цэнгэл',
    'Хувцас',
    'Бусад',
  ];

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
    _entryCtrl.dispose();
    _page.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _customIncome.dispose();
    _customExpense.dispose();
    super.dispose();
  }

  Future<void> _go(int step) async {
    setState(() => _step = step);
    await _page.animateToPage(step,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic);
  }

  Future<void> _next() async {
    if (_step == 0 && !(_formKey.currentState?.validate() ?? false)) return;
    if (_step == 1 && (_ageRange == null || _gender == null)) {
      _toast('Нас, хүйсээ сонгоно уу.');
      return;
    }
    await _go((_step + 1).clamp(0, _totalSteps - 1));
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ));

  void _toggle(Set<String> set, String v) => setState(() {
        if (set.contains(v)) {
          set.remove(v);
        } else if (set.length < 10) {
          set.add(v);
        }
      });

  void _addCustom(TextEditingController c, List<String> list) {
    final v = c.text.trim();
    if (v.isEmpty) return;
    setState(() {
      list.add(v);
      c.clear();
    });
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 768, imageQuality: 80);
    if (!mounted || img == null) return;
    setState(() => _profile = img);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final theme = ref.read(themeControllerProvider);
    String? b64;
    if (_profile != null) b64 = base64Encode(await _profile!.readAsBytes());
    try {
      await ref.read(authSessionProvider.notifier).signup(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            ageRange: _ageRange,
            gender: _gender,
            hasLoan: _hasLoan,
            hasSavings: _hasSavings,
            profileImageBase64: b64,
            incomeSources: _income.toList(),
            expenseSources: _expense.toList(),
            customIncomeSources: _customIncomeList,
            customExpenseSources: _customExpenseList,
            theme: theme,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      final msg =
          e is ApiFailure ? e.messageMn : 'Бүртгэл үүсгэхэд алдаа гарлаа.';
      if (mounted) _toast(msg);
    }
  }

  String _stepTitle(int s) => switch (s) {
        0 => 'Бүртгэлийн мэдээлэл',
        1 => 'Нас, хүйс',
        2 => 'Орлогын эх үүсвэр',
        3 => 'Зарлагын эх үүсвэр',
        4 => 'Нэмэлт мэдээлэл',
        5 => 'Профайл зураг',
        _ => 'Өнгө & дизайн',
      };

  String _stepHint(int s) => switch (s) {
        0 => 'Хэдхэн мэдээлэл аваад эхэлье.',
        1 => 'Зөвлөмжийг илүү оновчтой болгоно.',
        2 => '10 хүртэл сонгоно. Дуртайгаа нэм.',
        3 => 'Зарлагаа ангилахад тусална.',
        4 => 'Таны зорилгод нийцүүлнэ.',
        5 => 'Дараа нь сольж болно.',
        _ => 'Өөрийн өнгөө сонго.',
      };

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authSessionProvider).isLoading;
    final cs = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Animated background
          _AnimatedSignupBg(primary: cs.primary),

          // Floating blobs
          ..._buildBlobs(cs.primary, screenSize),

          // Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
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
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _GlassBackButton(
                                onTap: () => _step == 0
                                    ? context.go('/login')
                                    : _go(_step - 1),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(22, 6, 22, 16),
                              child: Column(
                                children: [
                                  _GlassLogo(primary: cs.primary),
                                  const SizedBox(height: 16),
                                  _GlassHeaderText(),
                                  const SizedBox(height: 22),
                                  _WizardProgress(
                                    step: _step,
                                    total: _totalSteps,
                                    title: _stepTitle(_step),
                                    hint: _stepHint(_step),
                                    primary: cs.primary,
                                  ),
                                  const SizedBox(height: 14),
                                  Expanded(
                                    child: _GlassCard(
                                      child: PageView(
                                        controller: _page,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: [
                                          _StepBasic(
                                            formKey: _formKey,
                                            name: _name,
                                            email: _email,
                                            password: _password,
                                            confirm: _confirm,
                                            obscure: _obscure,
                                            onToggleObscure: () => setState(
                                                () => _obscure = !_obscure),
                                          ),
                                          _StepAgeGender(
                                            ageRange: _ageRange,
                                            gender: _gender,
                                            onAge: (v) =>
                                                setState(() => _ageRange = v),
                                            onGender: (v) =>
                                                setState(() => _gender = v),
                                          ),
                                          _StepSources(
                                            title: 'Орлогын эх үүсвэр',
                                            subtitle: '${_income.length}/10',
                                            options: _incomeOptions,
                                            selected: _income,
                                            onToggle: (v) =>
                                                _toggle(_income, v),
                                            customController: _customIncome,
                                            customHint: 'Өөр орлогын эх…',
                                            customItems: _customIncomeList,
                                            onAddCustom: () => _addCustom(
                                                _customIncome,
                                                _customIncomeList),
                                            onRemoveCustom: (i) => setState(
                                                () => _customIncomeList
                                                    .removeAt(i)),
                                          ),
                                          _StepSources(
                                            title: 'Зарлагын эх үүсвэр',
                                            subtitle: '${_expense.length}/10',
                                            options: _expenseOptions,
                                            selected: _expense,
                                            onToggle: (v) =>
                                                _toggle(_expense, v),
                                            customController: _customExpense,
                                            customHint: 'Өөр зарлагын эх…',
                                            customItems: _customExpenseList,
                                            onAddCustom: () => _addCustom(
                                                _customExpense,
                                                _customExpenseList),
                                            onRemoveCustom: (i) => setState(
                                                () => _customExpenseList
                                                    .removeAt(i)),
                                          ),
                                          _StepFlags(
                                            hasLoan: _hasLoan,
                                            hasSavings: _hasSavings,
                                            onLoan: (v) =>
                                                setState(() => _hasLoan = v),
                                            onSavings: (v) =>
                                                setState(() => _hasSavings = v),
                                          ),
                                          _StepPhoto(
                                            file: _profile,
                                            onPick: _pickImage,
                                            onClear: () =>
                                                setState(() => _profile = null),
                                          ),
                                          _StepTheme(
                                            current: ref
                                                .watch(themeControllerProvider),
                                            onSelect: (k) => ref
                                                .read(themeControllerProvider
                                                    .notifier)
                                                .setTheme(k),
                                            primary: cs.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _StepDots(
                                      current: _step,
                                      total: _totalSteps,
                                      primary: cs.primary),
                                  const SizedBox(height: 14),
                                  Row(children: [
                                    if (_step > 0) ...[
                                      Expanded(
                                        child: _GlassGhostButton(
                                          label: 'Буцах',
                                          onTap: isLoading
                                              ? null
                                              : () => _go(_step - 1),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      flex: 2,
                                      child: _GlassGradientButton(
                                        label: _step == _totalSteps - 1
                                            ? 'Дуусгах'
                                            : 'Дараах →',
                                        loading: isLoading,
                                        onPressed: _step == _totalSteps - 1
                                            ? _submit
                                            : _next,
                                        primary: cs.primary,
                                      ),
                                    ),
                                  ]),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Бүртгэлтэй юу?',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 13,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.go('/login'),
                                        child: Text(
                                          'Нэвтрэх',
                                          style: TextStyle(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _ThemeColorDots(),
                                ],
                              ),
                            ),
                          ),
                        ],
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
      _SignupBlob(
        color: primary.withOpacity(0.2),
        size: 320,
        top: -120,
        left: -80,
        duration: 20,
      ),
      _SignupBlob(
        color: const Color(0xFF38BDF8).withOpacity(0.12),
        size: 260,
        top: screenSize.height * 0.25,
        right: -100,
        duration: 25,
      ),
      _SignupBlob(
        color: const Color(0xFF22C55E).withOpacity(0.1),
        size: 300,
        bottom: -100,
        right: -60,
        duration: 18,
      ),
      _SignupBlob(
        color: const Color(0xFFA855F7).withOpacity(0.12),
        size: 240,
        bottom: screenSize.height * 0.15,
        left: -70,
        duration: 22,
      ),
    ];
  }
}

// Animated Background
class _AnimatedSignupBg extends StatefulWidget {
  final Color primary;
  const _AnimatedSignupBg({required this.primary});

  @override
  State<_AnimatedSignupBg> createState() => _AnimatedSignupBgState();
}

class _AnimatedSignupBgState extends State<_AnimatedSignupBg>
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

class _SignupBlob extends StatefulWidget {
  final Color color;
  final double size;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final int duration;

  const _SignupBlob({
    required this.color,
    required this.size,
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.duration,
  });

  @override
  State<_SignupBlob> createState() => _SignupBlobState();
}

class _SignupBlobState extends State<_SignupBlob>
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

class _GlassLogo extends StatelessWidget {
  final Color primary;
  const _GlassLogo({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
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
          ),
        ),
      ),
    );
  }
}

class _GlassHeaderText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.8),
              cs.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Бүртгүүлэх',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
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
          child: const Text(
            'Хэдхэн алхам — дараа нь санхүүгээ ухаалгаар хяна.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0x99FFFFFF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _WizardProgress extends StatelessWidget {
  final int step, total;
  final String title, hint;
  final Color primary;
  const _WizardProgress({
    required this.step,
    required this.total,
    required this.title,
    required this.hint,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (step + 1) / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Text(
              '${step + 1}/$total — $title',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: primary.withOpacity(0.3)),
            ),
            child: Text(
              '${(pct * 100).round()}%',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Text(
          hint,
          style: const TextStyle(fontSize: 12, color: Color(0x80FFFFFF)),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(primary),
          ),
        ),
      ],
    );
  }
}

class _StepDots extends StatelessWidget {
  final int current, total;
  final Color primary;
  const _StepDots(
      {required this.current, required this.total, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? primary : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

// Glass Back Button
class _GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GlassBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xCCFFFFFF),
          size: 20,
        ),
      ),
    );
  }
}

// Glass Gradient Button
class _GlassGradientButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final Color primary;
  const _GlassGradientButton({
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
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}

// Glass Ghost Button
class _GlassGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _GlassGhostButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xCCFFFFFF),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// Step Basic (with glass fields)
class _StepBasic extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name, email, password, confirm;
  final bool obscure;
  final VoidCallback onToggleObscure;
  const _StepBasic({
    required this.formKey,
    required this.name,
    required this.email,
    required this.password,
    required this.confirm,
    required this.obscure,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ✅ ListView -> SingleChildScrollView
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GlassMiniHero(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Эхэлцгээе',
              subtitle: 'Нэр, и-мэйл, нууц үгээ оруулна уу.',
              primary: cs.primary,
            ),
            const SizedBox(height: 20),
            _GlassTextField(
              controller: name,
              hint: 'Таны нэр',
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Нэрээ зөв оруулна уу'
                  : null,
            ),
            const SizedBox(height: 12),
            _GlassTextField(
              controller: email,
              hint: 'И-мэйл хаяг',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Зөв и-мэйл оруулна уу'
                  : null,
            ),
            const SizedBox(height: 12),
            _GlassTextField(
              controller: password,
              hint: 'Нууц үг',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: obscure,
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 18,
                  color: Colors.white54,
                ),
                onPressed: onToggleObscure,
              ),
              validator: (v) => (v == null || v.length < 6)
                  ? 'Нууц үг хамгийн багадаа 6 тэмдэгт'
                  : null,
            ),
            const SizedBox(height: 12),
            _GlassTextField(
              controller: confirm,
              hint: 'Нууц үг давтах',
              prefixIcon: Icons.lock_reset_rounded,
              obscure: obscure,
              validator: (v) =>
                  (v != password.text) ? 'Нууц үг таарахгүй байна' : null,
            ),
            const SizedBox(height: 12),
            _GlassInfoBox(
              text: 'Нууц үг хамгийн багадаа 6 тэмдэгт байх ёстой.',
              primary: cs.primary,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StepAgeGender extends StatelessWidget {
  final String? ageRange, gender;
  final void Function(String) onAge, onGender;
  const _StepAgeGender({
    required this.ageRange,
    required this.gender,
    required this.onAge,
    required this.onGender,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlassMiniHero(
            icon: Icons.badge_outlined,
            title: 'Таны тухай',
            subtitle: 'Санал болгох зөвлөмжийг илүү оновчтой болгоно.',
            primary: cs.primary,
          ),
          const SizedBox(height: 20),
          const _GlassSectionLabel('Насны бүлэг'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final a in ['13-17', '18-24', '25-34', '35-44', '45+'])
              _GlassPill(
                label: a,
                selected: ageRange == a,
                onTap: () => onAge(a),
                primary: cs.primary,
              ),
          ]),
          const SizedBox(height: 16),
          const _GlassSectionLabel('Хүйс'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _GlassPill(
              label: 'Эр',
              selected: gender == 'male',
              onTap: () => onGender('male'),
              primary: cs.primary,
            ),
            _GlassPill(
              label: 'Эм',
              selected: gender == 'female',
              onTap: () => onGender('female'),
              primary: cs.primary,
            ),
            _GlassPill(
              label: 'Нууц',
              selected: gender == 'private',
              onTap: () => onGender('private'),
              primary: cs.primary,
            ),
          ]),
          const SizedBox(height: 16),
          _GlassInfoBox(
            text:
                'Энэ мэдээллийг зөвхөн танд тохирсон зөвлөмж өгөхөд ашиглана.',
            primary: cs.primary,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StepSources extends StatelessWidget {
  final String title, subtitle;
  final List<String> options;
  final Set<String> selected;
  final void Function(String) onToggle;
  final TextEditingController customController;
  final String customHint;
  final List<String> customItems;
  final VoidCallback onAddCustom;
  final void Function(int) onRemoveCustom;
  const _StepSources({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.customController,
    required this.customHint,
    required this.customItems,
    required this.onAddCustom,
    required this.onRemoveCustom,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0x80FFFFFF)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ Wrap options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final opt in options)
                _GlassPill(
                  label: opt,
                  selected: selected.contains(opt),
                  onTap: () => onToggle(opt),
                  primary: cs.primary,
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Custom input row
          Row(
            children: [
              Expanded(
                child: _GlassTextField(
                  controller: customController,
                  hint: customHint,
                  prefixIcon: Icons.add_rounded,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: _GlassGradientButton(
                  label: 'Нэмэх',
                  loading: false,
                  onPressed: onAddCustom,
                  primary: cs.primary,
                ),
              ),
            ],
          ),

          // Custom items
          if (customItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < customItems.length; i++)
                  _GlassChip(
                    label: customItems[i],
                    onRemove: () => onRemoveCustom(i),
                    primary: cs.primary,
                  ),
              ],
            ),
          ],

          const SizedBox(height: 20), // Bottom padding
        ],
      ),
    );
  }
}

class _StepFlags extends StatelessWidget {
  final bool hasLoan, hasSavings;
  final void Function(bool) onLoan, onSavings;
  const _StepFlags({
    required this.hasLoan,
    required this.hasSavings,
    required this.onLoan,
    required this.onSavings,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlassMiniHero(
            icon: Icons.tune_rounded,
            title: 'Нэмэлт тохиргоо',
            subtitle: 'Хүсвэл дараа нь өөрчилж болно.',
            primary: cs.primary,
          ),
          const SizedBox(height: 20),
          _GlassSwitchTile(
            value: hasLoan,
            onChanged: onLoan,
            title: 'Зээлтэй эсэх',
            subtitle: 'Тийм бол төлөвлөлт илүү оновчтой болно.',
            primary: cs.primary,
          ),
          const SizedBox(height: 8),
          _GlassSwitchTile(
            value: hasSavings,
            onChanged: onSavings,
            title: 'Хуримтлалтай эсэх',
            subtitle: 'Зорилго, дүрэм санал болгоно.',
            primary: cs.primary,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StepPhoto extends StatelessWidget {
  final XFile? file;
  final VoidCallback onPick, onClear;
  const _StepPhoto({
    required this.file,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlassMiniHero(
            icon: Icons.photo_camera_rounded,
            title: 'Профайл зураг',
            subtitle: 'Зураг нэмбэл илүү хувийн мэдрэмжтэй.',
            primary: cs.primary,
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    cs.primary.withOpacity(0.2),
                    cs.primary.withOpacity(0.08),
                  ],
                ),
                border: Border.all(
                  color: cs.primary.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_rounded,
                size: 52,
                color: cs.primary.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (file != null)
            Center(
              child: Text(
                'Сонгосон: ${file!.name}',
                style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12),
              ),
            ),
          const SizedBox(height: 20),
          _GlassGradientButton(
            label: 'Зураг сонгох',
            loading: false,
            onPressed: onPick,
            primary: cs.primary,
          ),
          if (file != null) ...[
            const SizedBox(height: 10),
            _GlassGhostButton(label: 'Арилгах', onTap: onClear),
          ],
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Зураг нэмэхийг алгасаж болно.',
              style:
                  TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.3)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StepTheme extends StatelessWidget {
  final AppThemeKey current;
  final void Function(AppThemeKey) onSelect;
  final Color primary;
  const _StepTheme({
    required this.current,
    required this.onSelect,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlassMiniHero(
            icon: Icons.palette_rounded,
            title: 'Өнгөө сонго',
            subtitle: 'AMON-оо өөрийнхөөрөө болго.',
            primary: primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Апп-ынхаа үндсэн өнгийг сонгоно уу.',
            style: TextStyle(fontSize: 13, color: Color(0x80FFFFFF)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final k in AppThemeKey.values)
                GestureDetector(
                  onTap: () => onSelect(k),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppThemes.seed(k),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: k == current ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemes.seed(k).withOpacity(0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: k == current
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _GlassInfoBox(
            text: 'Дараа нь Home дээр cashflow-ийн хэсгүүдээ үргэлжлүүлнэ.',
            primary: primary,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

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
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        prefixIcon:
            Icon(prefixIcon, size: 20, color: Colors.white.withOpacity(0.5)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}

class _GlassPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;

  const _GlassPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [primary.withOpacity(0.2), primary.withOpacity(0.1)],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? primary.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? primary : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  final Color primary;

  const _GlassChip({
    required this.label,
    required this.onRemove,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(0.15),
            primary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassSwitchTile extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;
  final String title, subtitle;
  final Color primary;

  const _GlassSwitchTile({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style:
                      const TextStyle(color: Color(0x80FFFFFF), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primary,
          ),
        ],
      ),
    );
  }
}

class _GlassMiniHero extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color primary;

  const _GlassMiniHero({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.2),
                primary.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primary.withOpacity(0.3)),
          ),
          child: Icon(icon, color: primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0x80FFFFFF)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassInfoBox extends StatelessWidget {
  final String text;
  final Color primary;

  const _GlassInfoBox({
    required this.text,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(0.1),
            primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xCCFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassSectionLabel extends StatelessWidget {
  final String text;
  const _GlassSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          color: Color(0x80FFFFFF),
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ThemeColorDots extends StatelessWidget {
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
                color: color.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
