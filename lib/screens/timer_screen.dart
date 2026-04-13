import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/interfaces/i_egg_recipe.dart';
import '../core/services/notification_service.dart';
import '../features/timer/timer_view_model.dart';
import '../shared/ui/app_theme.dart';
import '../shared/ui/widgets.dart';
import '../shared/responsive_service.dart';
import 'hatch_screen.dart';
import 'package:provider/provider.dart';
import '../features/mascot/eggy_mascot_controller.dart';
import '../features/mascot/mascot_view.dart';

/// Screen 4 — "The Incubation" — Active timer with pulsing ring + Eggy.
///
/// [returnToStepIndex] — when > -1, timer pops back to PrepGuideScreen at this
/// index instead of pushing to HatchScreen. Used for the Bungee flow.
class TimerScreen extends StatefulWidget {
  final IEggRecipe recipe;
  final Duration duration;
  final int returnToStepIndex;

  const TimerScreen({
    super.key,
    required this.recipe,
    required this.duration,
    this.returnToStepIndex = -1,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late final TimerViewModel _vm;
  late final EggyMascotController _mascotCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  
  late AnimationController _ritualCtrl;
  late Animation<double> _ritualRotation;
  bool _isRitualActive = true;
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _mascotCtrl = EggyMascotController();
    _vm = TimerViewModel(CountdownService());
    _vm.addListener(_onTimerUpdate);
    
    // Sync the Timer ViewModel to the Mascot Controller
    _vm.addListener(() {
      _mascotCtrl.updateProgress(_vm.progress);
    });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ── Phase 28: The Mechanical Ritual ──────────────────────────────
    // 1. Initial Pause (0.5s) showing '0'
    // 2. Clockwise Windup (1.5s) reaching target time
    // 3. Mission Start (Countdown)
    _ritualCtrl = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 2000)
    );
    
    _ritualRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ritualCtrl, curve: Curves.easeInOutQuart)
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _ritualCtrl.forward().then((_) {
          if (mounted) {
            setState(() => _isRitualActive = false);
            _vm.startTimer(widget.duration);
          }
        });
      }
    });
  }

  void _onTimerUpdate() {
    if (!_vm.isComplete || !mounted) return;

    // Fire timer-done notification
    EggyNotificationService().safeInit().then((_) {
      EggyNotificationService().showTimerComplete(widget.recipe.title);
    });

    if (widget.returnToStepIndex >= 0) {
      // Bungee: pop back to PrepGuideScreen — it will advance to returnToStepIndex
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => HatchScreen(recipe: widget.recipe),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_onTimerUpdate);
    _vm.dispose();
    _mascotCtrl.dispose();
    _pulseCtrl.dispose();
    _ritualCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EggyMascotController>.value(
      value: _mascotCtrl,
      child: ListenableBuilder(
        listenable: Listenable.merge([_vm, _ritualCtrl]),
        builder: (context, _) {
          final steps = widget.recipe.getStepInstructions();
          final step  = steps[_stepIndex.clamp(0, steps.length - 1)];
          final res = EggyResponsive(context);

          // Digital Time calculation for the ritual
          String ritualTime;
          if (_isRitualActive) {
            final ms = (widget.duration.inMilliseconds * _ritualRotation.value).toInt();
            final m  = (ms ~/ 60000).toString().padLeft(2, '0');
            final s  = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
            ritualTime = '$m:$s';
          } else {
            ritualTime = _vm.formattedTime;
          }

          return Scaffold(
            backgroundColor: EggyColors.alabaster,
            body: Stack(
              children: [
                // Warm heat-blur background with breathing animation
                _HeatBackground(
                  isCaution: _vm.progress > 0.8 && (widget.recipe.yolkOptions.first.label == 'Firm' || widget.recipe.yolkOptions.first.label == 'Soft Set'),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height - 
                          MediaQuery.paddingOf(context).top - 
                          MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: EggyColors.softCharcoal),
                                  onPressed: () => _showCancelDialog(),
                                ),
                                const Spacer(),
                                Text(
                                  widget.recipe.title.toUpperCase(), 
                                  style: AppTheme.caption.copyWith(
                                    letterSpacing: 2.5, 
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    color: EggyColors.onyx.withValues(alpha: 0.6),
                                  )
                                ),
                                const Spacer(),
                                const SizedBox(width: 48),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            height: res.spClamped(320, max: 480),
                            child: _ClassicMechanicalTimer(
                              key: const ValueKey('mechanical_ritual_timer'),
                              progress: _vm.progress,
                              ritualProgress: _ritualRotation.value,
                              isRitual: _isRitualActive,
                              duration: widget.duration,
                              formattedTime: ritualTime,
                            ),
                          ),
                          const SizedBox(height: 100),

                          // Protein Phase Timeline (Scientific Milestones)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _ProteinPhaseTimeline(progress: _vm.progress),
                          ),

                          const SizedBox(height: 32),

                          // Step instruction badge
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'COOKING STEP ${(_stepIndex + 1).toString().padLeft(2, '0')}',
                                    style: AppTheme.caption.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9,
                                      letterSpacing: 2.0,
                                      color: EggyColors.onyx.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    step.instruction,
                                    style: AppTheme.body.copyWith(
                                      height: 1.5, 
                                      fontSize: 16,
                                      color: EggyColors.onyx.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                              
                          if (steps.length > 1) ...[
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_stepIndex > 0)
                                      TextButton.icon(
                                        onPressed: () => setState(() => _stepIndex--),
                                        icon: const Icon(Icons.arrow_back_rounded, size: 14),
                                        label: Text('Prev', style: AppTheme.caption),
                                      ),
                                    const SizedBox(width: 12),
                                    if (_stepIndex < steps.length - 1)
                                      TextButton.icon(
                                        onPressed: () => setState(() => _stepIndex++),
                                        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                                        label: Text('Next', style: AppTheme.caption),
                                        iconAlignment: IconAlignment.end,
                                      ),
                                  ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Pause / Resume
                          Padding(
                            padding: EdgeInsets.only(bottom: res.hp(40)),
                            child: FloatingButton(
                              onTap: () => _vm.togglePause(),
                              backgroundColor: _vm.isPaused
                                  ? EggyColors.champagne
                                  : EggyColors.onyx,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _vm.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                    size: 20,
                                    color: _vm.isPaused ? EggyColors.onyx : Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _vm.isPaused ? 'RESUME TIMER' : 'PAUSE INCUBATION',
                                    style: AppTheme.caption.copyWith(
                                      color: _vm.isPaused ? EggyColors.onyx : Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: EggyColors.alabaster,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Cancel Timer?', style: AppTheme.title),
        content: Text('Eggy will stop watching your egg',
            style: AppTheme.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Keep Going', style: AppTheme.body)),
          TextButton(
            onPressed: () {
              _vm.cancel();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Cancel', style: AppTheme.body.copyWith(color: EggyColors.slate)),
          ),
        ],
      ),
    );
  }
}

class _ClassicMechanicalTimer extends StatelessWidget {
  final double progress;
  final double ritualProgress;
  final bool isRitual;
  final Duration duration;
  final String formattedTime;

  const _ClassicMechanicalTimer({
    super.key,
    required this.progress,
    required this.ritualProgress,
    required this.isRitual,
    required this.duration,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    final res = EggyResponsive(context);
    final size = res.spClamped(280, max: 380);
    
    // ── Strict Clockwise Logic ───────────────────────────────────────
    final double targetMinutes = duration.inSeconds / 60.0;
    
    double rotationAngle;
    if (isRitual) {
      // Phase 1: Ritual Wind-Up (0 -> Target)
      // Rotates Clockwise from 0 to reach the target minutes.
      rotationAngle = (targetMinutes * ritualProgress / 60.0) * 2 * math.pi;
    } else {
      // Phase 2: Mission Countdown (Target -> 0)
      // Continues moving Clockwise from the target back to 0.
      double startAngle = (targetMinutes / 60.0) * 2 * math.pi;
      rotationAngle = startAngle + (progress * (2 * math.pi - startAngle));
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ── The Bottom Shell (Stationary with Fixed Pointer) ───────────
          Positioned(
            bottom: size * 0.05,
            child: Container(
              width: size * 0.9,
              height: size * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(size * 0.5)),
                gradient: RadialGradient(
                  center: const Alignment(0, 0.4),
                  radius: 1.0,
                  colors: [
                    EggyColors.white,
                    EggyColors.alabaster,
                    EggyColors.vibrantYolk.withValues(alpha: 0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: EggyColors.onyx.withValues(alpha: 0.12),
                    blurRadius: 35,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // High-Contrast Red Delta (▲) Pointer - AT 0 POSITION
                  Positioned(
                    top: 6,
                    child: CustomPaint(
                      size: const Size(14, 10),
                      painter: _DeltaPointerPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── The Top Shell (Rotating with Cylindrical Projection) ───────
          Positioned(
            top: size * 0.1,
            child: Container(
              width: size * 0.9,
              height: size * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(size * 0.45)),
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.4),
                  radius: 1.2,
                  colors: [
                    EggyColors.white,
                    EggyColors.alabaster,
                    EggyColors.vibrantYolk.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(size * 0.45)),
                child: CustomPaint(
                  painter: _CylindricalDialPainter(
                    rotation: rotationAngle,
                    color: EggyColors.onyx,
                  ),
                ),
              ),
            ),
          ),

          // ── Real-World Seam Depth ──────────────────────────────────────
          Positioned(
            top: size * 0.54,
            child: Container(
              width: size * 0.905,
              height: 1.5,
              decoration: BoxDecoration(
                color: EggyColors.onyx.withValues(alpha: 0.2),
                boxShadow: [
                  BoxShadow(
                    color: EggyColors.onyx.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // ── Digital Feedback (Subtle Lab Readout) ──────────────────────
          Positioned(
            bottom: -55,
            child: Column(
              children: [
                Text(
                  formattedTime,
                  style: AppTheme.timerDisplay.copyWith(
                    fontSize: 44,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -1.5,
                    color: EggyColors.onyx,
                  ),
                ),
                Text(
                  'INCUBATING',
                  style: AppTheme.caption.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.0,
                    color: EggyColors.vibrantYolk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = EggyColors.vibrantYolk // High-Integrity Pointer
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter old) => false;
}

/// ── High-Fidelity Cylindrical Dial Painter ────────────────────────────
class _CylindricalDialPainter extends CustomPainter {
  final double rotation;
  final Color color;

  _CylindricalDialPainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final centerX = size.width / 2;
    final centerY = size.height;
    final radiusX = size.width / 2;

    for (int i = 0; i < 60; i++) {
        // baseAngle: Invert i so that rotating clockwise counts DOWN
        // i=0 is at 0. i=1 is at -1/60 * 2pi.
        final double baseAngle = -(i / 60) * 2 * math.pi;
        
        // Final projected angle
        final double projectedAngle = baseAngle + rotation;

        final double z = math.cos(projectedAngle);
        if (z < -0.1) continue;

        final double x = centerX + (radiusX * math.sin(projectedAngle));
        
        final bool isMajor = i % 5 == 0;
        final double alpha = (z + 0.1).clamp(0.0, 1.0);
        final double thicknessMultiplier = (z + 0.5).clamp(0.4, 1.0);

        final paint = Paint()
          ..color = color.withValues(alpha: isMajor ? alpha : alpha * 0.4)
          ..strokeWidth = (isMajor ? 2.5 : 1.0) * thicknessMultiplier
          ..strokeCap = StrokeCap.round;

        final double markLen = isMajor ? 20.0 : 10.0;
        canvas.drawLine(
          Offset(x, centerY - 6),
          Offset(x, centerY - 6 - markLen),
          paint,
        );

        if (isMajor) {
          textPainter.text = TextSpan(
            text: '$i',
            style: TextStyle(
              color: color.withValues(alpha: alpha),
              fontSize: 14 * thicknessMultiplier,
              fontWeight: FontWeight.w900,
              fontFamily: 'Inter', // Secondary Brand Font
              letterSpacing: -0.5,
            ),
          );
          textPainter.layout();
          final textOffset = Offset(
            x - (textPainter.width / 2),
            centerY - 18 - markLen - (textPainter.height / 2),
          );
          textPainter.paint(canvas, textOffset);
        }
    }
  }

  @override
  bool shouldRepaint(_CylindricalDialPainter old) => old.rotation != rotation;
}

class _HeatBackground extends StatefulWidget {
  final bool isCaution;
  const _HeatBackground({this.isCaution = false});

  @override
  State<_HeatBackground> createState() => _HeatBackgroundState();
}

class _HeatBackgroundState extends State<_HeatBackground> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1 + (_ctrl.value * (widget.isCaution ? 0.6 : 0.4)),
            colors: [
              EggyColors.vibrantYolk
                  .withValues(alpha: 0.05 + (_ctrl.value * (widget.isCaution ? 0.15 : 0.08))),
              EggyColors.alabaster,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProteinPhaseTimeline extends StatelessWidget {
  final double progress;
  const _ProteinPhaseTimeline({required this.progress});

  @override
  Widget build(BuildContext context) {
    final phases = [
      (0.25, "Denaturation", "Protein hydrogen bonds unfolding"),
      (0.50, "Lattice Formation", "Albumen (Ove-mucin) structure setting"),
      (0.75, "Vitellin Gelation", "Yolk lipids forming stable gel matrix"),
      (1.00, "Gel Stabilization", "Final matrix S-Ovalbumin consolidation"),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: phases.map((p) {
            final active = progress <= p.$1 && (progress > (phases.indexWhere((e) => e == p) > 0 ? phases[phases.indexWhere((e) => e == p) - 1].$1 : 0.0));
            return Expanded(
              child: Column(
                children: [
                   Container(
                     height: 3,
                     margin: const EdgeInsets.symmetric(horizontal: 2),
                     decoration: BoxDecoration(
                       color: progress >= p.$1 ? EggyColors.vibrantYolk : EggyColors.onyx.withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(1.5),
                     ),
                   ),
                   const SizedBox(height: 8),
                   if (active)
                     FittedBox(
                       child: Text(p.$2.toUpperCase(), 
                         style: AppTheme.caption.copyWith(
                           fontWeight: FontWeight.w900, 
                           fontSize: 8,
                           letterSpacing: 1.0,
                           color: EggyColors.onyx,
                         )
                       ),
                     ),
                ],
               ),
            );
          }).toList(),
        ),
        if (progress < 1.0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              phases.firstWhere((p) => progress < p.$1).$3.toUpperCase(),
              style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 9,
                  color: EggyColors.onyx.withValues(alpha: 0.5)
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
