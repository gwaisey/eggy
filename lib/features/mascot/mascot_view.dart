import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'eggy_mascot_controller.dart';
import 'mascot_theme.dart';
import '../../shared/ui/widgets.dart';
import '../../core/constants.dart';

/// A premium, gold-rimmed frame for the Eggy Mascot assets.
class SleekMascotFrame extends StatelessWidget {
  final Widget child;
  final double size;
  final bool hasGlow;
  final Color? glowColor;

  const SleekMascotFrame({
    super.key,
    required this.child,
    this.size = 120,
    this.hasGlow = true,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: hasGlow ? [
          BoxShadow(
            color: (glowColor ?? EggyColors.champagne).withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 2,
          )
        ] : null,
        border: Border.all(
          color: EggyColors.champagne.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: ClipOval(child: child),
        ),
      ),
    );
  }
}

/// A "Chef's Seal of Approval" badge using Eggy assets.
class EggyEndorsementBadge extends StatelessWidget {
  final bool isExcited;
  final double size;

  const EggyEndorsementBadge({
    super.key, 
    this.isExcited = true,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return SleekMascotFrame(
      size: size,
      hasGlow: false,
      child: Image.asset(
        isExcited ? 'assets/images/eggy_excited.png' : 'assets/images/eggy_cooking.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class EggyProgressMascot extends StatelessWidget {
  const EggyProgressMascot({super.key});

  Widget _buildMascotBody(MascotTheme theme) {
    return SleekMascotFrame(
      glowColor: theme.glowColor,
      child: theme.networkUrl != null
          ? CachedNetworkImage(
              imageUrl: theme.networkUrl!,
              placeholder: (context, url) => Image.asset(theme.assetPath, width: 120),
              errorWidget: (context, url, error) => Image.asset(theme.assetPath, width: 120),
            )
          : Image.asset(theme.assetPath, width: 120),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mascot = context.watch<EggyMascotController>();

    MascotState state = MascotState.idle;
    if (mascot.progress > 0.9) {
      state = MascotState.success;
    } else if (mascot.progress > 0.3) {
      state = MascotState.cooking;
    }

    final theme = MascotThemeFactory.getTheme(state);

    return AntiGravityWrapper(
      speed: mascot.speed,
      amplitude: mascot.amplitude,
      child: Center(
        child: _buildMascotBody(theme)
            .animate(target: mascot.isExcited ? 1 : 0)
            .shake(hz: 8, curve: Curves.easeInOutSine) // The "Yolk Wiggle"
            .shimmer(color: Colors.white.withOpacity(0.5)),
      ),
    );
  }
}
