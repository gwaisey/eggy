import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/data_context.dart';
import 'vector_semantic_service.dart';

enum CAMAIntent { culinary_protocol, scientific_research, safety_governance, general }
enum UserArchetype { home_cook, scientific_pro, busy_parent }
enum UrgencyLevel { standard, high, emergency }

/// CAMA (Circular Associative Memory Architecture) v5.0
/// 
/// Developed for "Human-Brain" Contextual Grounding.
/// Now features the "Psychographic UX Layer" (Sentiment & Urgency).
class CAMAService {
  static const String _shelvesKey = 'eggy_molecular_journals';
  
  // ── Level 1: The Working Console (Short-term / Anaphora) ─────────
  String? _activeSubject; 
  final List<String> _entityStack = [];
  
  // ── Level 2: The Episodic Rack (Session Theme) ─────────────────────
  String? _sessionTheme; 
  
  // ── Level 3: The Semantic Library (Librarian / Vector Store) ────────
  VectorSemanticService? _librarian;

  // ── Level 4: The Psychographic Layer (UX / Persona) ────────────────
  UserArchetype _archetype = UserArchetype.home_cook;
  UrgencyLevel _urgency = UrgencyLevel.standard;
  double _sentimentScore = 0.5; // 0.0 (Angry) to 1.0 (Happy)
  
  // ── Attributes & Entities (Hidden Extraction Pass) ─────────────────
  final Map<String, Map<String, String>> _attributeBuffer = {};

  CAMAIntent _activeIntent = CAMAIntent.general;
  List<DataContext> _activeContexts = []; 
  bool _isSpeedOriented = false;
  bool _isSafetyConcerned = false;

  String? get activeSubject => _activeSubject;
  String? get sessionTheme   => _sessionTheme;
  CAMAIntent get activeIntent => _activeIntent;
  List<DataContext> get activeContexts => _activeContexts;
  bool get isSpeedOriented  => _isSpeedOriented;
  UrgencyLevel get urgency => _urgency;
  UserArchetype get archetype => _archetype;

  void initLibrarian(String apiKey) {
    _librarian ??= VectorSemanticService(apiKey);
  }

  void setContexts(List<DataContext> contexts) {
    if (contexts.isNotEmpty) {
      _activeContexts = contexts;
    }
  }

  /// v4.1 Entity Extraction Pass: Identifies noun entities and their attributes
  void _extractEntities(String message) {
    final msg = message.toLowerCase();
    
    // Entity: Egg
    if (msg.contains('egg')) {
      final eggAttrs = _attributeBuffer.putIfAbsent('Egg', () => {});
      if (msg.contains('big') || msg.contains('large') || msg.contains('massive') || msg.contains('huge')) {
        eggAttrs['size'] = 'Large (70g+)';
      } else if (msg.contains('small') || msg.contains('tiny')) {
        eggAttrs['size'] = 'Small (45g-53g)';
      }
      
      if (msg.contains('fridge') || msg.contains('cold')) {
        eggAttrs['state'] = 'Chilled (4°C)';
      }
    }

    // Entity: Technique
    if (msg.contains('boil') || msg.contains('poach') || msg.contains('fry')) {
      _attributeBuffer.putIfAbsent('Technique', () => {})['active'] = 
        msg.contains('boil') ? 'Boiling' : (msg.contains('poach') ? 'Poaching' : 'Frying');
    }
  }

  /// Ingests a user message with high-fidelity "Map" generation
  void updateConsole(String message) {
    final msg = message.toLowerCase();
    
    // 1. Entity Extraction Pass (The "Hidden" pass)
    _extractEntities(message);

    // 2. Strict Anaphora: Detection of Species and Culinary Nouns
    String? detected;
    
    // --- Bird & Monotreme Species (Exotic detection) ---
    if      (msg.contains('duck'))    detected = 'Duck Egg';
    else if (msg.contains('chicken') || msg.contains('hen')) detected = 'Hen Egg';
    else if (msg.contains('quail'))   detected = 'Quail Egg';
    else if (msg.contains('goose'))   detected = 'Goose Egg';
    else if (msg.contains('ostrich')) detected = 'Ostrich Egg';
    else if (msg.contains('monotreme') || msg.contains('platypus') || msg.contains('echidna')) detected = 'Monotreme Egg';
    else if (msg.contains('avian'))    detected = 'Avian Biology';
    
    // --- Recipes & Sauces ---
    else if (msg.contains('hollandaise') || msg.contains('lecithin')) detected = 'Hollandaise Sauce';
    else if (msg.contains('benedict'))    detected = 'Egg Benedict';
    else if (msg.contains('mayo'))        detected = 'Mayonnaise';
    else if (msg.contains('custard'))     detected = 'Custard';
    else if (msg.contains('omelette'))    detected = 'Omelette';
    
    // --- Egg Components (Implicit) ---
    else if (msg.contains('yolk') || msg.contains('vitellus')) detected = 'Egg Yolk';
    else if (msg.contains('white') || msg.contains('albumin')) detected = 'Egg White';
    else if (msg.contains('shell'))     detected = 'Egg Shell';
    else if (msg.contains('membrane'))  detected = 'Egg Membrane';

    if (detected != null) {
      // Sticky Subject Rule: Don't let generic 'Hen' overwrite specialized species like Duck/Quail
      bool isGeneric = (detected == 'Hen Egg');
      bool currentIsSpecialized = (_activeSubject != null && _activeSubject != 'Hen Egg' && _activeSubject!.contains('Egg'));
      
      if (!isGeneric || !currentIsSpecialized) {
        _activeSubject = detected;
      }
      _entityStack.remove(detected);
      _entityStack.insert(0, detected);
    }

    // 3. Level 4: Psychographic UX Detection
    final urgencyWords = ['now', 'quick', 'hurry', 'emergency', 'asap', 'help', 'burning', 'fire'];
    if (urgencyWords.any((w) => msg.contains(w))) {
      _urgency = UrgencyLevel.emergency;
      _isSpeedOriented = true;
    } else if (msg.length < 15 && msg.contains('?')) {
      _urgency = UrgencyLevel.high;
    } else {
      _urgency = UrgencyLevel.standard;
    }

    // Archetype Detection
    if (msg.contains('molecular') || msg.contains('data') || msg.contains('constant') || msg.contains('formula')) {
      _archetype = UserArchetype.scientific_pro;
    } else if (msg.contains('kid') || msg.contains('morning') || msg.contains('breakfast')) {
      _archetype = UserArchetype.home_cook;
    }

    // 4. Session Theme Tracking (Episodic Rack)
    if (_sessionTheme == null || msg.length > 25) {
      if (msg.contains('safe') || msg.contains('pregnant')) _sessionTheme = "Safety & Governance Research";
      else if (msg.contains('how') || msg.contains('perfect') || msg.contains('recipe')) _sessionTheme = "Culinary Protocol Optimization";
      else if (msg.contains('science') || msg.contains('why') || msg.contains('protein')) _sessionTheme = "Molecular Lab Inquiry";
    }

    // 4. Pragmatic Priming
    final tempMatch = RegExp(r'(\d+)\s*(?:c|degree|°|deg)').firstMatch(msg);
    if (tempMatch != null) {
      if ((int.tryParse(tempMatch.group(1)!) ?? 0) >= 90) _isSpeedOriented = true;
    }
    if (['fast', 'hurry', 'quick'].any((w) => msg.contains(w))) _isSpeedOriented = true;

    // 5. Intent Classification
    if (msg.contains('recipe') || msg.contains('cook') || msg.contains('make')) _activeIntent = CAMAIntent.culinary_protocol;
    else if (msg.contains('safe') || msg.contains('spoil') || msg.contains('bacteria')) {
      _activeIntent = CAMAIntent.safety_governance;
      _isSafetyConcerned = true;
    } 
    else if (msg.contains('why') || msg.contains('protein') || msg.contains('structure') || msg.contains('molecular') || msg.contains('denatur')) _activeIntent = CAMAIntent.scientific_research;

    if (_entityStack.length > 5) _entityStack.removeLast();
  }

  /// Normalizes "Plain Talk" into Scientific Categories
  String normalizeCulinaryTerms(String query) {
    final q = query.toLowerCase();
    if (q.contains('dippy')) return 'Lab Category: 62°C - 63°C (Liquid/Dippy state)';
    if (q.contains('jammy')) return 'Lab Category: 64°C - 65°C (Jammy state)';
    if (q.contains('firm'))  return 'Lab Category: 77°C+ (Coagulated state)';
    if (q.contains('fluffy')) return 'Lab Category: Lipid-Stabilized Foam';
    return "";
  }

  /// Strict Anaphora Resolution: Checks if the user's pronouns refer to the active stack.
  bool isReferencingActive(String message) {
    if (_entityStack.isEmpty) return false;
    final msg = message.toLowerCase();
    final pronouns = ['it', 'that', 'this', 'them', 'they', 'those', 'there'];
    final hasPronoun = pronouns.any((p) => 
      msg.contains(' $p ') || msg.endsWith(' $p') || msg.startsWith('$p ') || msg == p
    );
    final nouns = [
      'egg', 'duck', 'chicken', 'hen', 'quail', 'goose', 'ostrich',
      'hollandaise', 'benedict', 'mayo', 'custard', 'omelette',
      'yolk', 'white', 'shell', 'membrane'
    ];
    final hasNewNoun = nouns.any((n) => msg.contains(n));
    return hasPronoun || (!hasNewNoun && msg.split(' ').length < 6);
  }

  String? getAnaphoraTarget() {
    return _entityStack.isNotEmpty ? _entityStack.first : null;
  }

  /// v4.1 Enriched Snapshot for Prompt Injection
  String getContextPayload() {
    List<String> payload = [];
    payload.add("SESSION_THEME: ${_sessionTheme ?? 'General Inquiry'}");
    payload.add("ACTIVE_ENTITY: ${_activeSubject ?? 'Hen Egg'}");
    
    final currentTarget = getAnaphoraTarget();
    if (currentTarget != null) {
      payload.add("ANAPHORA_RESOLUTION: If the user used a pronoun (it, that, etc.), it refers to: $currentTarget.");
    }
    
    _attributeBuffer.forEach((entity, attrs) {
      if (attrs.isNotEmpty) {
        payload.add("ENTITY_ATTRIBUTES ($entity): ${attrs.entries.map((e) => "${e.key}=${e.value}").join(', ')}");
      }
    });

    if (_isSpeedOriented) payload.add("PRAGMATIC_INTENT: Speed optimization detected (Priority: Fast/Hot)");
    if (_isSafetyConcerned) payload.add("GOVERNANCE_STATE: Critical Safety/Spoilage context active");

    final mode = "DIRECT_ASSISTANT (Precise, Helpful, No Preamble)";
    
    payload.add("UX_INSIGHTS: [Recommended Mode: $mode]");

    return payload.join("\n");
  }

  /// Extract thermal coagulation threshold from message intent
  double? getThermalThreshold(String message) {
    final msg = message.toLowerCase();
    
    // Explicit temperature mapping (e.g. 64°C, 64 degree, 64 c)
    final tempMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:c|degree|°|deg)').firstMatch(msg);
    if (tempMatch != null) {
      final temp = double.tryParse(tempMatch.group(1)!) ?? 0.0;
      if (temp < 50) return 0.05;
      if (temp < 60) return 0.20;
      if (temp < 64) return 0.45;
      if (temp < 66) return 0.65;
      if (temp < 77) return 0.85;
      return 0.98;
    }

    // Molecular & Keyword mapping
    if (msg.contains('denatur') || msg.contains('transition')) return 0.65;
    if (msg.contains('solidif') || msg.contains('rigid')) return 0.95;
    if (msg.contains('dippy') || msg.contains('liquid') || msg.contains('fluid')) return 0.15;
    if (msg.contains('jammy') || msg.contains('custard') || msg.contains('creamy')) return 0.65;
    if (msg.contains('firm') || msg.contains('set')) return 0.85;
    if (msg.contains('hard') || msg.contains('sulfur') || msg.contains('rubbery')) return 0.98;
    
    return null;
  }

  /// Semantically records a lesson for future recall
  Future<void> ingestCulinaryLesson(String lesson, String subject) async {
    if (_librarian != null) {
      await _librarian!.ingest(lesson, metadata: {'subject': subject, 'type': 'user_interaction'});
    }
  }

  /// Semantic Longitudinal Recall: Finds relevant past knowledge
  Future<String> getLongitudinalSummary(String currentMessage) async {
    if (_librarian == null) return "";
    
    final matches = await _librarian!.query(currentMessage, limit: 5);
    String semantic = "";
    if (matches.isNotEmpty) {
      semantic = "SEMANTIC_MEMORY: " + matches.map((m) => m.text).join(" | ");
    }
    
    return semantic;
  }
}
