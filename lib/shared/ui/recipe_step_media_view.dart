import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/models/step_icon_type.dart';
import '../../core/models/data_context.dart';
import 'app_theme.dart';
import 'widgets.dart';

/// Cartoon Edition Prep View — uses animated Flutter icons as "floating stickers."
/// No image generation required. Each [StepIconType] maps to a bespoke animation.
class RecipeStepMediaView extends StatelessWidget {
  final String instruction;
  final StepIconType iconType;
  final bool isCookingStep;
  final DataContext? context;

  const RecipeStepMediaView({
    super.key,
    required this.instruction,
    required this.iconType,
    this.isCookingStep = false,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    // Determine badge color based on classification
    final isSafety = this.context?.classification == 'Safety';
    final badgeColor = isSafety ? const Color(0xFFF5222D) : EggyColors.liquidGold;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Floating Animated Icon (The Visual Hook)
        SizedBox(
          height: 240,
          child: AntiGravityWrapper(
            speed: 3.0,
            amplitude: 14.0,
            child: _StepIcon(type: iconType, isCooking: isCookingStep),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 2. Classy Instruction Header (No Confusion)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            instruction,
            style: AppTheme.display.copyWith(
              fontSize: 22,
              height: 1.3,
              color: EggyColors.onyx.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // 3. Optional Science Trigger
        if (this.context != null)
          _ScienceBadge(
            data: this.context!,
            color: badgeColor,
            isSafety: isSafety,
          ),
      ],
    );
  }
}

class _ScienceBadge extends StatelessWidget {
  final DataContext data;
  final Color color;
  final bool isSafety;

  const _ScienceBadge({
    required this.data,
    required this.color,
    required this.isSafety,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (ctx) => _LabCardSheet(data: data),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSafety ? Icons.gpp_maybe_rounded : Icons.science_rounded,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              isSafety ? 'CRITICAL SAFETY' : 'MOLECULAR INSIGHT',
              style: AppTheme.caption.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .shimmer(duration: 2.seconds, color: color.withValues(alpha: 0.2)),
    );
  }
}

class _LabCardSheet extends StatelessWidget {
  final DataContext data;
  const _LabCardSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    final isSafety = data.classification == 'Safety';
    final accentColor = isSafety ? const Color(0xFFF5222D) : EggyColors.liquidGold;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: EggyColors.shadowSoft,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_user_rounded, color: accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verified Scientific Lineage', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(data.metadata['Domain'] ?? 'Culinary Science', style: AppTheme.caption),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: EggyColors.shadowSoft),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 0.5),

          // Pillars Grid
          Row(
            children: [
              _PillarItem(label: 'Source', value: data.lineage['dc:source'] ?? 'Verified Lab', icon: Icons.menu_book_rounded),
              _PillarItem(label: 'Trust', value: '${(data.trustScore * 100).toInt()}%', icon: Icons.auto_awesome_rounded),
              _PillarItem(label: 'Governance', value: data.classification, icon: Icons.gavel_rounded),
            ],
          ),
          const SizedBox(height: 24),

          // The "Nugget" (Explanation)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: EggyColors.creamFoam,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: accentColor, size: 18),
                    const SizedBox(width: 8),
                    Text('Molecular Insight', style: AppTheme.caption.copyWith(color: accentColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(data.content, style: AppTheme.body),
              ],
            ),
          ),
          if (isSafety) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFF5222D), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This protocol is governed by ${data.policy}',
                    style: AppTheme.caption.copyWith(color: const Color(0xFFF5222D), fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PillarItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PillarItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: EggyColors.shadowSoft),
          const SizedBox(height: 6),
          Text(label, style: AppTheme.caption.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value, 
            style: AppTheme.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  final StepIconType type;
  final bool isCooking;
  const _StepIcon({required this.type, required this.isCooking});

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
    };
  }

  // ── Individual icon builds ──────────────────────────────────────────────────

  Widget _buildEgg() => _iconStack(
    icon: Icons.egg_rounded,
    iconColor: EggyColors.butterYellow,
    bgColor: const Color(0xFFFFECB3),
    badge: null,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(begin: -0.05, end: 0.05, duration: 2800.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildWater() => _iconStack(
    icon: Icons.water_drop_rounded,
    iconColor: const Color(0xFF64B5F6),
    bgColor: const Color(0xFFE3F2FD),
    badge: null,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.92, end: 1.08, duration: 1800.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildHeat() => _iconStack(
    icon: Icons.local_fire_department_rounded,
    iconColor: const Color(0xFFFF7043),
    bgColor: const Color(0xFFFBE9E7),
    badge: null,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.9, end: 1.1, duration: 1200.ms, curve: Curves.easeInOutSine)
        .shimmer(delay: 600.ms, color: Colors.orangeAccent.withValues(alpha: 0.4)),
  );

  Widget _buildButter() => _iconStack(
    icon: Icons.kitchen_rounded,
    iconColor: EggyColors.butterYellow,
    bgColor: const Color(0xFFFFFDE7),
    badge: null,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(delay: 400.ms, duration: 2400.ms, color: Colors.white.withValues(alpha: 0.6)),
  );

  Widget _buildTimer() => _iconStack(
    icon: Icons.timer_rounded,
    iconColor: EggyColors.softCharcoal,
    bgColor: EggyColors.butterYellow,
    badge: null,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat())
        .rotate(begin: 0, end: 1, duration: 8000.ms, curve: Curves.linear)
        .shimmer(delay: 1000.ms, color: Colors.white.withValues(alpha: 0.5)),
  );

  Widget _buildIceBath() => _iconStack(
    icon: Icons.ac_unit_rounded,
    iconColor: const Color(0xFF4DD0E1),
    bgColor: const Color(0xFFE0F7FA),
    badge: null,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.90, end: 1.10, duration: 2000.ms, curve: Curves.easeInOutSine)
        .shimmer(color: Colors.white.withValues(alpha: 0.7)),
  );

  Widget _buildWhisk() => _iconStack(
    icon: Icons.blender_rounded,
    iconColor: const Color(0xFFAB79E8),
    bgColor: const Color(0xFFF3E5F5),
    badge: null,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(begin: -0.08, end: 0.08, duration: 400.ms, curve: Curves.easeInOut),
  );

  Widget _buildFold() => _iconStack(
    icon: Icons.layers_rounded,
    iconColor: EggyColors.butterYellow,
    bgColor: const Color(0xFFFFF9C4),
    badge: null,
    extraAnimation: (w) => w
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .flipV(begin: 0, end: 0.05, duration: 2000.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildCrack() => _iconStack(
    icon: Icons.egg_alt_rounded,
    iconColor: const Color(0xFFFFCC80),
    bgColor: const Color(0xFFFFF3E0),
    badge: null,
    extraAnimation: (w) => w
        .animate()
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0),
            duration: 600.ms, curve: Curves.elasticOut)
        .then()
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(begin: -0.04, end: 0.04, duration: 2600.ms, curve: Curves.easeInOutSine),
  );

  Widget _buildPlate() => _iconStack(
    icon: Icons.restaurant_rounded,
    iconColor: const Color(0xFF66BB6A),
    bgColor: const Color(0xFFE8F5E9),
    badge: null,
    extraAnimation: (w) => w
        .animate()
        .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0),
            duration: 700.ms, curve: Curves.elasticOut)
        .shimmer(delay: 500.ms, color: Colors.white.withValues(alpha: 0.5)),
  );

  // ── Shared Builder ──────────────────────────────────────────────────────────

  Widget _iconStack({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    Widget? badge,
    required Widget Function(Widget) extraAnimation,
  }) {
    Widget w = Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.25),
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, size: 72, color: iconColor),
    );

    // Add the shimmer on entry
    w = w.animate().fadeIn(duration: 350.ms).scale(
      begin: const Offset(0.75, 0.75),
      end: const Offset(1.0, 1.0),
      duration: 500.ms,
      curve: Curves.elasticOut,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        extraAnimation(w),
        if (badge != null) Positioned(bottom: 0, right: 0, child: badge),
      ],
    );
  }
}
