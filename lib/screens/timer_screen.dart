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

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  late final TimerViewModel _vm;
  late final EggyMascotController _mascotCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _mascotCtrl = EggyMascotController();
    _vm = TimerViewModel(CountdownService());
    _vm.startTimer(widget.duration);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EggyMascotController>.value(
      value: _mascotCtrl,
      child: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          final steps = widget.recipe.getStepInstructions();
          final step  = steps[_stepIndex.clamp(0, steps.length - 1)];
          final res = EggyResponsive(context);

          return Scaffold(
            backgroundColor: EggyColors.warmWhite,
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

                          const SizedBox(height: 12),

                          SizedBox(
                            height: res.spClamped(300, max: 480),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Atmospheric Heat Glow
                                AnimatedBuilder(
                                  animation: _pulse,
                                  builder: (context, _) => Container(
                                    width: res.spClamped(300),
                                    height: res.spClamped(300),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: EggyColors.liquidGold.withValues(alpha: 0.15 * _pulse.value),
                                          blurRadius: 60,
                                          spreadRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                ProgressRing(
                                  progress: _vm.progress,
                                  size: res.spClamped(280, max: 420),
                                  strokeWidth: 6,
                                  center: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      _ScientificEggSchematic(
                                        progress: _vm.progress,
                                        targetYolk: widget.recipe.yolkOptions.first.hexColor, 
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: res.hp(50)),
                                          Text(_vm.formattedTime, 
                                            style: AppTheme.timerDisplay.copyWith(
                                              fontSize: 72,
                                              letterSpacing: -2,
                                              fontWeight: FontWeight.w200,
                                            )
                                          ),
                                          Text('INCUBATING', 
                                            style: AppTheme.caption.copyWith(
                                              letterSpacing: 3.0, 
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: EggyColors.onyx.withValues(alpha: 0.4),
                                            )
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

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
        backgroundColor: EggyColors.warmWhite,
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
            child: Text('Cancel', style: AppTheme.body.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );
  }
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
              (widget.isCaution ? Colors.orange : EggyColors.champagne)
                  .withValues(alpha: 0.03 + (_ctrl.value * (widget.isCaution ? 0.15 : 0.08))),
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
                       color: progress >= p.$1 ? EggyColors.champagne : EggyColors.onyx.withValues(alpha: 0.05),
                       borderRadius: BorderRadius.circular(1.5),
                     ),
                   ),
                   const SizedBox(height: 4),
                   if (active)
                     FittedBox(
                       child: Text(p.$2.toUpperCase(), 
                         style: AppTheme.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 9)
                       ),
                     ),
                ],
              ),
            );
          }).toList(),
        ),
        if (progress < 1.0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(
              phases.firstWhere((p) => progress < p.$1).$3,
              style: AppTheme.caption.copyWith(
                  fontStyle: FontStyle.italic, 
                  letterSpacing: 0.2,
                  color: EggyColors.softCharcoal.withValues(alpha: 0.7)
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _ScientificEggSchematic extends StatelessWidget {
  final double progress;
  final Color targetYolk;

  const _ScientificEggSchematic({required this.progress, required this.targetYolk});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(180, 200),
      painter: _ScientificSchematicPainter(progress: progress, targetYolk: targetYolk),
    );
  }
}

class _ScientificSchematicPainter extends CustomPainter {
  final double progress;
  final Color targetYolk;
  _ScientificSchematicPainter({required this.progress, required this.targetYolk});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final eggH = size.height * 0.85;
    final eggW = eggH * 0.82;

    // ── Glass Outline ──────────────────────────────────────────────────
    final shellPaint = Paint()
      ..color = EggyColors.softCharcoal.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: eggW, height: eggH), shellPaint);

    // ── Air Cell Expansion (Molecular Metric) ──────────────────────────
    // The air cell grows at the blunt end (bottom) as internal content contracts/heats
    final airCellHeight = eggH * (0.05 + (0.10 * progress));
    final airCellPath = Path()
      ..moveTo(cx - (eggW * 0.35), cy + (eggH * 0.42))
      ..quadraticBezierTo(cx, cy + (eggH * 0.42) - airCellHeight, cx + (eggW * 0.35), cy + (eggH * 0.42));
    
    canvas.drawPath(airCellPath, Paint()..color = Colors.white.withValues(alpha: 0.2)..style = PaintingStyle.fill);

    // ── Egg White (Coagulation) ────────────────────────────────────────
    final whitePaint = Paint()
      ..color = Color.lerp(
        Colors.white.withValues(alpha: 0.1),
        Colors.white.withValues(alpha: 0.95),
        progress
      )!;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: eggW - 4, height: eggH - 4), whitePaint);

    // ── Yolk (Vitellin Gelation) ───────────────────────────────────────
    final yolkPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFFFFCC33).withValues(alpha: 0.4),
        targetYolk,
        progress
      )!;
    
    final yolkRadius = (eggW * 0.28) - (progress * 2);
    canvas.drawCircle(Offset(cx, cy + (eggH * 0.05)), yolkRadius, yolkPaint);

    // ── Grid Schematic Overlay ─────────────────────────────────────────
    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.1)..strokeWidth = 0.5;
    for (int i = 1; i < 5; i++) {
      canvas.drawLine(Offset(cx - (eggW / 2), cy - (eggH / 2) + (eggH / 5 * i)), Offset(cx + (eggW / 2), cy - (eggH / 2) + (eggH / 5 * i)), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_ScientificSchematicPainter old) => old.progress != progress;
}
