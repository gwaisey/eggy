/// Describes the animated icon style for a prep step.
/// The UI renders these as bespoke Flutter icon animations — no image generation needed.
enum StepIconType {
  egg,       // Raw egg
  water,     // Filling with water / vinegar
  heat,      // Fire / heating up
  butter,    // Butter melting in pan
  timerGo,   // The "isCookingStep" — rotating timer
  iceBath,   // Ice cube / cooling
  whisk,     // Whisking motion
  fold,      // Folding omelette / eggs
  crack,     // Cracking egg into pan
  plate,     // Plating / done
}
