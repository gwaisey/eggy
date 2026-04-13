import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/models/step_icon_type.dart';

/// Bespoke animated icons for egg cooking steps.
/// "Cozy Kitchen" Line — High-fidelity shapes built with custom Flutter components.
class StepIcon extends StatelessWidget {
  final StepIconType type;
  final bool isCooking;
  final double size;

  const StepIcon({
    super.key,
    required this.type,
    this.isCooking = false,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      StepIconType.egg      => _buildEgg(),
      StepIconType.water    => _buildWater(),
      StepIconType.heat     => _buildHeat(),
      StepIconType.butter   => _buildButter(),
      StepIconType.timerGo  => _buildTimer(),
      StepIconType.iceBath  => _buildIceBath(),
      StepIconType.whisk    => _buildWhisk(),
      StepIconType.fold     => _buildFold(),
      StepIconType.crack    => _buildCrack(),
      StepIconType.plate    => _buildPlate(),
      StepIconType.salt     => _buildSalt(),
      StepIconType.vinegar  => _buildVinegar(),
      StepIconType.pan      => _buildPan(),
      StepIconType.pot      => _buildPot(),
      StepIconType.bowl     => _buildBowl(),
      StepIconType.saucepan => _buildSaucepan(),
      StepIconType.muffin   => _buildMuffin(),
      StepIconType.bacon    => _buildBacon(),
      StepIconType.spoon    => _buildSpoon(),
      StepIconType.spatula  => _buildSpatula(),
      StepIconType.sauce    => _buildSauce(),
      StepIconType.knife    => _buildKnife(),
    };
  }

  // ── Individual icon builds ──────────────────────────────────────────────────

  Widget _buildEgg() => _iconStack(
    icon: Icons.egg_rounded,
    iconColor: EggyColors.vibrantYolk,
    bgColor: EggyColors.vibrantYolk.withValues(alpha: 0.1),
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(begin: -0.05, end: 0.05, duration: 2800.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildWater() => _iconStack(
    icon: Icons.water_drop_rounded,
    iconColor: EggyColors.slate.withValues(alpha: 0.6),
    bgColor: EggyColors.slate.withValues(alpha: 0.1),
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.92, end: 1.08, duration: 1800.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildHeat() => _iconStack(
    icon: Icons.local_fire_department_rounded,
    iconColor: EggyColors.vibrantYolk,
    bgColor: EggyColors.vibrantYolk.withValues(alpha: 0.05),
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.9, end: 1.1, duration: 1200.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildButter() => _iconStack(
    icon: Icons.kitchen_rounded,
    iconColor: EggyColors.vibrantYolk,
    bgColor: EggyColors.vibrantYolk.withValues(alpha: 0.1),
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(delay: 400.ms, duration: 2400.ms, color: Colors.white.withValues(alpha: 0.6)),
  );

  Widget _buildTimer() => _iconStack(
    icon: Icons.timer_rounded,
    iconColor: EggyColors.onyx,
    bgColor: EggyColors.vibrantYolk,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat())
        .rotate(begin: 0, end: 1, duration: 8000.ms, curve: Curves.linear),
  );

  Widget _buildIceBath() => _iconStack(
    icon: Icons.ac_unit_rounded,
    iconColor: EggyColors.slate.withValues(alpha: 0.5),
    bgColor: EggyColors.slate.withValues(alpha: 0.05),
    foregroundElements: [
      ...List.generate(3, (i) => Positioned(
        top: 10 + (i * 15.0),
        right: 15 + (i * 8.0),
        child: Icon(Icons.square_rounded, size: 8, color: Colors.white.withValues(alpha: 0.8))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: -5, end: 5, duration: (1000 + i * 200).ms)
            .rotate(begin: 0, end: 0.2),
      )),
    ],
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.95, end: 1.05, duration: 2000.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildWhisk() => _iconStack(
    icon: Icons.auto_fix_high_rounded, 
    iconColor: EggyColors.slate,
    bgColor: EggyColors.slate.withValues(alpha: 0.05),
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(begin: -0.15, end: 0.15, duration: 300.ms, curve: Curves.easeInOut)
        .shake(hz: 3, curve: Curves.easeInOutSine),
  );

  Widget _buildFold() => _iconStack(
    icon: Icons.layers_rounded,
    iconColor: EggyColors.vibrantYolk,
    bgColor: EggyColors.vibrantYolk.withValues(alpha: 0.1),
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .flipV(begin: 0, end: 0.05, duration: 2000.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildCrack() => _iconStack(
    icon: Icons.egg_alt_rounded,
    iconColor: EggyColors.vibrantYolk,
    bgColor: EggyColors.vibrantYolk.withValues(alpha: 0.05),
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(begin: -0.04, end: 0.04, duration: 2600.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildPlate() => _iconStack(
    icon: Icons.restaurant_rounded,
    iconColor: EggyColors.slate,
    bgColor: EggyColors.slate.withValues(alpha: 0.05),
    extraAnimation: (w) => w
        .animate()
        .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0),
            duration: 700.ms, curve: Curves.elasticOut)
        .shimmer(delay: 500.ms, color: Colors.white.withValues(alpha: 0.5)),
  );

  Widget _buildSalt() => _iconStack(
    icon: Icons.grain_rounded,
    iconColor: Colors.white,
    bgColor: EggyColors.alabaster,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: -2, end: 2, duration: 1000.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildVinegar() => _iconStack(
    icon: Icons.opacity_rounded,
    iconColor: EggyColors.onyx.withValues(alpha: 0.4),
    bgColor: EggyColors.alabaster,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat())
        .moveY(begin: 0, end: 8, duration: 2000.ms, curve: Curves.easeInQuad)
        .fadeOut(duration: 500.ms, delay: 1500.ms),
  );

  Widget _buildPan() => _iconStack(
    icon: Icons.circle_rounded, 
    iconColor: Colors.transparent, // Background only
    bgColor: EggyColors.alabaster,
    foregroundElements: [
      // Pan body
      Center(
        child: Container(
          width: size * 0.55,
          height: size * 0.45,
          decoration: BoxDecoration(
            color: EggyColors.onyx,
            borderRadius: BorderRadius.circular(size * 0.1),
          ),
        ),
      ),
      // Wooden handle
      Positioned(
        left: size * 0.05,
        top: size * 0.4,
        child: Transform.rotate(
          angle: -0.4,
          child: Container(
            width: size * 0.4,
            height: size * 0.1,
            decoration: BoxDecoration(
              color: EggyColors.onyx.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(size * 0.05),
              border: Border.all(color: EggyColors.onyx.withValues(alpha: 0.8), width: 1),
            ),
          ),
        ),
      ),
    ],
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(begin: -0.02, end: 0.02, duration: 1500.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildPot() => _iconStack(
    icon: Icons.soup_kitchen_rounded,
    iconColor: Colors.transparent,
    bgColor: EggyColors.alabaster,
    foregroundElements: [
      // Pot body
      Center(
        child: Container(
          width: size * 0.6,
          height: size * 0.45,
          decoration: BoxDecoration(
            color: EggyColors.slate,
            borderRadius: BorderRadius.circular(size * 0.05),
          ),
        ),
      ),
      // Left handle
      Positioned(
        left: size * 0.1,
        top: size * 0.4,
        child: Container(
          width: size * 0.15,
          height: size * 0.15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: EggyColors.slate.withValues(alpha: 0.8), width: 3),
          ),
        ),
      ),
      // Right handle
      Positioned(
        right: size * 0.1,
        top: size * 0.4,
        child: Container(
          width: size * 0.15,
          height: size * 0.15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: EggyColors.slate.withValues(alpha: 0.8), width: 3),
          ),
        ),
      ),
      // Steam
      ...List.generate(2, (i) => Positioned(
        top: 15,
        left: size * (0.35 + i * 0.2),
        child: Icon(Icons.cloud_rounded, size: 20, color: Colors.white.withValues(alpha: 0.6))
            .animate(onPlay: (c) => c.repeat())
            .moveY(begin: 0, end: -30, duration: (1200 + i * 400).ms)
            .fadeOut(),
      )),
    ],
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.98, end: 1.02, duration: 2000.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildBowl() => _iconStack(
    icon: Icons.circle_outlined,
    iconColor: Colors.transparent,
    bgColor: EggyColors.slate.withValues(alpha: 0.05),
    foregroundElements: [
      // Cozy Ceramic Bowl Shape
      Center(
        child: Container(
          width: size * 0.7,
          height: size * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(size * 0.35),
              bottomRight: Radius.circular(size * 0.35),
              topLeft: Radius.circular(size * 0.05),
              topRight: Radius.circular(size * 0.05),
            ),
            border: Border.all(color: EggyColors.slate, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
        ),
      ),
      // Inner Teal Fill
      Center(
        child: Padding(
          padding: EdgeInsets.only(top: size * 0.1),
          child: Container(
            width: size * 0.55,
            height: size * 0.3,
            decoration: BoxDecoration(
              color: EggyColors.slate.withValues(alpha: 0.15),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(size * 0.27),
                bottomRight: Radius.circular(size * 0.27),
              ),
            ),
          ),
        ),
      ),
    ],
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: -2, end: 2, duration: 1800.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildSaucepan() => _iconStack(
    icon: Icons.soup_kitchen_rounded,
    iconColor: Colors.transparent,
    bgColor: EggyColors.alabaster,
    foregroundElements: [
      Center(
        child: Container(
          width: size * 0.45,
          height: size * 0.35,
          decoration: BoxDecoration(
            color: EggyColors.onyx.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(size * 0.05),
          ),
        ),
      ),
      Positioned(
        left: size * 0.05,
        top: size * 0.35,
        child: Container(
          width: size * 0.4,
          height: size * 0.08,
          decoration: BoxDecoration(
            color: EggyColors.onyx.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(size * 0.04),
          ),
        ),
      ),
    ],
    extraAnimation: (w) => w.animate(onPlay: (c) => c.repeat(reverse: true)).rotate(begin: -0.01, end: 0.01),
  );

  Widget _buildMuffin() => _iconStack(
    icon: Icons.bakery_dining_rounded,
    iconColor: EggyColors.onyx.withValues(alpha: 0.8),
    bgColor: EggyColors.alabaster,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.96, end: 1.04, duration: 1500.ms),
  );

  Widget _buildBacon() => _iconStack(
    icon: Icons.restaurant_menu_rounded, // Fallback base
    iconColor: Colors.transparent,
    bgColor: EggyColors.vibrantYolk.withValues(alpha: 0.05),
    foregroundElements: [
      // Two wavy bacon strips
      ...List.generate(2, (i) => Positioned(
        top: size * (0.3 + i * 0.15),
        child: Container(
          width: size * 0.6,
          height: size * 0.12,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [EggyColors.vibrantYolk, EggyColors.white, EggyColors.vibrantYolk],
              stops: [0.3, 0.5, 0.7],
            ),
            borderRadius: BorderRadius.circular(size * 0.06),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .shake(hz: 0.5),
      )),
    ],
    extraAnimation: (w) => w.animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -2, end: 2),
  );

  Widget _buildSpoon() => _iconStack(
    icon: Icons.restaurant_rounded,
    iconColor: EggyColors.slate,
    bgColor: EggyColors.alabaster,
    extraAnimation: (w) => w.animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -3, end: 3),
  );

  Widget _buildSpatula() => _iconStack(
    icon: Icons.menu_open_rounded,
    iconColor: EggyColors.slate,
    bgColor: EggyColors.alabaster,
    extraAnimation: (w) => w.animate(onPlay: (c) => c.repeat(reverse: true)).rotate(begin: -0.1, end: 0.1),
  );

  Widget _buildSauce() => _iconStack(
    icon: Icons.opacity_rounded,
    iconColor: EggyColors.onyx.withValues(alpha: 0.6),
    bgColor: EggyColors.alabaster,
    extraAnimation: (w) => w.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 0.9, end: 1.1),
  );

  Widget _buildKnife() => _iconStack(
    icon: Icons.colorize_rounded, 
    iconColor: Colors.transparent,
    bgColor: EggyColors.alabaster,
    foregroundElements: [
      // Blade
      Center(
        child: Transform.rotate(
          angle: 0.4,
          child: Container(
            width: size * 0.5,
            height: size * 0.1,
            decoration: BoxDecoration(
              color: EggyColors.slate.withValues(alpha: 0.4),
              borderRadius: BorderRadius.only(topRight: Radius.circular(size * 0.05), bottomRight: Radius.circular(size * 0.05)),
            ),
          ),
        ),
      ),
      // Wooden handle
      Positioned(
        left: size * 0.15,
        top: size * 0.45,
        child: Transform.rotate(
          angle: 0.4,
          child: Container(
            width: size * 0.25,
            height: size * 0.1,
            decoration: BoxDecoration(
              color: EggyColors.onyx.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(size * 0.02),
            ),
          ),
        ),
      ),
    ],
    extraAnimation: (w) => w.animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -2, end: 2),
  );

  Widget _iconStack({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    List<Widget> foregroundElements = const [],
    required Widget Function(Widget) extraAnimation,
  }) {
    Widget base = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: iconColor == Colors.transparent ? Colors.black.withValues(alpha: 0.05) : iconColor.withValues(alpha: 0.25),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: size * 0.51, color: iconColor),
      ),
    );

    base = base.animate().fadeIn(duration: 350.ms).scale(
      begin: const Offset(0.75, 0.75),
      end: const Offset(1.0, 1.0),
      duration: 500.ms,
      curve: Curves.elasticOut,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        extraAnimation(base),
        ...foregroundElements,
      ],
    );
  }
}
