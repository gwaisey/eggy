import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../features/preferences/preferences_view_model.dart';
import '../../shared/ui/app_theme.dart';
import '../../shared/responsive_service.dart';

class EggCabinet extends StatefulWidget {
  const EggCabinet({super.key});

  @override
  State<EggCabinet> createState() => _EggCabinetState();
}

class _EggCabinetState extends State<EggCabinet> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesViewModel>();
    final res = EggyResponsive(context);
    final speciesList = EggSpecies.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                'EGG CABINET',
                style: AppTheme.caption.copyWith(
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: EggyColors.onyx.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  EggSpeciesTheme.registry[prefs.eggSpecies]?.label.toUpperCase() ?? '',
                  style: AppTheme.caption.copyWith(
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: EggyColors.vibrantYolk,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: 160,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: speciesList.map((species) {
                          final theme = EggSpeciesTheme.registry[species]!;
                          final isSelected = prefs.eggSpecies == species;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _EggSpeciesCard(
                              species: species,
                              theme: theme,
                              isSelected: isSelected,
                              onTap: () => prefs.setEggSpecies(species),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EggSpeciesCard extends StatefulWidget {
  final EggSpecies species;
  final EggSpeciesTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _EggSpeciesCard({
    required this.species,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_EggSpeciesCard> createState() => _EggSpeciesCardState();
}

class _EggSpeciesCardState extends State<_EggSpeciesCard> with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    if (widget.isSelected) _shakeCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_EggSpeciesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _shakeCtrl.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _shakeCtrl.stop();
      _shakeCtrl.reset();
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 90,
        height: 140,
        clipBehavior: Clip.antiAlias, // Recommended by user to prevent overflows
        decoration: BoxDecoration(
          color: widget.isSelected 
            ? EggyColors.white 
            : EggyColors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: widget.isSelected 
              ? EggyColors.vibrantYolk.withValues(alpha: 0.5) 
              : EggyColors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            if (widget.isSelected)
              BoxShadow(
                color: EggyColors.shadowSoft.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _shakeCtrl,
              builder: (context, child) {
                final shake = math.sin(_shakeCtrl.value * math.pi * 2) * (widget.isSelected ? 2.0 : 0.0);
                final rotation = math.sin(_shakeCtrl.value * math.pi * 2) * (widget.isSelected ? 0.05 : 0.0);
                
                return Transform.translate(
                  offset: Offset(0, shake),
                  child: Transform.rotate(
                    angle: rotation,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 46 * widget.theme.visualScale,
                height: 56 * widget.theme.visualScale,
                decoration: BoxDecoration(
                  color: widget.theme.shellColor,
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(
                      23 * widget.theme.visualScale, 
                      (widget.species == EggSpecies.quail ? 24 : (widget.species == EggSpecies.goose ? 32 : 28)) * widget.theme.visualScale
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: EggyColors.onyx.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                    BoxShadow(
                      color: widget.theme.shellColor.withValues(alpha: 0.5),
                      blurRadius: 2,
                      offset: const Offset(-1, -1),
                    ),
                  ],
                  gradient: widget.species == EggSpecies.henBrown 
                    ? null // Matte Brown Exception
                    : RadialGradient(
                        center: const Alignment(-0.2, -0.4),
                        radius: 1.0,
                        colors: [
                          EggyColors.white.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                ),
                // Quail mottling effect
                child: widget.species == EggSpecies.quail 
                  ? CustomPaint(painter: _QuailMottlingPainter())
                  : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.theme.label.split(' ').first,
              style: AppTheme.caption.copyWith(
                fontSize: 9,
                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                color: widget.isSelected ? EggyColors.onyx : EggyColors.onyx.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuailMottlingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = EggyColors.onyx.withValues(alpha: 0.3);
    final random = math.Random(42);
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
