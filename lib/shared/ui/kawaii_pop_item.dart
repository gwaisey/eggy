import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/models/recipe_models.dart';
import 'app_theme.dart';
import 'step_icon.dart';

/// A robust, interactive item for the Mission Briefing.
/// Features a flattened gesture hierarchy for 100% reliable tapping on all platforms.
class KawaiiPopItem extends StatefulWidget {
  final PrepItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final int index; // For staggered entry animation

  const KawaiiPopItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<KawaiiPopItem> createState() => _KawaiiPopItemState();
}

class _KawaiiPopItemState extends State<KawaiiPopItem> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _entryController;
  late Animation<double> _entryScale;
  late Animation<double> _entryOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _entryScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );

    _entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    // Staggered start
    Future.delayed(Duration(milliseconds: 400 + (widget.index * 50)), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _pulseController.forward().then((_) => _pulseController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entryOpacity,
      child: ScaleTransition(
        scale: _entryScale,
        child: Padding(
          padding: const EdgeInsets.all(4.0), // Slight padding to avoid border clipping during scale
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(24),
              splashColor: EggyColors.vibrantYolk.withValues(alpha: 0.2),
              highlightColor: Colors.transparent,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                  CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
                ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isSelected 
              ? EggyColors.vibrantYolk.withValues(alpha: 0.1) 
              : EggyColors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isSelected 
                ? EggyColors.vibrantYolk 
                : EggyColors.white.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: widget.isSelected ? [
            BoxShadow(
              color: EggyColors.vibrantYolk.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ] : null,
        ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // The Icon
                        Expanded(
                          child: Center(
                            child: Opacity(
                              opacity: widget.isSelected ? 1.0 : 0.8,
                              child: StepIcon(
                                type: widget.item.iconType,
                                size: 64,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // The Label
                        Text(
                          widget.item.name,
                          style: AppTheme.caption.copyWith(
                            fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                            color: widget.isSelected 
                                ? EggyColors.onyx 
                                : EggyColors.softCharcoal.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.item.quantity != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.item.quantity!,
                            style: AppTheme.caption.copyWith(
                              fontSize: 9,
                              color: EggyColors.softCharcoal.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
