import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/interfaces/i_conversation_service.dart';
import '../../core/models/chat_suggestion.dart';
import '../../core/models/app_state.dart';
import '../../core/utils/string_utils.dart';
import '../mascot/eggy_mascot_controller.dart';
import 'scientific_context_service.dart';
import 'persistence_service.dart';
import '../../core/constants.dart';
import 'cama_service.dart';
import 'web_research_service.dart';
import '../physics/thermal_state.dart';
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
    if ([
      'rotten',
      'smell',
      'expired',
      'bad taste',
      'off flavor',
      'mold',
      'sulfur'
    ].any(q.contains)) {
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
    if (matches.contains('duck') &&
        (lowerQuery.contains('salt') || lowerQuery.contains('brine'))) {
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
    int? tempValue =
        tempMatch != null ? int.tryParse(tempMatch.group(1)!) : null;
    final hasPronoun = [
          ' it ',
          ' that ',
          ' this ',
          ' them ',
          ' it\'s ',
          ' its '
        ].any((p) => lower.contains(p)) ||
        lower.startsWith('it ') ||
        lower.endsWith(' it');
    List<String> matches = _extractAllKeywords(lower);

    String keyToUse = 'default';
    String prefix = _generalBridges[_random.nextInt(_generalBridges.length)];

    if (matches.contains('snake') || matches.contains('reptile'))
      keyToUse = 'reptile_egg';
    else if (matches.contains('choline') ||
        lower.contains('brain') ||
        lower.contains('b12'))
      keyToUse = 'choline_science';
    else if (matches.contains('phase') || lower.contains('separation'))
      keyToUse = 'phase_separation';
    else if (matches.contains('antibiotic') || matches.contains('amr'))
      keyToUse = 'one_health';
    else if (matches.contains('salut') || matches.contains('embryo'))
      keyToUse = 'balut_science';
    else if (tempValue != null) {
      if (tempValue < 62)
        keyToUse = "coag_liquid";
      else if (tempValue <= 65)
        keyToUse = "coag_jammy";
      else if (tempValue <= 76)
        keyToUse = "coag_firm";
      else
        keyToUse = "coag_high";
      prefix = "Looking at the science of temperature... ";
    } else if (matches.isNotEmpty) {
      keyToUse = _findBestIntersection(matches, lower);
      if (keyToUse.contains('recipe'))
        prefix = _recipeBridges[_random.nextInt(_recipeBridges.length)];
    } else if (hasPronoun && _lastSubject != null) {
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
        const ChatSuggestion(
            text: 'My eggs are straight from the fridge',
            icon: Icons.ac_unit_rounded),
        const ChatSuggestion(
            text: 'How do I know the water is ready',
            icon: Icons.water_drop_rounded),
        const ChatSuggestion(
            text: 'My omelette keeps sticking',
            icon: Icons.pan_tool_alt_rounded),
        const ChatSuggestion(
            text: 'How do I get a runny yolk', icon: Icons.opacity_rounded),
        const ChatSuggestion(
            text: 'What makes scrambled eggs fluffy',
            icon: Icons.cloud_queue_rounded),
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
    // 1. Check dart-define first (Standard for Vercel/Production)
    // 2. Fallback to .env (Standard for Local Development)
    final apiKey = const String.fromEnvironment('OPENROUTER_API_KEY').isNotEmpty
        ? const String.fromEnvironment('OPENROUTER_API_KEY')
        : (dotenv.env['OPENROUTER_API_KEY'] ?? '');

    final modelToUse =
        const String.fromEnvironment('OPENROUTER_MODEL').isNotEmpty
            ? const String.fromEnvironment('OPENROUTER_MODEL')
            : (dotenv.env['OPENROUTER_MODEL'] ??
                'meta-llama/llama-3.3-70b-instruct:free');

    if (apiKey.isEmpty || apiKey == 'your_openrouter_key_here') {
      throw Exception('AI API key not set (checked --dart-define and .env)');
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
          final prompt = attempt == 0
              ? _systemPrompt
              : "Answer this about eggs: $userMessage";

          final response = await http
              .post(
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
              )
              .timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final content = data['choices'][0]['message']['content'] as String;
            return content.trim().scrubEmojis();
          } else if (response.statusCode == 400 && attempt == 0) {
            print(
                'AI: $model rejected system prompt, retrying with minimalist fallback...');
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
        const ChatSuggestion(
            text: 'Avian nesting & egg incubation science',
            icon: Icons.science_rounded),
        const ChatSuggestion(
            text: 'Molecular structure of shell density',
            icon: Icons.biotech_rounded),
        const ChatSuggestion(
            text: 'Osmosis eggsperiment protocol', icon: Icons.science_rounded),
        const ChatSuggestion(
            text: 'Hollandaise emulsification science',
            icon: Icons.soup_kitchen_rounded),
      ];
    }
    return [
      const ChatSuggestion(
          text: 'Silky scrambled egg technique',
          icon: Icons.restaurant_menu_rounded),
      const ChatSuggestion(
          text: 'Velvety French Omelette technique',
          icon: Icons.restaurant_menu_rounded),
      const ChatSuggestion(
          text: 'How to perfectly slice a soft egg',
          icon: Icons.soup_kitchen_rounded),
      const ChatSuggestion(
          text: 'Floating egg freshness test 101', icon: Icons.science_rounded),
    ];
  }
}

// â”€â”€ Chat ViewModel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ChatMessage {
  final String text;
  final bool isUser;
  final AlertLevel alertLevel;
  final String? rawError;
  final List<DataContext>? contexts;
  final String? suggestion;
  final ThermalState? thermalState;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.alertLevel = AlertLevel.standard,
    this.rawError,
    this.contexts,
    this.suggestion,
    this.thermalState,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get hasTrustedContext =>
      contexts != null && contexts!.any((c) => c.trustScore >= 0.9);
}

enum ChatDraftStatus { empty, modified, persisted }

class ChatSessionState {
  final String? activeConversationId;
  final String draftId;
  final List<ChatMessage> messages;
  final String composerText;
  final ChatDraftStatus draftStatus;
  final bool isPersisted;

  ChatSessionState({
    required this.activeConversationId,
    required this.draftId,
    required List<ChatMessage> messages,
    required this.composerText,
    required this.draftStatus,
    required this.isPersisted,
  }) : messages = List.unmodifiable(messages);

  ChatSessionState copyWith({
    String? activeConversationId,
    bool clearActiveConversationId = false,
    String? draftId,
    List<ChatMessage>? messages,
    String? composerText,
    ChatDraftStatus? draftStatus,
    bool? isPersisted,
  }) {
    return ChatSessionState(
      activeConversationId: clearActiveConversationId
          ? null
          : activeConversationId ?? this.activeConversationId,
      draftId: draftId ?? this.draftId,
      messages: messages ?? this.messages,
      composerText: composerText ?? this.composerText,
      draftStatus: draftStatus ?? this.draftStatus,
      isPersisted: isPersisted ?? this.isPersisted,
    );
  }
}

class EggyChatViewModel extends ChangeNotifier {
  final IConversationService _aiService;
  final ScriptedResponseService _localService;
  final EggyMascotController _mascotController;
  final ScientificContextService _contextService = ScientificContextService();
  final PersistenceService _persistenceService;
  final CAMAService _cama = CAMAService();
  final IWebResearchService _webResearch = WebResearchService();

  static final math.Random _idRandom = math.Random.secure();
  late ChatSessionState _chatState = _newDraftState();
  bool _isTyping = false;
  bool _isTumbling = false;
  List<String> _researchBreadcrumbs = [];
  bool _initialized = false;
  Future<void>? _initializationFuture;
  int _sessionEpoch = 0;
  String? _nextSuggestion;
  bool _disposed = false;

  EggyChatViewModel(
    this._aiService,
    this._localService,
    this._mascotController, {
    PersistenceService? persistenceService,
  }) : _persistenceService = persistenceService ?? PersistenceService();

  Future<void> initialize() {
    if (_initialized) return Future<void>.value();
    return _initializationFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _contextService.init();
      final savedHistory = await _persistenceService.loadHistory();
      if (savedHistory.isNotEmpty) {
        var conversationId = await _persistenceService.loadConversationId();
        if (conversationId == null || conversationId.isEmpty) {
          conversationId = _newId();
          await _persistenceService.saveHistory(
            savedHistory,
            conversationId: conversationId,
          );
        }
        _chatState = ChatSessionState(
          activeConversationId: conversationId,
          draftId: _newId(),
          messages: savedHistory,
          composerText: '',
          draftStatus: ChatDraftStatus.persisted,
          isPersisted: true,
        );
        _cama.resetSession();
        for (final message in savedHistory.where((message) => message.isUser)) {
          _cama.updateConsole(message.text);
        }
      }

      _initialized = true;
      if (!_disposed) notifyListeners();
    } finally {
      _initializationFuture = null;
    }
  }

  EggyAppState _appState = EggyAppState.unknown();

  ChatSessionState get chatState => _chatState;
  List<ChatMessage> get messages => _chatState.messages;
  String? get activeConversationId => _chatState.activeConversationId;
  String get draftId => _chatState.draftId;
  String get composerText => _chatState.composerText;
  ChatDraftStatus get draftStatus => _chatState.draftStatus;
  bool get isPersisted => _chatState.isPersisted;
  bool get isTyping => _isTyping;
  bool get isTumbling => _isTumbling;
  List<String> get researchBreadcrumbs => _researchBreadcrumbs;
  bool get isAIBacked => _aiService.isAIBacked;
  List<ChatSuggestion> get suggestedPrompts =>
      _aiService.getSuggestedPrompts(isProfessorMode: isProfessorMode);

  bool get isProfessorMode => _mascotController.isProfessorMode;

  ChatSessionState _newDraftState() => ChatSessionState(
        activeConversationId: null,
        draftId: _newId(),
        messages: const [],
        composerText: '',
        draftStatus: ChatDraftStatus.empty,
        isPersisted: false,
      );

  String _newId() {
    final bytes = List<int>.generate(16, (_) => _idRandom.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  bool _isCurrentSession(
    int epoch,
    String draftId,
    String? conversationId,
  ) {
    return !_disposed &&
        epoch == _sessionEpoch &&
        draftId == _chatState.draftId &&
        conversationId == _chatState.activeConversationId;
  }

  void updateComposerText(String text) {
    _chatState = _chatState.copyWith(
      composerText: text,
      draftStatus: _chatState.messages.isEmpty &&
              _chatState.activeConversationId == null
          ? (text.isEmpty ? ChatDraftStatus.empty : ChatDraftStatus.modified)
          : _chatState.draftStatus,
    );
  }

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

  String _processResponse(String rawAiOutput, int sessionEpoch) {
    if (rawAiOutput.toLowerCase().contains('outside my shell')) {
      _triggerTumble(sessionEpoch);
    }
    return rawAiOutput;
  }

  void _triggerTumble(int sessionEpoch) {
    if (sessionEpoch != _sessionEpoch || _disposed) return;
    _isTumbling = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (sessionEpoch != _sessionEpoch || _disposed) return;
      _isTumbling = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_isTyping) return;
    final requestedEpoch = _sessionEpoch;
    await initialize();
    if (_disposed || requestedEpoch != _sessionEpoch) return;

    final sessionEpoch = _sessionEpoch;
    final draftId = _chatState.draftId;
    final conversationId = _chatState.activeConversationId ?? _newId();
    final userMessage = ChatMessage(text: text, isUser: true);
    final historySnapshot = [..._chatState.messages, userMessage];
    _chatState = _chatState.copyWith(
      activeConversationId: conversationId,
      messages: historySnapshot,
      composerText: '',
      draftStatus: ChatDraftStatus.modified,
      isPersisted: false,
    );
    _isTyping = true;
    _researchBreadcrumbs = [];
    if (!_disposed) notifyListeners();

    try {
      await _persistenceService.saveHistory(
        historySnapshot,
        conversationId: conversationId,
      );
    } catch (_) {
      if (_isCurrentSession(sessionEpoch, draftId, conversationId)) {
        _isTyping = false;
        if (!_disposed) notifyListeners();
      }
      rethrow;
    }

    if (!_isCurrentSession(sessionEpoch, draftId, conversationId)) return;
    _chatState = _chatState.copyWith(
      draftStatus: ChatDraftStatus.persisted,
      isPersisted: true,
    );
    _mascotController.resetMood();

    final lower = text.toLowerCase();
    final isBored = lower.contains('bored') ||
        lower.contains('nothing to do') ||
        lower.contains('tired of');

    final alertLevel = AlertMatcher.getLevel(text);
    var responseText = '';
    String? capturedRawError;
    ThermalState? thermalState;

    try {
      if (isBored) {
        responseText = _handleBoredom();
      } else {
        _cama.updateConsole(text);

        final bool isProfessor = _mascotController.isProfessorMode;
        final bool isScientific =
            _cama.activeIntent == CAMAIntent.scientific_research ||
                _cama.activeIntent == CAMAIntent.safety_governance;

        String? researchContext;
        if (isProfessor || isScientific) {
          _researchBreadcrumbs = [
            "Scanning Global Research Hub...",
            "Accessing Nature & PubMed archives..."
          ];
          if (!_disposed) notifyListeners();

          final result = await _webResearch.investigate(text, []);
          if (!_isCurrentSession(sessionEpoch, draftId, conversationId)) return;
          _researchBreadcrumbs = result.breadcrumbs;
          if (!_disposed) notifyListeners();

          if (result.trustScore > 0.6) {
            researchContext =
                "TRUSTED_RESEARCH (Source: ${result.source}): ${result.content}";
          }
          await Future.delayed(const Duration(milliseconds: 800));
          if (!_isCurrentSession(sessionEpoch, draftId, conversationId)) return;
        } else {
          _researchBreadcrumbs = [
            "Synthesizing precise response...",
            "Recalling deep-context history..."
          ];
          if (!_disposed) notifyListeners();
        }

        final longitudinalSummary = await _cama.getLongitudinalSummary(text);
        if (!_isCurrentSession(sessionEpoch, draftId, conversationId)) return;
        final contextualQuery = _buildContextualQuery(
          text,
          longitudinalSummary: longitudinalSummary,
          researchContext: researchContext,
          history: historySnapshot,
        );

        final rawResponse = await _aiService.getResponse(contextualQuery);
        if (!_isCurrentSession(sessionEpoch, draftId, conversationId)) return;
        responseText = _processResponse(rawResponse, sessionEpoch);

        if (responseText.contains('MASTERPIECE') ||
            responseText.contains('PROTOCOL_SUCCESS')) {
          _mascotController.celebrate();
          responseText = responseText
              .replaceAll('MASTERPIECE', '')
              .replaceAll('PROTOCOL_SUCCESS', '')
              .trim();
        }

        await _cama.ingestCulinaryLesson(
          "User: $text | Eggy: $responseText",
          _cama.activeSubject ?? "Egg Science",
        );
        if (!_isCurrentSession(sessionEpoch, draftId, conversationId)) return;

        if (isProfessor) {
          final threshold = _cama.getThermalThreshold(responseText) ??
              _cama.getThermalThreshold(text);
          final speciesLabel =
              _cama.activeSubject?.split(' ').first.toLowerCase() ?? 'hen';
          final species = EggSpecies.values.firstWhere(
            (e) => e.name.toLowerCase().contains(speciesLabel),
            orElse: () => EggSpecies.henWhite,
          );
          thermalState = threshold != null
              ? ThermalState(threshold: threshold, species: species)
              : null;
        }
      }
    } catch (error) {
      if (!_isCurrentSession(sessionEpoch, draftId, conversationId)) return;
      capturedRawError = error.toString();
      debugPrint("AI ERROR: $error");
      responseText =
          "Eggy's having a bit of a wobble connecting to the servers. Please check your internet or try again in a moment!";
    }

    if (!_isCurrentSession(sessionEpoch, draftId, conversationId)) return;
    _chatState = _chatState.copyWith(
      messages: [
        ..._chatState.messages,
        ChatMessage(
          text: responseText,
          isUser: false,
          alertLevel: alertLevel,
          rawError: capturedRawError,
          contexts: capturedRawError == null ? const [] : null,
          suggestion: _nextSuggestion,
          thermalState: thermalState,
        ),
      ],
      draftStatus: ChatDraftStatus.modified,
      isPersisted: false,
    );
    _nextSuggestion = null;
    _isTyping = false;
    _researchBreadcrumbs = [];
    if (!_disposed) notifyListeners();

    await _persistenceService.saveHistory(
      _chatState.messages,
      conversationId: conversationId,
    );
    if (!_isCurrentSession(sessionEpoch, draftId, conversationId)) return;
    _chatState = _chatState.copyWith(
      draftStatus: ChatDraftStatus.persisted,
      isPersisted: true,
    );
    if (!_disposed) notifyListeners();
  }

  String _buildContextualQuery(
    String userQuery, {
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
    final recentWindow =
        history.length > 6 ? history.sublist(history.length - 6) : history;
    final transcript = recentWindow
        .map((m) => "${m.isUser ? 'USER' : 'EGGY'}: ${m.text}")
        .join("\n");

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

  Future<void> startNewSession() async {
    _sessionEpoch++;
    await initialize();
    final previousState = _chatState;
    _chatState = _newDraftState();
    _isTyping = false;
    _isTumbling = false;
    _researchBreadcrumbs = [];
    _nextSuggestion = null;
    _cama.resetSession();
    if (!_disposed) notifyListeners();

    await _persistenceService.archiveAndClearHistory(
      previousState.messages,
      conversationId: previousState.activeConversationId,
    );
  }

  Future<List<ChatArchiveSession>> loadArchivedSessions() {
    return _persistenceService.loadArchivedSessions();
  }

  Future<void> restoreArchivedSession(ChatArchiveSession session) async {
    _sessionEpoch++;
    await initialize();
    _chatState = ChatSessionState(
      activeConversationId: session.id,
      draftId: _newId(),
      messages: session.messages,
      composerText: '',
      draftStatus: ChatDraftStatus.persisted,
      isPersisted: true,
    );
    _isTyping = false;
    _isTumbling = false;
    _researchBreadcrumbs = [];
    _nextSuggestion = null;
    _cama.resetSession();
    for (final message in session.messages.where((message) => message.isUser)) {
      _cama.updateConsole(message.text);
    }
    if (!_disposed) notifyListeners();
    await _persistenceService.saveHistory(
      session.messages,
      conversationId: session.id,
    );
  }

  Future<void> clearChat() async {
    await startNewSession();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
