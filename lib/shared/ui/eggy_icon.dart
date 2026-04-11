import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The Global Asset Loader for Eggy.
/// Replaces arbitrary textual emojis with scalable, AI-generated image assets.
class EggyIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;
  final bool animateBounce;

  const EggyIcon(
    this.assetPath, {
    super.key,
    this.size = 24.0,
    this.color,
    this.animateBounce = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      assetPath,
      width: size,
      height: size,
      color: color, 
      filterQuality: FilterQuality.medium,
    );

    if (animateBounce) {
      image = image.animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .slideY(begin: -0.05, end: 0.05, duration: 2.seconds, curve: Curves.easeInOut);
    }

    return image;
  }
}
