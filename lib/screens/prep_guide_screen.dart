import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../core/interfaces/i_egg_recipe.dart';
import '../core/services/notification_service.dart';
import '../shared/ui/app_theme.dart';
import '../shared/ui/widgets.dart';
import '../shared/responsive_service.dart';
import '../shared/ui/recipe_step_media_view.dart';
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
          SafeArea(
            child: Column(
              children: [
                // ── Top Header Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: EggyColors.softCharcoal),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        widget.recipe.title.toUpperCase(),
                        style: AppTheme.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),

                // ── Progress Bridge (No Confusion) ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: Row(
                    children: List.generate(steps.length, (index) {
                      final isActive = index == _currentIndex;
                      final isDone = index < _currentIndex;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: isActive ? 6 : 4,
                          decoration: BoxDecoration(
                            color: isDone 
                                ? EggyColors.onyx 
                                : (isActive ? EggyColors.onyx : EggyColors.onyx.withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  child: Text(
                    'PREPARATION STEP ${_currentIndex + 1} / ${steps.length}',
                    style: AppTheme.caption.copyWith(
                      letterSpacing: 1.5,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: EggyColors.onyx.withValues(alpha: 0.5),
                    ),
                  ),
                ),

            // ── Main Step View ─────────────────────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Forced clarity: must use buttons
                    onPageChanged: (idx) => setState(() => _currentIndex = idx),
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      return Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: RecipeStepMediaView(
                            instruction: step.instruction,
                            iconType: step.iconType,
                            isCookingStep: step.isCookingStep,
                            context: step.context,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Sleek Controls ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, res.hp(40)),
                  child: Row(
                    children: [
                      if (_currentIndex > 0)
                        GestureDetector(
                          onTap: _prevStep,
                          child: Text(
                            'PREV',
                            style: AppTheme.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      const Spacer(),
                      FloatingButton(
                        onTap: () => _nextStep(steps),
                        backgroundColor: currentStep.isCookingStep ? EggyColors.onyx : (isLast ? const Color(0xFF2E7D32) : EggyColors.onyx),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            ctaLabel.toUpperCase(),
                            style: AppTheme.bodyMedium.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
        final baseColor = Color.lerp(const Color(0xFFF5F9FF), const Color(0xFFFFF7EB), heatIntensity)!;
        final pulseColor = Color.lerp(const Color(0xFFE6F0FF), const Color(0xFFFFEBD6), heatIntensity)!;
        
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2 + (_ctrl.value * 0.4),
              colors: [
                pulseColor.withValues(alpha: 0.2 + (_ctrl.value * 0.1)),
                baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}
