import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'app_theme.dart';

/// Reusable glassmorphism container — the "floating card" of the anti-gravity UI.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double blur;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.blur = 16,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16); // Refined radius

    Widget card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

/// Wraps any widget in a floating sine-wave animation — the "anti-gravity" feel.
class AntiGravityWrapper extends StatefulWidget {
  final Widget child;
  final double amplitude;   // max y-drift in pixels
  final double speed;       // animation speed in pixels / second
  final Duration delay;

  const AntiGravityWrapper({
    super.key,
    required this.child,
    this.amplitude = 8.0,
    this.speed     = 6.0,
    this.delay     = Duration.zero,
  });

  @override
  State<AntiGravityWrapper> createState() => _AntiGravityWrapperState();
}

class _AntiGravityWrapperState extends State<AntiGravityWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    
    // Time-Dilation Math:
    // Duration = Total Distance (Amplitude * 4) / Speed (px/s)
    final double totalDistance = widget.amplitude * 4;
    final int durationMs = ((totalDistance / widget.speed) * 1000).toInt();

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat(reverse: true);
    
    _anim = Tween<double>(begin: -widget.amplitude, end: widget.amplitude)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    if (widget.delay != Duration.zero) {
      _ctrl.stop();
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Floating spring button with overshoot — the "weightless" tap feel.
class FloatingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const FloatingButton({
    super.key,
    required this.child,
    required this.onTap,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  State<FloatingButton> createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, c) => Transform.scale(scale: _scale.value, child: c),
        child: Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            color: widget.backgroundColor ?? EggyColors.onyx,
            boxShadow: [
              BoxShadow(
                color: (widget.backgroundColor ?? EggyColors.onyx).withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.8,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Circular progress ring for the incubation timer screen.
class ProgressRing extends StatelessWidget {
  final double progress;   // 0.0 → 1.0
  final double size;
  final double strokeWidth;
  final Color color;
  final Widget? center;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size        = 260,
    this.strokeWidth = 6, // Thinner ring
    this.color       = EggyColors.champagne,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress,
              color: color,
              strokeWidth: strokeWidth,
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color  color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    // Track
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    final sweepAngle = 2 * 3.14159265 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265 / 2, // start at top
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0.5),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
