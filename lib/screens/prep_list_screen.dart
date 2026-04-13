import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../core/models/recipe_models.dart';
import '../core/models/recipe_step.dart';
import '../core/models/step_icon_type.dart';
import '../core/interfaces/i_egg_recipe.dart';
import '../core/interfaces/i_egg_calculator.dart';
import '../core/egg_physics_engine.dart';
import '../shared/ui/app_theme.dart';
import '../shared/ui/widgets.dart'; 
import '../shared/responsive_service.dart';
import '../features/yolk_meter/yolk_o_meter_view_model.dart';
import '../features/preferences/preferences_view_model.dart';
import 'prep_guide_screen.dart';

class PrepListScreen extends StatefulWidget {
  final IEggRecipe recipe;

  const PrepListScreen({super.key, required this.recipe});

  @override
  State<PrepListScreen> createState() => _PrepListScreenState();
}

class _PrepListScreenState extends State<PrepListScreen> {
  @override
  Widget build(BuildContext context) {
    if (!widget.recipe.hasYolkCustomizer) {
      return _PrepListScaffold(recipe: widget.recipe);
    }

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
      child: _PrepListScaffold(recipe: widget.recipe),
    );
  }
}

class _PrepListScaffold extends StatelessWidget {
  final IEggRecipe recipe;
  const _PrepListScaffold({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final res = EggyResponsive(context);
    final vm = recipe.hasYolkCustomizer ? context.watch<YolkOMeterViewModel>() : null;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: EggyColors.alabaster,
      body: Stack(
        children: [
          // 1. Premium Sliver Layout
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Header
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                elevation: 0,
                backgroundColor: EggyColors.alabaster,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: EggyColors.onyx, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Gradient accent (Safety fix: uses fixed height instead of bottom-inset to avoid negative height on collapse)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 280,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                EggyColors.vibrantYolk.withValues(alpha: 0.15),
                                EggyColors.alabaster,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Large Dish Icon Hero
                      Hero(
                        tag: 'recipe_${recipe.id}',
                        child: AntiGravityWrapper(
                          amplitude: 12,
                          speed: 3.5,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Image.asset(
                              recipe.icon, 
                              height: 220, 
                              fit: BoxFit.contain,
                            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // The Pull-up Content Card
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 20,
                        offset: Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 140), // Large bottom padding for the sticky button
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Subtitle
                        Text(
                          recipe.title,
                          style: AppTheme.display.copyWith(fontSize: 32, height: 1.1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe.subtitle,
                          style: AppTheme.body.copyWith(
                            color: EggyColors.softCharcoal.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // Metrics Row (High-fidelity indicators)
                        _MetricsRow(recipe: recipe, vm: vm),

                        const SizedBox(height: 32),
                        // Dynamic Nutrition Card (Reactive to species/size/count)
                        _NutritionSection(
                          recipe: recipe,
                          prefs: vm?.prefs ?? const UserEggPreferences(),
                        ),
                        const SizedBox(height: 48),

                        // Ingredients Block
                        _buildInfoSection('Ingredients', recipe.ingredients),
                        
                        const SizedBox(height: 48),

                        // Tools Block
                        _buildInfoSection('Kitchen tools', recipe.tools),
                        
                        const SizedBox(height: 48),

                        // The Method Block
                        _buildMethodSection(),

                        const SizedBox(height: 48),

                        // Customization Section (Yolk calibration integrated)
                        if (recipe.hasYolkCustomizer && vm != null) ...[
                          _buildTargetResultBlock(context, vm),
                          const SizedBox(height: 48),
                        ],

                        // Professor Note
                        _buildProfessorNote(),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
                ),
              ),
            ],
          ),

          // 2. Sticky "Start Cooking" Button
          _buildStartButton(context, vm),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<PrepItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionHeader(title: title),
            Text('${items.length} items', style: AppTheme.caption.copyWith(fontSize: 10)),
          ],
        ),
        const SizedBox(height: 20),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: EggyColors.alabaster,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: EggyColors.vibrantYolk, shape: BoxShape.circle),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.name,
                  style: AppTheme.bodyMedium.copyWith(fontSize: 15, color: EggyColors.onyx),
                ),
              ),
              if (item.quantity != null)
                Text(
                  item.quantity!,
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: EggyColors.softCharcoal.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildMethodSection() {
    final steps = recipe.getStepInstructions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Mission procedure'),
        const SizedBox(height: 32),
        // The Vertical Timeline Container
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          itemBuilder: (context, index) {
            return _MethodStepCard(
              index: index,
              step: steps[index],
              isLast: index == steps.length - 1,
            ).animate()
              .fadeIn(delay: (200 + index * 50).ms)
              .slideX(begin: 0.05, end: 0, delay: (200 + index * 50).ms, curve: Curves.easeOutCubic);
          },
        ),
      ],
    );
  }

  Widget _buildTargetResultBlock(BuildContext context, YolkOMeterViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Target result'),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: vm.yolkColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: vm.yolkColor.withValues(alpha: 0.15), width: 1.5),
          ),
          child: Column(
            children: [
              // 1. Mission Outcome Header (Visual + Metrics)
              Row(
                children: [
                  // Egg Cross-Section Visual
                  SizedBox(
                    width: 70,
                    height: 90,
                    child: _EggCrossSection(color: vm.yolkColor),
                  ),
                  const SizedBox(width: 20),
                  // Metrics
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vm.yolkLabel.toUpperCase(), 
                          style: AppTheme.caption.copyWith(
                            fontWeight: FontWeight.w900, 
                            letterSpacing: 1.2,
                            color: vm.yolkColor.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vm.formattedCookingTime, 
                          style: AppTheme.display.copyWith(fontSize: 36, height: 1.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 2. The Doneness Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: vm.yolkColor,
                  inactiveTrackColor: vm.yolkColor.withValues(alpha: 0.1),
                  thumbColor: Colors.white,
                  overlayColor: vm.yolkColor.withValues(alpha: 0.1),
                  trackHeight: 10, // Thicker, more tactile track
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
                ),
                child: Slider(
                  value: vm.sliderValue,
                  onChanged: vm.updateSlider,
                ),
              ),

              const SizedBox(height: 32),
              
              // 3. Species Selection (Full Width Integrated)
              _SpeciesCarousel(
                selected: vm.prefs.species,
                onChanged: vm.updateSpecies,
                activeColor: vm.yolkColor,
              ),

              const SizedBox(height: 32),

              // 4. Physical Attributes (The "Normal Size" Controls)
              // We split these into two rows to ensure "Normal Size" buttons on mobile
              Row(
                children: [
                  // Quantity
                  _QuantitySelector(
                    count: vm.prefs.eggCount,
                    onChanged: vm.updateEggCount,
                    activeColor: vm.yolkColor,
                  ),
                  const SizedBox(width: 12),
                  // Size Toggle
                  Expanded(
                    child: _EggyToggle(
                      labels: const ['Small', 'Large'],
                      selectedIndex: vm.prefs.size == EggSize.large ? 1 : 0,
                      activeColor: vm.yolkColor,
                      onChanged: (idx) => vm.updateSize(idx == 0 ? EggSize.small : EggSize.large),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Temperature Toggle (Full Width for clarity)
              _EggyToggle(
                labels: const ['Fridge Cold', 'Room Temperature'],
                selectedIndex: vm.prefs.startTemp == StartTemp.roomTemp ? 1 : 0,
                activeColor: vm.yolkColor,
                onChanged: (idx) => vm.updateStartTemp(idx == 0 ? StartTemp.fridge : StartTemp.roomTemp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfessorNote() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EggyColors.champagne.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: EggyColors.champagne, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'A zero-friction setup is the key to culinary mastery. Focus on the prep.',
              style: AppTheme.body.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: EggyColors.onyx.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, YolkOMeterViewModel? vm) {
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: 0.8),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: FloatingButton(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrepGuideScreen(
                  recipe: recipe,
                  cookingTime: vm?.cookingTime,
                ),
              ),
            );
          },
          backgroundColor: EggyColors.onyx,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'Start cooking',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTheme.caption.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: EggyColors.onyx.withValues(alpha: 0.3),
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final IEggRecipe recipe;
  final YolkOMeterViewModel? vm;
  const _MetricsRow({required this.recipe, this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EggyColors.alabaster,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetricItem(icon: Icons.speed_rounded, label: recipe.difficulty, title: 'Difficulty'),
          _MetricItem(icon: Icons.timer_outlined, label: vm?.formattedCookingTime ?? '5 min', title: 'Prep Time'),
          _MetricItem(icon: Icons.egg_alt_outlined, label: vm?.yolkLabel ?? 'Cooked', title: 'Goal'),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;

  const _MetricItem({required this.icon, required this.label, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: EggyColors.onyx.withValues(alpha: 0.3)),
        const SizedBox(height: 8),
        Text(title, style: AppTheme.caption.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class _PrefChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PrefChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? EggyColors.onyx : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? Colors.transparent : Colors.black.withValues(alpha: 0.05)),
        ),
        child: Text(
          label,
          style: AppTheme.caption.copyWith(
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : EggyColors.onyx.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
class _EggCrossSection extends StatelessWidget {
  final Color color;
  const _EggCrossSection({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CrossSectionPainter(yolkColor: color),
    );
  }
}

class _CrossSectionPainter extends CustomPainter {
  final Color yolkColor;
  _CrossSectionPainter({required this.yolkColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // 1. Egg White (The Outer Shell)
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final shellPath = Path()
      ..moveTo(center.dx, 0)
      ..quadraticBezierTo(size.width * 0.95, 0, size.width, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.95, size.height, center.dx, size.height)
      ..quadraticBezierTo(size.width * 0.05, size.height, 0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.05, 0, center.dx, 0)
      ..close();
    
    canvas.drawPath(shellPath, whitePaint);
    
    // Subtle shadow for depth
    canvas.drawPath(shellPath, Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    // 2. The Yolk (The Dynamic Heart)
    final yolkPaint = Paint()
      ..color = yolkColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(Offset(center.dx, center.dy + 8), 24, yolkPaint);

    // Highlight
    canvas.drawCircle(
      Offset(center.dx - 8, center.dy), 6,
      Paint()..color = Colors.white.withValues(alpha: 0.3)
    );
  }

  @override
  bool shouldRepaint(_CrossSectionPainter old) => old.yolkColor != yolkColor;
}
class _EggyToggle extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final Color activeColor;
  final Function(int) onChanged;

  const _EggyToggle({
    required this.labels,
    required this.selectedIndex,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, // Increased to "Normal" height
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth / 2) - 2;
          return Stack(
            children: [
              // Sliding Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: selectedIndex * width,
                child: Container(
                  width: width,
                  height: 40, // Match inner height
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Option Labels
              Row(
                children: List.generate(labels.length, (index) {
                  final isSelected = selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(index),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          labels[index],
                          style: AppTheme.caption.copyWith(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                            color: isSelected ? Colors.white : EggyColors.onyx.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;
  final Color activeColor;

  const _QuantitySelector({
    required this.count,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, // Normal height
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          _IconButton(icon: Icons.remove, onTap: () => onChanged(-1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$count',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w900, color: activeColor),
            ),
          ),
          _IconButton(icon: Icons.add, onTap: () => onChanged(1)),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: EggyColors.onyx.withValues(alpha: 0.3)),
      ),
    );
  }
}

class _SpeciesCarousel extends StatelessWidget {
  final EggSpecies selected;
  final ValueChanged<EggSpecies> onChanged;
  final Color activeColor;

  const _SpeciesCarousel({
    required this.selected,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Increased height for premium visuals
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: EggSpecies.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final species = EggSpecies.values[index];
          final theme = EggSpeciesTheme.registry[species]!;
          final isSelected = species == selected;

          return GestureDetector(
            onTap: () => onChanged(species),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 90,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.1),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // anti-gravity floating procedural egg
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: AntiGravityWrapper(
                        amplitude: isSelected ? 6 : 0,
                        speed: 3.5,
                        child: Center(
                          child: Container(
                            width: 36 * theme.visualScale,
                            height: 46 * theme.visualScale,
                            decoration: BoxDecoration(
                              color: theme.shellColor,
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(
                                  18 * theme.visualScale,
                                  (species == EggSpecies.quail ? 19 : (species == EggSpecies.goose ? 24 : 22)) * theme.visualScale,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(1, 4),
                                ),
                                BoxShadow(
                                  color: theme.shellColor.withValues(alpha: 0.5),
                                  blurRadius: 1,
                                  offset: const Offset(-1, -1),
                                ),
                              ],
                              gradient: RadialGradient(
                                center: const Alignment(-0.2, -0.4),
                                radius: 1.0,
                                colors: [
                                  Colors.white.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: species == EggSpecies.quail
                                ? CustomPaint(painter: _QuailMottlingPainter())
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      theme.label.toUpperCase(),
                      style: AppTheme.caption.copyWith(
                        fontSize: 8, // Slightly smaller to fit "WHITE HEN"
                        letterSpacing: 0.8,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                        color: isSelected ? EggyColors.onyx : EggyColors.onyx.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuailMottlingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF5D4037).withValues(alpha: 0.4);
    final random = math.Random(42);
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _NutritionSection extends StatelessWidget {
  final IEggRecipe recipe;
  final UserEggPreferences prefs;

  const _NutritionSection({required this.recipe, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final base = recipe.getBaseNutrition();
    final facts = base.scale(
      massGrams: prefs.massGrams,
      quantity: prefs.eggCount,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('NUTRITION DASHBOARD',
                      style: AppTheme.caption.copyWith(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                        color: EggyColors.onyx.withValues(alpha: 0.4),
                      )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: EggyColors.onyx.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${prefs.eggCount} SERVING',
                        style: AppTheme.caption.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: EggyColors.onyx.withValues(alpha: 0.6),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // --- Primary Macros (Hero Row) ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _MacroCard(
                      label: 'CALORIES',
                      value: facts.calories,
                      unit: 'kcal',
                      gradient: [EggyColors.vibrantYolk.withValues(alpha: 0.3), EggyColors.vibrantYolk.withValues(alpha: 0.1)],
                      icon: Icons.bolt_rounded,
                      color: EggyColors.onyx,
                      accentColor: Color(0xFFE6A300), // Darker yolk
                    ),
                    const SizedBox(width: 12),
                    _MacroCard(
                      label: 'PROTEIN',
                      value: facts.protein,
                      unit: 'g',
                      gradient: [EggyColors.champagne.withValues(alpha: 0.25), EggyColors.champagne.withValues(alpha: 0.1)],
                      icon: Icons.fitness_center_rounded,
                      color: EggyColors.onyx,
                      accentColor: EggyColors.champagne,
                    ),
                    const SizedBox(width: 12),
                    _MacroCard(
                      label: 'FATS',
                      value: facts.fatTotal,
                      unit: 'g',
                      gradient: [EggyColors.liquidGold.withValues(alpha: 0.2), EggyColors.liquidGold.withValues(alpha: 0.05)],
                      icon: Icons.opacity_rounded,
                      color: EggyColors.onyx,
                      accentColor: EggyColors.bronze,
                    ),
                    const SizedBox(width: 12),
                    _MacroCard(
                      label: 'CARBS',
                      value: facts.carbs,
                      unit: 'g',
                      gradient: [EggyColors.slate.withValues(alpha: 0.15), EggyColors.slate.withValues(alpha: 0.05)],
                      icon: Icons.bakery_dining_rounded,
                      color: EggyColors.onyx,
                      accentColor: EggyColors.slate,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Divider(color: Colors.black.withValues(alpha: 0.05)),
              const SizedBox(height: 16),

              // --- Secondary Micros (Detail Grid) ---
              _MicroDetailRow(label: 'Saturated Fat', value: facts.fatSaturated, unit: 'g', dv: (facts.fatSaturated / 20) * 100),
              _MicroDetailRow(label: 'Cholesterol', value: facts.cholesterol, unit: 'mg', dv: (facts.cholesterol / 300) * 100),
              _MicroDetailRow(label: 'Sodium', value: facts.sodium, unit: 'mg', dv: (facts.sodium / 2300) * 100),
              _MicroDetailRow(label: 'Potassium', value: facts.potassium, unit: 'mg', dv: (facts.potassium / 4700) * 100),

              const SizedBox(height: 24),
              
              // --- Professor's Insight (Glassmorphism Banner) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      EggyColors.champagne.withValues(alpha: 0.1),
                      EggyColors.champagne.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: EggyColors.champagne.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb_outline_rounded, size: 16, color: EggyColors.champagne),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        facts.dietInsight,
                        style: AppTheme.body.copyWith(
                          fontSize: 11,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: EggyColors.onyx.withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final List<Color> gradient;
  final IconData icon;
  final Color color;
  final Color accentColor;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.gradient,
    required this.icon,
    required this.color,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accentColor.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutExpo,
            builder: (context, val, _) => Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  val >= 10 ? val.toStringAsFixed(0) : val.toStringAsFixed(1),
                  style: AppTheme.headline.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: EggyColors.onyx,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: AppTheme.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: EggyColors.onyx.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: AppTheme.caption.copyWith(
              fontSize: 8,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w900,
              color: EggyColors.onyx.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _MicroDetailRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double dv;

  const _MicroDetailRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.dv,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: AppTheme.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: EggyColors.onyx.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    value.toStringAsFixed(value < 1 ? 2 : 0),
                    style: AppTheme.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: EggyColors.onyx,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: AppTheme.caption.copyWith(
                      fontSize: 9,
                      color: EggyColors.onyx.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 40,
            alignment: Alignment.centerRight,
            child: Text(
              '${dv.toStringAsFixed(0)}%',
              style: AppTheme.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: dv > 15 ? Colors.orange.shade700 : EggyColors.onyx.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodStepCard extends StatelessWidget {
  final int index;
  final RecipeStep step;
  final bool isLast;

  const _MethodStepCard({
    required this.index,
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator Column
          Column(
            children: [
              // The Number Bubble
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: EggyColors.vibrantYolk.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: EggyColors.vibrantYolk.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: AppTheme.headline.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: EggyColors.vibrantYolk,
                    ),
                  ),
                ),
              ),
              // The Connector Line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: EggyColors.champagne.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          // The Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: EggyColors.onyx.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step.title != null) ...[
                      Row(
                        children: [
                          Icon(
                            _getIconData(step.iconType),
                            size: 14,
                            color: EggyColors.onyx.withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.title!.toUpperCase(),
                              style: AppTheme.caption.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                color: EggyColors.onyx,
                              ),
                            ),
                          ),
                          if (step.isCookingStep)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'TIMER',
                                style: AppTheme.caption.copyWith(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: EggyColors.vibrantYolk,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            step.instruction,
                            style: AppTheme.body.copyWith(
                              fontSize: 14,
                              height: 1.6,
                              color: EggyColors.onyx.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(StepIconType type) {
    switch (type) {
      case StepIconType.egg: return Icons.egg_alt_outlined;
      case StepIconType.water: return Icons.water_drop_outlined;
      case StepIconType.heat: return Icons.local_fire_department_outlined;
      case StepIconType.butter: return Icons.opacity_outlined;
      case StepIconType.timerGo: return Icons.timer_outlined;
      case StepIconType.iceBath: return Icons.ac_unit_rounded;
      case StepIconType.whisk: return Icons.cyclone_rounded;
      case StepIconType.fold: return Icons.reply_all_rounded;
      case StepIconType.crack: return Icons.vignette_outlined;
      case StepIconType.plate: return Icons.restaurant_rounded;
      case StepIconType.salt: return Icons.grain_rounded;
      case StepIconType.vinegar: return Icons.science_outlined;
      case StepIconType.pan: return Icons.outdoor_grill_outlined;
      case StepIconType.pot: return Icons.soup_kitchen_outlined;
      case StepIconType.bowl: return Icons.soup_kitchen_outlined;
      case StepIconType.saucepan: return Icons.soup_kitchen_outlined;
      case StepIconType.muffin: return Icons.bakery_dining_outlined;
      case StepIconType.bacon: return Icons.lunch_dining_outlined;
      case StepIconType.spoon: return Icons.flatware_rounded;
      case StepIconType.spatula: return Icons.architecture_outlined;
      case StepIconType.sauce: return Icons.colorize_outlined;
      case StepIconType.knife: return Icons.flatware_rounded;
      default: return Icons.egg_alt_outlined;
    }
  }
}
