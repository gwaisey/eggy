import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/interfaces/i_conversation_service.dart';
import '../../core/models/chat_suggestion.dart';
import '../../core/models/app_state.dart';
import '../../core/utils/string_utils.dart';
import '../mascot/eggy_mascot_controller.dart';
import '../mascot/mascot_theme.dart';
import 'scientific_context_service.dart';
import 'persistence_service.dart';
import '../../core/constants.dart';
import 'cama_service.dart';
import 'web_research_service.dart';
import '../physics/thermal_state.dart';
import '../physics/thermal_heatmap.dart';
import '../../core/interfaces/i_web_research_service.dart';
import '../../core/models/data_context.dart';
import '../preferences/preferences_view_model.dart';

// â”€â”€ Exceptions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class QuotaExceededException implements Exception {
  final String message;
  QuotaExceededException(this.message);
  @override
  String toString() => message;
}

// â”€â”€ Alert System Models â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
enum AlertLevel { critical, caution, standard }

class AlertMatcher {
  static AlertLevel getLevel(String query) {
    final q = query.toLowerCase();
    
    // Tier 1: Critical (Bacteria/Health)
    if (['rotten', 'smell', 'expired', 'bad taste', 'off flavor', 'mold', 'sulfur'].any(q.contains)) {
      return AlertLevel.critical;
    }
    
    // Tier 2: Caution (Old/Quality Risk)
    if (['float', 'old', 'cloudy', 'off color', 'age'].any(q.contains)) {
      return AlertLevel.caution;
    }
    
    // Tier 3: Standard (Mishap/Technique)
    return AlertLevel.standard;
  }
}

// â”€â”€ Phase 1: Scripted (Local JSON, no API, no hallucination) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ScriptedResponseService implements IConversationService {
  Map<String, List<String>> _responses = {};
  bool _loaded = false;
  final _random = math.Random();
  String? _lastSubject;

  @override
  bool get isAIBacked => false;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/data/chat_responses.json');
    final Map<String, dynamic> rawJson = json.decode(raw);
    
    final sortedKeys = rawJson.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    
    _responses = {
      for (var k in sortedKeys) 
        k: (rawJson[k] is List) 
            ? List<String>.from(rawJson[k]) 
            : [rawJson[k].toString()]
    };
    _loaded = true;
  }

  final Map<String, int> _lastResponseIndices = {};

  final List<String> _generalBridges = [""];

  final List<String> _recipeBridges = [""];

  List<String> _extractAllKeywords(String query) {
    return _responses.keys.where((k) => query.contains(k)).toList();
  }

  String _findBestIntersection(List<String> matches, String lowerQuery) {
    if (matches.contains('duck') && (lowerQuery.contains('salt') || lowerQuery.contains('brine'))) {
      return 'salted_duck';
    }
    matches.sort((a, b) => b.length.compareTo(a.length));
    return matches.first;
  }

  @override
  Future<String> getResponse(String userMessage) async {
    await load();
    final lower = userMessage.toLowerCase();
    
    final tempMatch = RegExp(r'(\d+)\s*(?:c|degree|Â°|deg)').firstMatch(lower);
    int? tempValue = tempMatch != null ? int.tryParse(tempMatch.group(1)!) : null;
    final hasPronoun = [' it ', ' that ', ' this ', ' them ', ' it\'s ', ' its '].any((p) => lower.contains(p)) ||
                       lower.startsWith('it ') || lower.endsWith(' it');
    List<String> matches = _extractAllKeywords(lower);

    String keyToUse = 'default';
    String prefix = _generalBridges[_random.nextInt(_generalBridges.length)];

    if (matches.contains('snake') || matches.contains('reptile')) keyToUse = 'reptile_egg';
    else if (matches.contains('choline') || lower.contains('brain') || lower.contains('b12')) keyToUse = 'choline_science';
    else if (matches.contains('phase') || lower.contains('separation')) keyToUse = 'phase_separation';
    else if (matches.contains('antibiotic') || matches.contains('amr')) keyToUse = 'one_health';
    else if (matches.contains('salut') || matches.contains('embryo')) keyToUse = 'balut_science';
    else if (tempValue != null) {
      if (tempValue < 62) keyToUse = "coag_liquid";
      else if (tempValue <= 65) keyToUse = "coag_jammy";
      else if (tempValue <= 76) keyToUse = "coag_firm";
      else keyToUse = "coag_high";
      prefix = "Looking at the science of temperature... ";
    }
    else if (matches.isNotEmpty) {
      keyToUse = _findBestIntersection(matches, lower);
      if (keyToUse.contains('recipe')) prefix = _recipeBridges[_random.nextInt(_recipeBridges.length)];
    }
    else if (hasPronoun && _lastSubject != null) {
      keyToUse = _lastSubject!;
      prefix = "Regarding that ${_lastSubject!} we were discussing... ";
    }

    if (['duck', 'ostrich', 'quail', 'hen'].contains(keyToUse)) {
      _lastSubject = keyToUse;
    }

    final variations = _responses[keyToUse] ?? _responses['default']!;
    int index = _random.nextInt(variations.length);
    if (variations.length > 1 && index == _lastResponseIndices[keyToUse]) {
      index = (index + 1) % variations.length;
    }
    _lastResponseIndices[keyToUse] = index;
    
    return variations[index];
  }

  @override
  @override
  List<ChatSuggestion> getSuggestedPrompts({bool isProfessorMode = false}) => [
    const ChatSuggestion(text: 'My eggs are straight from the fridge', icon: Icons.ac_unit_rounded),
    const ChatSuggestion(text: 'How do I know the water is ready', icon: Icons.water_drop_rounded),
    const ChatSuggestion(text: 'My omelette keeps sticking', icon: Icons.pan_tool_alt_rounded),
    const ChatSuggestion(text: 'How do I get a runny yolk', icon: Icons.opacity_rounded),
    const ChatSuggestion(text: 'What makes scrambled eggs fluffy', icon: Icons.cloud_queue_rounded),
  ];
}

// ── Phase 2: OpenRouter AI (OpenAI Compatible) ──────────────────────────────────────────────────

class EggyAIService implements IConversationService {
  final String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  Future<WebResearchResult> Function(String)? onSearchRequest;
  void Function(String)? onPredictionGenerated;

  @override
  bool get isAIBacked => true;

  static const _systemPrompt = r'''
You are a professional assistant specializing in avian biology and egg-culinary science.
1. CONTEXT: For all scientific inquiries (especially in Professor mode), assume the topic is within your specialized egg/avian domain even if not explicitly stated.
2. SCOPE: You answer questions about eggs, broad avian science, bird biology, and egg-based culinary techniques. If truly off-topic, politely redirect to your specialized field.
3. STYLE: Start with the direct answer. No intros. Keep it classy and professional.
4. INFRASTRUCTURE: Never disclose your AI provider or technical details.
''';

  @override
  Future<String> getResponse(String userMessage) async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    final modelToUse = dotenv.env['OPENROUTER_MODEL'] ?? 'meta-llama/llama-3.3-70b-instruct:free';
    
    if (apiKey.isEmpty || apiKey == 'your_openrouter_key_here') {
      throw Exception('AI API key not set in .env');
    }

    // We try two paths to handle potential rate limits:
    // 1. Your preferred Llama model from .env
    // 2. The OpenRouter Free Auto-Router as a resilient fallback
    final models = [
      modelToUse,
      'openrouter/free', 
    ];

    String? lastError;

    for (var model in models) {
      try {
        for (var attempt = 0; attempt < 2; attempt++) {
          final prompt = attempt == 0 ? _systemPrompt : "Answer this about eggs: $userMessage";
          
          final response = await http.post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://eggy.app',
              'X-Title': 'Eggy App',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'system', 'content': prompt},
                {'role': 'user', 'content': userMessage},
              ],
              'temperature': 0.7,
              'max_tokens': 1000,
            }),
          ).timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final content = data['choices'][0]['message']['content'] as String;
            return content.trim().scrubEmojis();
          } else if (response.statusCode == 400 && attempt == 0) {
            print('AI: $model rejected system prompt, retrying with minimalist fallback...');
            continue; 
          } else if (response.statusCode == 429 && model != models.last) {
            print('AI: $model rate limited (429), trying fallback model...');
            break; // Try the fallback model
          } else {
            lastError = 'Error ${response.statusCode}: ${response.body}';
            break; // Try next model in the outer loop
          }
        }
      } catch (e) {
        lastError = e.toString();
        print('AI Request Failed for $model: $e');
      }
    }

    throw Exception('Failed to get response. Last error: $lastError');
  }

  @override
  List<ChatSuggestion> getSuggestedPrompts({bool isProfessorMode = false}) {
    if (isProfessorMode) {
      return [
        const ChatSuggestion(text: 'Avian nesting & egg incubation science', icon: Icons.science_rounded),
        const ChatSuggestion(text: 'Molecular structure of shell density', icon: Icons.biotech_rounded),
        const ChatSuggestion(text: 'Osmosis eggsperiment protocol', icon: Icons.science_rounded),
        const ChatSuggestion(text: 'Hollandaise emulsification science', icon: Icons.soup_kitchen_rounded),
      ];
    }
    return [
      const ChatSuggestion(text: 'Silky scrambled egg technique', icon: Icons.restaurant_menu_rounded),
      const ChatSuggestion(text: 'Velvety French Omelette technique', icon: Icons.restaurant_menu_rounded),
      const ChatSuggestion(text: 'How to perfectly slice a soft egg', icon: Icons.soup_kitchen_rounded),
      const ChatSuggestion(text: 'Floating egg freshness test 101', icon: Icons.science_rounded),
    ];
  }
}

// â”€â”€ Chat ViewModel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ChatMessage {
  final String text;
  final bool isUser;
  final AlertLevel alertLevel;
  final DateTime timestamp;
  final String? rawError;
  final List<DataContext>? contexts;
  final String? suggestion;
  final ThermalState? thermalState;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.alertLevel = AlertLevel.standard,
    this.rawError,
    this.contexts,
    this.suggestion,
    this.thermalState,
  }) : timestamp = DateTime.now();
  
  bool get hasTrustedContext => contexts != null && contexts!.any((c) => c.trustScore >= 0.9);
}

class EggyChatViewModel extends ChangeNotifier {
  final IConversationService _aiService;
  final ScriptedResponseService _localService;
  final EggyMascotController _mascotController;
  final ScientificContextService _contextService = ScientificContextService();
  final PersistenceService _persistenceService = PersistenceService();
  final CAMAService _cama = CAMAService();
  final IWebResearchService _webResearch = WebResearchService();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isTumbling = false;
  List<String> _researchBreadcrumbs = [];
  bool _initialized = false;
  String? _nextSuggestion;
  bool _disposed = false;

  EggyChatViewModel(this._aiService, this._localService, this._mascotController);

  Future<void> initialize() async {
    if (_initialized) return;
    await _contextService.init();
    final savedHistory = await _persistenceService.loadHistory();
    _messages.addAll(savedHistory);
    
    if (_aiService is EggyAIService) {
      final ai = _aiService as EggyAIService;
      // Note: Semantic and tool wiring will be simplified for this phase.
      _initialized = true;
    }
    _initialized = true;
    if (!_disposed) notifyListeners();
  }
  
  EggyAppState _appState = EggyAppState.unknown();

  List<ChatMessage> get messages       => List.unmodifiable(_messages);
  bool get isTyping                    => _isTyping;
  bool get isTumbling                  => _isTumbling;
  List<String> get researchBreadcrumbs => _researchBreadcrumbs;
  bool get isAIBacked                  => _aiService.isAIBacked;
  List<ChatSuggestion> get suggestedPrompts => _aiService.getSuggestedPrompts(isProfessorMode: isProfessorMode);
  
  bool get isProfessorMode => _mascotController.isProfessorMode;

  void toggleProfessorMode(PreferencesViewModel prefs) {
    final newState = !isProfessorMode;
    prefs.setProfessorMode(newState);
    _mascotController.setProfessorMode(newState);
    notifyListeners();
  }

  void updateAppState(EggyAppState state) {
    _appState = state;
    if (!_disposed) notifyListeners();
  }

  String _handleBoredom() {
    final recipes = ['Omelette', 'Fried', 'Poached', 'Scrambled', 'Boiled'];
    final suggestion = recipes[DateTime.now().second % recipes.length];
    return "Bored of the usual? The $suggestion recipe is calling your name!";
  }

  String _processResponse(String rawAiOutput) {
    if (rawAiOutput.toLowerCase().contains('outside my shell')) {
      _triggerTumble();
    }
    return rawAiOutput;
  }

  void _triggerTumble() {
    _isTumbling = true;
    if (!_disposed) notifyListeners();
    Future.delayed(const Duration(milliseconds: 1500), () {
      _isTumbling = false;
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (!_initialized) await initialize();
    _mascotController.resetMood();

    final lower = text.toLowerCase();
    final isBored = lower.contains('bored') || lower.contains('nothing to do') || lower.contains('tired of');

    final alertLevel = AlertMatcher.getLevel(text);
    _messages.add(ChatMessage(text: text, isUser: true));
    _isTyping = true;
    if (!_disposed) notifyListeners();

    String responseText;
    AlertLevel finalLevel = alertLevel;
    String? capturedRawError;
    List<DataContext> activeContexts = [];

    if (isBored) {
      responseText = _handleBoredom();
    } else {
      try {
        _cama.updateConsole(text);
        
        // --- PHASE 1: RESEARCH (The Librarian Pass) ---
        final bool isProfessor = _mascotController.isProfessorMode;
        final bool isScientific = _cama.activeIntent == CAMAIntent.scientific_research || _cama.activeIntent == CAMAIntent.safety_governance;
        
        String? researchContext;
        if (isProfessor || isScientific) {
          _researchBreadcrumbs = ["Scanning Global Research Hub...", "Accessing Nature & PubMed archives..."];
          if (!_disposed) notifyListeners();
          
          final result = await _webResearch.investigate(text, []);
          _researchBreadcrumbs = result.breadcrumbs;
          if (!_disposed) notifyListeners();
          
          if (result.trustScore > 0.6) {
            researchContext = "TRUSTED_RESEARCH (Source: ${result.source}): ${result.content}";
          }
          await Future.delayed(const Duration(milliseconds: 800)); // Aesthetic pause
        } else {
          _researchBreadcrumbs = ["Synthesizing precise response...", "Recalling deep-context history..."];
          if (!_disposed) notifyListeners();
        }

        // --- PHASE 2: SYNTHESIS (The AI Pass) ---
        final longitudinalSummary = await _cama.getLongitudinalSummary(text);
        final contextualQuery = _buildContextualQuery(text, 
            longitudinalSummary: longitudinalSummary,
            researchContext: researchContext,
            history: _messages);
        
        final rawResponse = await _aiService.getResponse(contextualQuery);
        responseText = _processResponse(rawResponse);

        // Success Recognition: Trigger Celebration if keywords detected
        if (responseText.contains('MASTERPIECE') || responseText.contains('PROTOCOL_SUCCESS')) {
          _mascotController.celebrate();
          responseText = responseText
              .replaceAll('MASTERPIECE', '')
              .replaceAll('PROTOCOL_SUCCESS', '')
              .trim();
        }
        
        // Ingest the lesson for future semantic recall
        await _cama.ingestCulinaryLesson("User: $text | Eggy: $responseText", _cama.activeSubject ?? "Egg Science");
        
        _isTyping = false;
        _researchBreadcrumbs = [];
        
        // Use the existing isProfessor variable declared earlier in the method
        ThermalState? thermalState;
        
        if (isProfessor) {
          final threshold = _cama.getThermalThreshold(responseText) ?? _cama.getThermalThreshold(text);
          final speciesLabel = _cama.activeSubject?.split(' ').first.toLowerCase() ?? 'hen';
          final species = EggSpecies.values.firstWhere(
            (e) => e.name.toLowerCase().contains(speciesLabel),
            orElse: () => EggSpecies.henWhite
          );
          thermalState = threshold != null ? ThermalState(threshold: threshold, species: species) : null;
        }

        _addMessage(responseText, finalLevel, 
                contexts: [], // No local contexts in Pure AI mode
                rawError: capturedRawError, 
                suggestion: _nextSuggestion,
                thermalState: thermalState);
        _nextSuggestion = null;
        await _persistenceService.saveHistory(_messages);
      } catch (e) {
        _isTyping = false;
        _researchBreadcrumbs = [];
        
        capturedRawError = e.toString();
        print("AI ERROR: $e");
        
        responseText = "Eggy's having a bit of a wobble connecting to the servers. Please check your internet or try again in a moment!";
        
        _addMessage(responseText, finalLevel, 
                contexts: activeContexts, 
                rawError: capturedRawError, 
                suggestion: _nextSuggestion);
        _nextSuggestion = null;
        if (!_disposed) notifyListeners();
      }
    }
  }

  String _buildContextualQuery(String userQuery, {
    String longitudinalSummary = "",
    String? researchContext,
    List<ChatMessage> history = const [],
  }) {
    final state = _appState;
    final contextPayload = _cama.getContextPayload();
    
    final bool isProfessor = _mascotController.isProfessorMode;
    final String personaInstructions = isProfessor 
      ? "You are an EGG & AVIAN PROFESSOR. Focus on molecular structure, thermal dynamics, avian biology, and chemical safety. Be academic but direct."
      : "You are a COOKING EGG ASSISTANT. Focus on kitchen utility, techniques, and practical cooking advice. Be cozy but direct.";

    // Extra-Mile: Transparent History Injection (Last 6 turns)
    final recentWindow = history.length > 6 ? history.sublist(history.length - 6) : history;
    final transcript = recentWindow.map((m) => "${m.isUser ? 'USER' : 'EGGY'}: ${m.text}").join("\n");

    return """
[USER MESSAGE]
$userQuery

[ACTIVE_SUBJECT]
${_cama.activeSubject ?? "Not explicitly defined"}

[RECENT DIALOGUE TRANSCRIPT]
$transcript

[MENTAL STATE / CONTEXT]
$contextPayload
- Long-term Memory: $longitudinalSummary
- Active Recipe: ${state.activeRecipe}

[EXTERNAL_RESEARCH_DATA]
${researchContext ?? "No external data needed for this query."}

[INSTRUCTIONS]
$personaInstructions
The user is continuing a specific inquiry. 
- You MUST answer for the [ACTIVE_SUBJECT] specifically if the user query is generic.
- CRITICAL: If the topic is NOT about eggs or avian science, stay in character but explain that your expertise is limited to the wonderful world of eggs and birds.
- CRITICAL: NO INTROS. NO GREETINGS. NO Hallucinating technical details about your creation.
- Resolve ordinals from the [RECENT DIALOGUE TRANSCRIPT].
- If [EXTERNAL_RESEARCH_DATA] is provided, prioritize it for scientific accuracy.
""";
  }

  void _addMessage(String text, AlertLevel level, {
    List<DataContext>? contexts, 
    String? rawError, 
    String? suggestion,
    ThermalState? thermalState,
  }) {
    _messages.add(ChatMessage(
      text: text, 
      isUser: false, 
      alertLevel: level,
      rawError: rawError,
      contexts: contexts,
      suggestion: suggestion,
      thermalState: thermalState,
    ));
    if (!_disposed) notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
