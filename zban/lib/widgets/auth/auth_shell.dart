import 'dart:ui';
import 'package:flutter/material.dart';

class AmonShell extends StatelessWidget {
  final Widget child;
  const AmonShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          Positioned(
              top: -90,
              left: -80,
              child:
                  _Blob(color: cs.primary.withValues(alpha: 0.50), size: 280)),
          Positioned(
              top: 80,
              right: -70,
              child: _Blob(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.28),
                  size: 220)),
          Positioned(
              bottom: -110,
              right: -60,
              child: _Blob(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.22),
                  size: 300)),
          Positioned(
              bottom: -80,
              left: -50,
              child: _Blob(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.20),
                  size: 240)),
          // Blur layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox.shrink(),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Frosted-glass card
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0x12FFFFFF),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Gradient primary button (purple)
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, Color.lerp(cs.primary, Colors.black, 0.18)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.35),
              blurRadius: 20,
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
                    strokeWidth: 2, color: Colors.white),
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

/// Ghost/outlined button
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1FFFFFFF)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0x99FFFFFF),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

/// Dark text field with glass style
class DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  const DarkField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscure = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefixIcon, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}

/// Selectable pill chip
class AmonPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const AmonPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.22)
              : const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.60)
                : const Color(0x18FFFFFF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? const Color(0xFFA09AEF) : const Color(0x80FFFFFF),
          ),
        ),
      ),
    );
  }
}

/// Section label (small uppercase muted)
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          color: Color(0x66FFFFFF),
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Step icon + title + subtitle header used in signup wizard
class WizardStepHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const WizardStepHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
          ),
          child: Icon(icon, color: cs.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0x66FFFFFF)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tip / info box
class InfoBox extends StatelessWidget {
  final String text;
  const InfoBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0x80FFFFFF)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Internal ────────────────────────────────────────────────────────────────

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
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}
