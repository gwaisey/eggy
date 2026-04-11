import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/interfaces/i_egg_recipe.dart';
import '../shared/ui/app_theme.dart';
import '../shared/ui/widgets.dart';
import '../features/mascot/mascot_view.dart';
import '../features/mascot/eggy_mascot_controller.dart';
import '../features/mascot/mascot_theme.dart';
import 'home_screen.dart';

/// Screen 5 — "The Hatch" — Timer complete celebration
class HatchScreen extends StatefulWidget {
  final IEggRecipe recipe;
  const HatchScreen({super.key, required this.recipe});

  @override
  State<HatchScreen> createState() => _HatchScreenState();
}

class _HatchScreenState extends State<HatchScreen> {
  @override
  void initState() {
    super.initState();
    // Set mascot to 'Done' state for celebration safely after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EggyMascotController>().setMood(MascotMood.excited);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EggyColors.warmWhite,
      body: Stack(
        children: [
          _BioParticleField(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final iconSize = (w * 0.40).clamp(160.0, 240.0);
                final titleSize = (w * 0.06).clamp(24.0, 42.0);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: h),
                    child: IntrinsicHeight(
                      child: Center(
                        child: SizedBox(
                          width: w.clamp(0.0, 520.0), // cap for wide screens
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: h * 0.05),

                              // ── Celebration Mascot Hero ──────────────────────────────
                              SleekMascotFrame(
                                size: iconSize,
                                child: Image.asset(
                                  'assets/images/eggy_excited.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                              .animate()
                              .scale(
                                begin: const Offset(0.3, 0.3),
                                duration: 800.ms,
                                curve: Curves.elasticOut,
                              )
                              .fadeIn()
                              .shimmer(delay: 1.seconds, duration: 1200.ms),

                              SizedBox(height: h * 0.04),

                              // ── Title (Protocol Success) ───────────────────────────
                              Text(
                                'Cooking Complete',
                                style: AppTheme.display.copyWith(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: -1,
                                ),
                                textAlign: TextAlign.center,
                              )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 800.ms)
                              .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                              SizedBox(height: h * 0.012),

                              Text(
                                'Your ${widget.recipe.title} has achieved perfect thermal equilibrium.',
                                style: AppTheme.body.copyWith(
                                  fontSize: (w * 0.035).clamp(14.0, 18.0),
                                  color: EggyColors.softCharcoal.withValues(alpha: 0.7),
                                  letterSpacing: 0.2,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              )
                              .animate()
                              .fadeIn(delay: 400.ms),

                              SizedBox(height: h * 0.08),

                              // ── Cook Another ────────────────────────────
                              FloatingButton(
                                onTap: () {
                                  context.read<EggyMascotController>().updateProgress(0.0);
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                                    (_) => false,
                                  );
                                },
                                  backgroundColor: EggyColors.onyx,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Text(
                                      'COOK ANOTHER EGG', 
                                      style: AppTheme.caption.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                      )
                                    ),
                                  ),
                              )
                              .animate(delay: 600.ms)
                              .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut)
                              .fadeIn(),

                              SizedBox(height: h * 0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background Sparkles (Flutter Icons, no emojis) ────────────────────────────

class _BioParticleField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (int i = 0; i < 20; i++)
              Positioned(
                top: (i * 73.1) % size.height,
                left: (i * 91.4) % size.width,
                child: Container(
                  width: 4 + (i % 3) * 2.0,
                  height: 4 + (i % 3) * 2.0,
                  decoration: BoxDecoration(
                    color: i % 2 == 0 ? EggyColors.liquidGold : Colors.white,
                    shape: i % 3 == 0 ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: i % 3 != 0 ? BorderRadius.circular(2) : null,
                  ),
                )
                .animate(delay: Duration(milliseconds: i * 50))
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut)
                .then()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: 0,
                  end: 40.0 * (i % 4 - 2),
                  duration: Duration(milliseconds: 2500 + i * 200),
                  curve: Curves.easeInOutSine,
                )
                .blur(begin: const Offset(0, 0), end: const Offset(2, 2))
                .fadeOut(delay: 1500.ms),
              ),
          ],
        ),
      ),
    );
  }
}
