import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/models/step_icon_type.dart';
import '../../core/models/data_context.dart';
import 'app_theme.dart';
import 'widgets.dart';
import 'step_icon.dart';

class RecipeStepMediaView extends StatelessWidget {
  final String instruction;
  final String? actionCommand;
  final StepIconType iconType;
  final bool isCookingStep;
  final DataContext? context;

  const RecipeStepMediaView({
    super.key,
    required this.instruction,
    this.actionCommand,
    required this.iconType,
    this.isCookingStep = false,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    // Determine badge color based on classification
    final isSafety = this.context?.classification == 'Safety';
    final badgeColor = isSafety ? const Color(0xFFF5222D) : EggyColors.vibrantYolk;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Technical Icon Platform (The Visual Hook)
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glowing platform base
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      badgeColor.withValues(alpha: 0.1),
                      badgeColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(duration: 2.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), curve: Curves.easeInOut),
              
              AntiGravityWrapper(
                speed: 3.0,
                amplitude: 14.0,
                child: StepIcon(type: iconType, isCooking: isCookingStep),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 2. Bold Action Hero (The "What to do now")
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            (actionCommand ?? instruction).toUpperCase(),
            style: AppTheme.display.copyWith(
              fontSize: 22,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w900,
              color: EggyColors.onyx,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // 3. Narrative Detail
        if (actionCommand != null && actionCommand != instruction)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              instruction,
              style: AppTheme.body.copyWith(
                fontSize: 14,
                height: 1.5,
                color: EggyColors.onyx.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 32),

        // 4. Optional Science Trigger
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
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withValues(alpha: 0.1)),
            ),
            child: Text(
              data.content,
              style: AppTheme.body.copyWith(
                height: 1.6,
                color: EggyColors.onyx.withValues(alpha: 0.8),
              ),
            ),
          ),
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
          Icon(icon, size: 20, color: EggyColors.softCharcoal.withValues(alpha: 0.4)),
          const SizedBox(height: 8),
          Text(label, style: AppTheme.caption.copyWith(fontSize: 9, letterSpacing: 0.5)),
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
