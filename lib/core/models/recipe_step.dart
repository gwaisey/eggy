import 'step_icon_type.dart';
import 'data_context.dart';
export 'step_icon_type.dart';
export 'data_context.dart';

/// A single step in a recipe's instruction flow.
///
/// [isCookingStep] — when true, the PrepGuideScreen shows "Start Timer"
/// instead of "Next", and after the timer completes it returns to the next step.
/// 
/// [context] — Optional Data Context Pack (Metadata, Lineage, etc.)
class RecipeStep {
  final String instruction;
  final StepIconType iconType;
  final bool isCookingStep;
  final Duration? customDuration;
  final DataContext? context;

  const RecipeStep({
    required this.instruction,
    this.iconType = StepIconType.egg,
    this.isCookingStep = false,
    this.customDuration,
    this.context,
  });
}
