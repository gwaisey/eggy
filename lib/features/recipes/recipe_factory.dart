import '../../core/constants.dart';
import '../../core/interfaces/i_egg_recipe.dart';
import '../../core/egg_physics_engine.dart';
import 'egg_recipes.dart';

/// Factory Pattern: creates the correct IEggRecipe from a CookingMethod.
/// The UI never instantiates recipe classes directly — always goes through here.
class RecipeFactory {
  final EggPhysicsEngine _engine;

  RecipeFactory(this._engine);

  IEggRecipe create(CookingMethod method) {
    switch (method) {
      case CookingMethod.boiled:    return BoiledEgg(_engine);
      case CookingMethod.scrambled: return ScrambledEgg(_engine);
      case CookingMethod.poached:   return PoachedEgg(_engine);
      case CookingMethod.omelette:  return Omelette(_engine);
      case CookingMethod.fried:     return FriedEgg(_engine);
      case CookingMethod.benedict:  return EggsBenedict(_engine);
      case CookingMethod.soySauceEgg: return SoySauceEgg(_engine);
    }
  }

  List<IEggRecipe> get all => [
    BoiledEgg(_engine),
    SoySauceEgg(_engine),
    ScrambledEgg(_engine),
    PoachedEgg(_engine),
    Omelette(_engine),
    FriedEgg(_engine),
    EggsBenedict(_engine),
  ];
}
