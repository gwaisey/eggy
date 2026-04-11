import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/interfaces/i_egg_calculator.dart';
import '../core/interfaces/i_egg_recipe.dart';
import '../core/egg_physics_engine.dart';
import '../features/yolk_meter/yolk_o_meter_view_model.dart';
import '../shared/ui/app_theme.dart';
import '../shared/ui/widgets.dart';
import '../shared/responsive_service.dart';
import '../features/preferences/preferences_view_model.dart';
import 'prep_guide_screen.dart';

class YolkCustomizerScreen extends StatelessWidget {
  final IEggRecipe recipe;

  const YolkCustomizerScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final globalPrefs = context.read<PreferencesViewModel>();

    return ChangeNotifierProvider(
      create: (_) => YolkOMeterViewModel(
        context.read<EggPhysicsEngine>(),
        prefs: UserEggPreferences(
          size: globalPrefs.eggSize,
          species: globalPrefs.eggSpecies,
          startTemp: globalPrefs.startTemp,
        ),
      ),
      child: _YolkCustomizerBody(recipe: recipe),
    );
  }
}

class _YolkCustomizerBody extends StatelessWidget {
  final IEggRecipe recipe;
  const _YolkCustomizerBody({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<YolkOMeterViewModel>();
    final res = EggyResponsive(context);

    return Scaffold(
      backgroundColor: EggyColors.warmWhite,
      appBar: AppBar(
        title: Text(recipe.title, style: AppTheme.headline.copyWith(fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Molecular Viscosity background
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  EggyColors.warmWhite,
                  // Linear blend from Fluid Yellow -> Matte Gold -> Structured Pale
                  Color.lerp(
                    Color.lerp(const Color(0xFFFFE082).withValues(alpha: 0.1), const Color(0xFFFFB300).withValues(alpha: 0.15), vm.sliderValue),
                    const Color(0xFFFFF9C4).withValues(alpha: 0.2), 
                    vm.sliderValue > 0.7 ? (vm.sliderValue - 0.7) / 0.3 : 0.0,
                  )!,
                ],
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTabletLayout = constraints.maxWidth >= 600 || res.hasHinge;
                final hPad = res.spClamped(24);

                // Top / Left Pane (Yolk settings & Visuals)
                final topMainSection = Column(
                  children: [
                    SizedBox(height: res.hp(16)),

                    // Yolk label pill
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: anim.drive(Tween(begin: const Offset(0, 0.2), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
                          child: child,
                        ),
                      ),
                      child: Container(
                        key: ValueKey(vm.yolkLabel),
                        padding: EdgeInsets.symmetric(horizontal: res.spClamped(28), vertical: res.hp(12)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: vm.yolkColor.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: vm.yolkColor.withValues(alpha: 0.2), width: 0.8),
                        ),
                        child: Text(
                          vm.yolkLabel.toUpperCase(), 
                          style: AppTheme.caption.copyWith(
                            color: EggyColors.softCharcoal, 
                            fontSize: res.spClamped(12),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                          )
                        ),
                      ),
                    ),

                    SizedBox(height: res.hp(20)),

                    // New Culinary Insight Description
                    _CulinaryInsightMemo(description: recipe.description),

                    SizedBox(height: res.hp(20)),

                    // Egg cross-section + slider row
                    SizedBox(
                      height: 320, 
                      child: Row(
                        children: [
                          // Egg cross-section visual
                          Expanded(
                            child: AntiGravityWrapper(
                              amplitude: 8,
                              speed: 3.5,
                              child: _EggCrossSection(
                                yolkColor: vm.yolkColor,
                                species: vm.prefs.species,
                              ),
                            ),
                          ),

                          SizedBox(width: res.spClamped(32)),

                          // The Yolk-o-Meter slider
                          _GlassYolkSlider(),

                          SizedBox(width: res.spClamped(16)),

                          // Level labels
                          _YolkLabels(currentValue: vm.sliderValue),
                        ],
                      ),
                    ),
                  ],
                );

                // Bottom / Right Pane (Preferences & Start)
                final bottomStartSection = Column(
                  children: [
                    // Egg size & temp selectors
                    _EggPrefsRow(),

                    SizedBox(height: res.hp(24)),

                    // Cooking time display
                    GlassCard(
                      padding: EdgeInsets.symmetric(horizontal: res.spClamped(20), vertical: res.hp(18)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PREPARATION TIME', 
                                  style: AppTheme.caption.copyWith(fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Precision Thermal Matrix', 
                                  style: AppTheme.caption.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(vm.formattedCookingTime,
                              style: AppTheme.display.copyWith(
                                  color: EggyColors.onyx, fontSize: res.spClamped(28))),
                        ],
                      ),
                    ),

                    SizedBox(height: res.hp(20)),

                    // Start button
                    FloatingButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, anim, __) => PrepGuideScreen(
                              recipe: recipe,
                              cookingTime: vm.cookingTime,
                            ),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      backgroundColor: EggyColors.onyx,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_outlined, size: res.spClamped(16), color: EggyColors.champagne),
                          const SizedBox(width: 10),
                          Text(
                            'START COOKING', 
                            style: AppTheme.bodyMedium.copyWith(
                              fontSize: res.spClamped(15), 
                              color: Colors.white,
                              letterSpacing: 1.0,
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                if (isTabletLayout) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: res.hp(32)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Main interactive area
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: topMainSection),
                              if (res.hasHinge)
                                SizedBox(width: res.spClamped(40))
                              else
                                SizedBox(width: res.spClamped(24)),
                              Expanded(child: bottomStartSection),
                            ],
                          ),
                          
                          const SizedBox(height: 48),
                          
                          // Scientific Insight Footer (Desktop/Tablet version)
                          const _ScientificInsightCard(),
                        ],
                      ),
                    ),
                  );
                } else {
                   return SingleChildScrollView(
                     physics: const BouncingScrollPhysics(),
                     padding: EdgeInsets.symmetric(horizontal: hPad),
                     child: ConstrainedBox(
                       constraints: BoxConstraints(
                         minHeight: constraints.maxHeight,
                       ),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         children: [
                           // Add some leading air at the top
                           SizedBox(height: res.hp(20)),
                           topMainSection,
                           SizedBox(height: res.hp(32)),
                           bottomStartSection,
                           SizedBox(height: res.hp(32)),
                           const _ScientificInsightCard(),
                           SizedBox(height: res.hp(24)),
                         ],
                       ),
                     ),
                   );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassYolkSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<YolkOMeterViewModel>();
    const sliderH = 320.0;

    return SizedBox(
      width: 54,
      height: sliderH,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glass track shadow/depth
          Container(
            width: 16,
            height: sliderH,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // Glass track
          Container(
            width: 14,
            height: sliderH,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 0.8),
            ),
          ),
          // Filled track (Liquid Viscosity Effect)
          Positioned(
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 14,
              height: vm.sliderValue * sliderH,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    vm.yolkColor,
                    vm.yolkColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: vm.yolkColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
            ),
          ),
          // Draggable Eggy handle
          Positioned(
            bottom: (vm.sliderValue * sliderH) - 20,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                final newVal = vm.sliderValue - (details.delta.dy / sliderH);
                vm.updateSlider(newVal);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: EggyColors.shadowSoft.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: vm.yolkColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: vm.yolkColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.drag_indicator_rounded, size: 16, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YolkLabels extends StatelessWidget {
  final double currentValue;
  const _YolkLabels({required this.currentValue});

  static const _labels = [
    (0.0,  'Liquid\nGold'),
    (0.25, 'Jammy'),
    (0.5,  'Custardy'),
    (0.75, 'Soft\nSet'),
    (1.0,  'Firm'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _labels.reversed.map((entry) {
          final (val, label) = entry;
          final active = (currentValue - val).abs() < 0.12;
          return AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: AppTheme.caption.copyWith(
              fontSize: active ? 13 : 10,
              fontWeight: active ? FontWeight.bold : FontWeight.w400,
              letterSpacing: active ? 1.0 : 0.2,
              color: active
                  ? EggyColors.softCharcoal
                  : EggyColors.softCharcoal.withValues(alpha: 0.35),
            ),
            child: Text(label),
          );
        }).toList(),
      ),
    );
  }
}

class _EggCrossSection extends StatelessWidget {
  final Color yolkColor;
  final EggSpecies species;
  const _EggCrossSection({required this.yolkColor, required this.species});

  @override
  Widget build(BuildContext context) {
    final theme = EggSpeciesTheme.registry[species]!;

    return CustomPaint(
      size: const Size(180, 200),
      painter: _CrossSectionPainter(
        yolkColor: yolkColor,
        shellColor: theme.shellColor,
        visualScale: theme.visualScale,
      ),
    );
  }
}

class _CrossSectionPainter extends CustomPainter {
  final Color yolkColor;
  final Color shellColor;
  final double visualScale;

  _CrossSectionPainter({
    required this.yolkColor,
    required this.shellColor,
    required this.visualScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Scale the entire egg based on species-specific visual factor
    final baseEggHeight = math.min(size.width * (200 / 180), size.height) * 0.95;
    final eggHeight = baseEggHeight * visualScale.clamp(0.5, 1.4); // Clamp for UI stability
    final eggWidth = eggHeight * (180 / 200);

    // 1. Shell Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 4, cy + 8), width: eggWidth, height: eggHeight),
      Paint()..color = EggyColors.shadowSoft.withValues(alpha: 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // 2. White (Albumen lattice)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: eggWidth, height: eggHeight),
      Paint()..shader = RadialGradient(
        colors: [
          shellColor.withValues(alpha: 0.1), // Hint of shell color in the translucent white
          const Color(0xFFFBFBF8),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCenter(center: Offset(cx, cy), width: eggWidth, height: eggHeight)),
    );

    // Subtle internal fill
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: eggWidth - 2, height: eggHeight - 2),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    
    // 3. Yolk (Vitellin core)
    final yolkSizeFactor = visualScale >= 1.5 ? 0.55 : 0.48; // Larger eggs have relatively larger yolks
    final yolkRect = Rect.fromCenter(center: Offset(cx, cy + (eggHeight * 0.05)), width: eggWidth * yolkSizeFactor, height: eggWidth * yolkSizeFactor);
    canvas.drawOval(
      yolkRect,
      Paint()..shader = RadialGradient(
        colors: [
          yolkColor,
          yolkColor.withValues(alpha: 0.85),
        ],
      ).createShader(yolkRect),
    );
    
    // 4. Detailed Highlight
    canvas.drawCircle(
      Offset(cx - (eggWidth * 0.1), cy - (eggHeight * 0.05)),
      eggWidth * 0.06,
      Paint()..color = Colors.white.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    
    // 5. Exterior Hairline Outline
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: eggWidth, height: eggHeight),
      Paint()
        ..color = EggyColors.softCharcoal.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(_CrossSectionPainter old) =>
      old.yolkColor != yolkColor ||
      old.shellColor != shellColor ||
      old.visualScale != visualScale;
}

class _EggPrefsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<YolkOMeterViewModel>();

    return Row(
      children: [
        // Egg size
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: EggSize.values.map((size) {
                  final selected = vm.prefs.size == size;
                  return GestureDetector(
                    onTap: () => vm.updateSize(size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? EggyColors.onyx : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        size.name[0].toUpperCase() + size.name.substring(1),
                        style: AppTheme.caption.copyWith(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? Colors.white : EggyColors.onyx.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Start temp
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TempChip(label: 'Fridge', temp: StartTemp.fridge, current: vm.prefs.startTemp, vm: vm),
                  _TempChip(label: 'Room',   temp: StartTemp.roomTemp, current: vm.prefs.startTemp, vm: vm),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TempChip extends StatelessWidget {
  final String label;
  final StartTemp temp;
  final StartTemp current;
  final YolkOMeterViewModel vm;

  const _TempChip({required this.label, required this.temp, required this.current, required this.vm});

  @override
  Widget build(BuildContext context) {
    final selected = temp == current;
    return GestureDetector(
      onTap: () => vm.updateStartTemp(temp),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? EggyColors.onyx : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: AppTheme.caption.copyWith(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? Colors.white : EggyColors.onyx.withValues(alpha: 0.4),
            )),
      ),
    );
  }
}
class _ScientificInsightCard extends StatelessWidget {
  const _ScientificInsightCard();

  static const _tips = [
    (Icons.biotech_rounded, "LLPS Theory: Egg yolk proteins demonstrate Liquid-Liquid Phase Separation, forming biomolecular condensates as they cook."),
    (Icons.egg_rounded, "Duck eggs are the 'B12 Kings'—containing ~225% of your daily value (5.4µg) in just one egg!"),
    (Icons.thermostat_rounded, "The Williams Formula suggests mass (M) is the primary variable for thermal inertia in large eggs."),
    (Icons.science_rounded, "Coagulation begins at 62°C. Below this, the protein lattice is too weak to trap moisture."),
    (Icons.tips_and_updates_rounded, "Zero-Noise Physics: Eggy assumes a perfect 100°C boiling point to focus purely on internal thermal dynamics. ✨"),
  ];

  @override
  Widget build(BuildContext context) {
    final res = EggyResponsive(context);
    final tip = _tips[math.Random().nextInt(_tips.length)];

    return GlassCard(
      padding: EdgeInsets.all(res.spClamped(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tip.$1, size: 14, color: EggyColors.champagne),
              const SizedBox(width: 8),
              Text(
                "PROFESSOR'S NOTE",
                style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: EggyColors.onyx.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tip.$2,
            style: AppTheme.body.copyWith(
              fontSize: res.spClamped(13),
              height: 1.5,
              color: EggyColors.onyx.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _CulinaryInsightMemo extends StatelessWidget {
  final String description;
  const _CulinaryInsightMemo({required this.description});

  @override
  Widget build(BuildContext context) {
    final res = EggyResponsive(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: res.spClamped(8)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 14, color: EggyColors.onyx),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                description,
                style: AppTheme.caption.copyWith(
                  fontSize: res.spClamped(12),
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  color: EggyColors.onyx.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
