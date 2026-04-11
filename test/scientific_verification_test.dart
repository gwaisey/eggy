import 'package:flutter_test/flutter_test.dart';
import '../lib/features/recipes/egg_recipes.dart';
import '../lib/core/egg_physics_engine.dart';

void main() {
  test('BoiledEgg Lineage Test - Verify Williams Formula 1992 citation', () {
    final engine = EggPhysicsEngine();
    final recipe = BoiledEgg(engine);
    final steps = recipe.getStepInstructions();
    
    // Step 3 (index 2) is the timer step in BoiledEgg
    final timerStep = steps[2];
    
    expect(timerStep.instruction, contains('start the Eggy timer'));
    expect(timerStep.context, isNotNull);
    expect(timerStep.context?.lineage['dc:source'], equals('University of Exeter'));
    expect(timerStep.context?.lineage['dc:date'], equals('1992'));
    expect(timerStep.context?.metadata['Property'], equals('Williams_Equation'));
  });

  test('EggsBenedict Safety Test - Verify Hollandaise Governance', () {
    final engine = EggPhysicsEngine();
    final recipe = EggsBenedict(engine);
    final steps = recipe.getStepInstructions();
    
    // Step 4 (index 3) is the Hollandaise step
    final hollandaiseStep = steps[3];
    
    expect(hollandaiseStep.instruction, contains('Hollandaise'));
    expect(hollandaiseStep.context, isNotNull);
    expect(hollandaiseStep.context?.classification, equals('Safety'));
    expect(hollandaiseStep.context?.policy, equals('Safety_Override_Protocol'));
  });
}
