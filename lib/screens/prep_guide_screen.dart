import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../core/interfaces/i_egg_recipe.dart';
import '../core/services/notification_service.dart';
import '../shared/ui/app_theme.dart';
import '../shared/ui/widgets.dart';
import '../shared/responsive_service.dart';
import '../shared/ui/recipe_step_media_view.dart';
import '../core/models/recipe_models.dart';
import '../features/mascot/mascot_view.dart';
import 'timer_screen.dart';
import 'hatch_screen.dart';

/// PrepGuideScreen — "The Mise en Place"
///
/// Bungee Navigation Flow:
///   1. User steps through prep steps (Next →)
///   2. On a [isCookingStep], button label becomes "Start Timer ⏱"
///   3. TimerScreen is pushed. When the timer ends, it pops back here at [startIndex+1].
///   4. User completes remaining post-cooking steps.
///   5. On the final step, the OS "Kitchen Complete" notification fires.
class PrepGuideScreen extends StatefulWidget {
  final IEggRecipe recipe;
  final Duration? cookingTime;
  final int startIndex; // Used when returning from TimerScreen

  const PrepGuideScreen({
    super.key,
    required this.recipe,
    this.cookingTime,
    this.startIndex = 0,
  });

  @override
  State<PrepGuideScreen> createState() => _PrepGuideScreenState();
}

class _PrepGuideScreenState extends State<PrepGuideScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextStep(List steps) async {
    final step = steps[_currentIndex];

    if (step.isCookingStep && (widget.cookingTime != null || step.customDuration != null)) {
      // ── Bungee: Go to timer, return here at the next step ──────────────────
      final timerDuration = step.customDuration ?? widget.cookingTime!;
      
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => TimerScreen(
            recipe: widget.recipe,
            duration: timerDuration,
            returnToStepIndex: _currentIndex + 1,
          ),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );

      // TimerScreen popped back — advance to next step
      if (!mounted) return;
      final nextIdx = _currentIndex + 1;
      if (nextIdx < steps.length) {
        setState(() => _currentIndex = nextIdx);
        _pageController.animateToPage(
          nextIdx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
      return;
    }

    if (_currentIndex < steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // ── All steps done — fire "Kitchen Complete" notification ──────────────
      await EggyNotificationService().safeInit();
      await EggyNotificationService().showAllDone(widget.recipe.title);

      if (!mounted) return;
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

  void _prevStep() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.recipe.getStepInstructions();
    final currentStep = steps[_currentIndex.clamp(0, steps.length - 1)];
    final isLast = _currentIndex == steps.length - 1;
    final res = EggyResponsive(context);

    // Determine CTA label
    String ctaLabel;
    if (currentStep.isCookingStep && widget.cookingTime != null) {
      ctaLabel = 'Start Timer';
    } else if (isLast) {
      ctaLabel = 'All Done';
    } else {
      ctaLabel = 'Next';
    }

    return Scaffold(
      backgroundColor: EggyColors.warmWhite,
      body: Stack(
        children: [
          _HeatPulseBackground(progress: _currentIndex / (steps.length - 1)),
          
          // ── Technical HUD Overlay (Grid) ──────────────────────────────────
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _HudGridPainter()),
            ),
          ),

          // ── Professor Tip Overlay (Sliding from Corner) ─────────────────────────
          _ProfessorTipOverlay(
            currentStepIndex: _currentIndex,
            tips: widget.recipe.proTips,
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Mission Header ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      _HudIconButton(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            'CULINARY MISSION',
                            style: AppTheme.caption.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                              fontSize: 9,
                              color: EggyColors.onyx.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.recipe.title.toUpperCase(),
                            style: AppTheme.headline.copyWith(
                              fontSize: 14,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                // ── Segmented Mission Track (Progress Indicator) ─────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: Row(
                    children: List.generate(steps.length, (index) {
                      final isActive = index == _currentIndex;
                      final isDone = index < _currentIndex;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutQuart,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: isActive ? 4 : 2,
                          decoration: BoxDecoration(
                            color: isDone 
                                ? EggyColors.onyx 
                                : (isActive ? EggyColors.vibrantYolk : EggyColors.onyx.withValues(alpha: 0.08)),
                            borderRadius: BorderRadius.circular(1),
                            boxShadow: isActive ? [
                              BoxShadow(
                                color: EggyColors.vibrantYolk.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ] : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Main Step View (Mission Focus Card) ──────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (idx) => setState(() => _currentIndex = idx),
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      return Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Oversized Step Number (Watermark style)
                                Positioned(
                                  top: 0, right: 0,
                                  child: Text(
                                    (index + 1).toString().padLeft(2, '0'),
                                    style: AppTheme.display.copyWith(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w900,
                                      color: EggyColors.onyx.withValues(alpha: 0.03),
                                    ),
                                  ),
                                ),
                                RecipeStepMediaView(
                                  instruction: step.instruction,
                                  actionCommand: step.actionCommand,
                                  iconType: step.iconType,
                                  isCookingStep: step.isCookingStep,
                                  context: step.context,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Technical Controls ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, res.hp(40)),
                  child: Row(
                    children: [
                      if (_currentIndex > 0)
                        _HudTextButton(
                          label: 'ABORT',
                          onTap: _prevStep,
                        ),
                      const Spacer(),
                      _HudActionButton(
                        label: ctaLabel,
                        isStart: currentStep.isCookingStep,
                        isFinish: isLast,
                        onTap: () => _nextStep(steps),
                      ),
                    ],
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

class _HudIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HudIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: EggyColors.onyx.withValues(alpha: 0.05)),
        ),
        child: Icon(icon, size: 20, color: EggyColors.onyx),
      ),
    );
  }
}

class _HudTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _HudTextButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 2.0,
          color: EggyColors.onyx.withValues(alpha: 0.4),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _HudActionButton extends StatelessWidget {
  final String label;
  final bool isStart;
  final bool isFinish;
  final VoidCallback onTap;

  const _HudActionButton({
    required this.label,
    required this.isStart,
    required this.isFinish,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isStart 
        ? EggyColors.vibrantYolk 
        : (isFinish ? const Color(0xFF2E7D32) : EggyColors.onyx);
    
    return FloatingButton(
      onTap: onTap,
      backgroundColor: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isStart) ...[
              const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 12),
            ],
            Text(
              label.toUpperCase(),
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 13,
                color: Colors.white,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (c) => isStart ? c.repeat() : c.stop())
     .shimmer(
       duration: 2.seconds, 
       color: Colors.white.withValues(alpha: 0.2),
     );
  }
}

class _HudGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = EggyColors.onyx.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HeatPulseBackground extends StatefulWidget {
  final double progress;
  const _HeatPulseBackground({required this.progress});

  @override
  State<_HeatPulseBackground> createState() => _HeatPulseBackgroundState();
}

class _HeatPulseBackgroundState extends State<_HeatPulseBackground> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
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
      builder: (context, _) {
        final heatIntensity = widget.progress;
        // More vibrant "Sleek Kawaii" gradient
        final baseColor = Color.lerp(EggyColors.warmWhite, EggyColors.accentGold.withValues(alpha: 0.1), heatIntensity)!;
        final pulseColor = Color.lerp(EggyColors.eggyPink.withValues(alpha: 0.05), EggyColors.tastyTeal.withValues(alpha: 0.05), heatIntensity)!;
        
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.4, -0.2), // Tilted for dynamic sunlight feel
              radius: 1.5 + (_ctrl.value * 0.3),
              colors: [
                pulseColor.withValues(alpha: 0.3 + (_ctrl.value * 0.1)),
                baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ── Professor Tip Overlay ──────────────────────────────────────────────────
class _ProfessorTipOverlay extends StatelessWidget {
  final int currentStepIndex;
  final List<ProTip> tips;

  const _ProfessorTipOverlay({
    required this.currentStepIndex,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    final activeTip = tips.where((t) => t.triggerStepIndex == currentStepIndex).firstOrNull;
    if (activeTip == null) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      right: 20,
      left: 20,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            SleekMascotFrame(
              size: 44,
              child: Image.asset('assets/images/eggy_idle.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activeTip.title.toUpperCase(),
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 8,
                      letterSpacing: 1.2,
                      color: EggyColors.tastyTeal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeTip.message,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: EggyColors.onyx,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
      .animate(key: ValueKey(activeTip.id))
      .slideX(begin: 1.0, end: 0, duration: 600.ms, curve: Curves.easeOutBack)
      .fadeIn()
      .shake(delay: 800.ms, hz: 4, rotation: 0.02),
    );
  }
}
