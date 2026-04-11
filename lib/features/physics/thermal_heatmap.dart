import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'thermal_state.dart';

class ThermalHeatmapWidget extends StatefulWidget {
  final ThermalState state;
  final Duration animationDuration;

  const ThermalHeatmapWidget({
    Key? key,
    required this.state,
    this.animationDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<ThermalHeatmapWidget> createState() => _ThermalHeatmapWidgetState();
}

class _ThermalHeatmapWidgetState extends State<ThermalHeatmapWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(140, 180),
          painter: VolumetricThermalPainter(
            state: widget.state,
            pulseValue: _pulseController.value,
          ),
        );
      },
    );
  }
}

class VolumetricThermalPainter extends CustomPainter {
  final ThermalState state;
  final double pulseValue;

  VolumetricThermalPainter({required this.state, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final eggPath = _getEggPath(size);

    // 1. Draw Shell Backdrop (Diffuse Shadow)
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(eggPath, shadowPaint);

    // 2. Draw Albumen (Egg White)
    // We use a radial gradient that starts from the center (yolk) to the shell
    final albumenPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          state.albumenColor.withOpacity(0.1),
          state.albumenColor,
        ],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(eggPath, albumenPaint);

    // 3. Draw Molecular Yolk (The Core)
    // The yolk is slightly off-center (lower) for scientific accuracy
    final yolkCenter = Offset(size.width / 2, size.height * 0.6);
    final yolkRadius = (size.width * 0.28) + (pulseValue * 2);

    final yolkPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          state.yolkColor,
          state.yolkColor.withOpacity(0.8),
          state.yolkColor.withOpacity(0.4),
        ],
        stops: const [0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: yolkCenter, radius: yolkRadius))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + (pulseValue * 2));

    canvas.drawCircle(yolkCenter, yolkRadius, yolkPaint);

    // 4. Draw Highlights (Glass-like effect)
    final highlightPath = Path()
      ..addOval(Rect.fromLTWH(size.width * 0.25, size.height * 0.15, size.width * 0.2, size.height * 0.1));
    
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(highlightPath, highlightPaint);

    // 5. Draw Shell Border
    final borderPaint = Paint()
      ..color = state.shellColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(eggPath, borderPaint);
  }

  Path _getEggPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Natural Ovoid (Egg) Path
    path.moveTo(w * 0.5, 0);
    
    // Right side (Narrower top, wider bottom)
    path.cubicTo(w * 0.85, 0, w, h * 0.3, w, h * 0.6);
    path.cubicTo(w, h * 0.9, w * 0.8, h, w * 0.5, h);

    // Left side
    path.cubicTo(w * 0.2, h, 0, h * 0.9, 0, h * 0.6);
    path.cubicTo(0, h * 0.3, w * 0.15, 0, w * 0.5, 0);

    return path;
  }

  @override
  bool shouldRepaint(covariant VolumetricThermalPainter oldDelegate) => 
      oldDelegate.state.threshold != state.threshold || 
      oldDelegate.pulseValue != pulseValue;
}
