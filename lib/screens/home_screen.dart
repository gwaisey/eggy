import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../features/recipes/recipe_factory.dart';
import '../core/interfaces/i_egg_recipe.dart';
import '../shared/ui/widgets.dart'; // Contains GlassCard, AntiGravityWrapper, FloatingButton
import '../shared/ui/egg_cabinet.dart';
import '../core/constants.dart';
import '../shared/responsive_service.dart';
import '../features/preferences/preferences_view_model.dart';
import '../features/mascot/mascot_view.dart'; // Contains SleekMascotFrame, EggyEndorsementBadge
import '../features/mascot/mascot_theme.dart'; // Contains MascotThemeFactory
import '../shared/ui/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<IEggRecipe> _recipes;

  @override
  void initState() {
    super.initState();
    _recipes = RecipeFactory(context.read()).all;
  }

  void _selectRecipe(IEggRecipe recipe) {
    if (recipe.hasYolkCustomizer) {
      Navigator.pushNamed(context, '/calibrate', arguments: recipe);
    } else {
      Navigator.pushNamed(context, '/prep', arguments: recipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = EggyResponsive(context);
    final hPad = res.spClamped(24);

    return Scaffold(
      body: Stack(
        children: [
          _BackgroundBlobs(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: res.hp(20)),
                        // Header
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.egg_alt_rounded, size: 24, color: EggyColors.champagne),
                                  const SizedBox(width: 12),
                                  Text('eggy', 
                                      style: AppTheme.display.copyWith(fontSize: res.spClamped(32))),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.settings_outlined,
                                    size: res.spClamped(22),
                                    color: EggyColors.onyx),
                                onPressed: () => Navigator.pushNamed(context, '/settings'),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: res.hp(40)),

                        // Main Greeting + Mascot
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'What are we making today?',
                                  style: AppTheme.headline.copyWith(
                                    fontSize: res.spClamped(24),
                                    color: EggyColors.onyx.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              AntiGravityWrapper(
                                amplitude: 4,
                                speed: 3,
                                child: SleekMascotFrame(
                                  size: res.spClamped(60),
                                  child: Image.asset(
                                    MascotThemeFactory.getTheme(MascotState.idle).assetPath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(curve: Curves.elasticOut),
                            ],
                          ),
                        ),

                        SizedBox(height: res.hp(30)),

                        // Egg Cabinet
                        const EggCabinet(),

                        SizedBox(height: res.hp(40)),

                        // Recipe Grid
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: res.spClamped(200, max: 260),
                              mainAxisExtent: res.hp(220),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                            itemCount: _recipes.length,
                            itemBuilder: (_, i) {
                              final recipe = _recipes[i];
                              // Move GestureDetector to the ROOT of the item to ensure hit-testing reliability
                              return GestureDetector(
                                onTap: () => _selectRecipe(recipe),
                                behavior: HitTestBehavior.opaque,
                                child: AntiGravityWrapper(
                                  amplitude: 5,
                                  speed: 4.0,
                                  delay: Duration(milliseconds: i * 150),
                                  child: Stack(
                                    children: [
                                      _RecipeBubble(
                                        recipe: recipe,
                                        res: res,
                                      ),
                                      if (i == 0) // Mascot's Selection
                                        Positioned(
                                          top: -4,
                                          right: -4,
                                          child: const EggyEndorsementBadge(size: 32)
                                              .animate()
                                              .scale(delay: 800.ms, curve: Curves.elasticOut)
                                              .fadeIn(),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: res.hp(100)), // Bottom padding
                      ],
                    ),
                  ),
                ),

                // Eggy Chat button (Always visible at bottom)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: hPad, vertical: res.hp(20)),
                  child: FloatingButton(
                    onTap: () => Navigator.pushNamed(context, '/chat'),
                    backgroundColor: EggyColors.onyx,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome_outlined, size: 16, color: EggyColors.champagne),
                        const SizedBox(width: 10),
                        Text('Assistant', 
                          style: AppTheme.bodyMedium.copyWith(
                            fontSize: res.spClamped(15), 
                            color: Colors.white,
                            letterSpacing: 1.0,
                          )
                        ),
                      ],
                    ),
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

class _RecipeBubble extends StatelessWidget {
  final IEggRecipe recipe;
  final EggyResponsive res;

  const _RecipeBubble({required this.recipe, required this.res});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(res.spClamped(16)),
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: res.hp(80)),
                        child: Image.asset(recipe.icon, fit: BoxFit.contain)
                            .animate()
                            .scale(delay: 100.ms, curve: Curves.easeOutBack)
                            .then()
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .slideY(begin: -0.03, end: 0.03, duration: 2.seconds, curve: Curves.easeInOut),
                      ),
                    ),
                    SizedBox(height: res.hp(10)),
                    Text(recipe.title,
                        style: AppTheme.title.copyWith(fontSize: res.spClamped(15)),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: res.hp(4)),
                    Text(recipe.subtitle,
                        style: AppTheme.caption.copyWith(fontSize: res.spClamped(10), color: EggyColors.onyx.withValues(alpha: 0.5)),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class _BackgroundBlobs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(top: -60, right: -60,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: EggyColors.champagne.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(bottom: 100, left: -80,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: EggyColors.onyx.withValues(alpha: 0.08),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
