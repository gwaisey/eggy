import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:ui';
import '../../core/constants.dart';
import '../../core/models/chat_suggestion.dart';
import '../../core/models/app_state.dart';
import '../../features/chat/conversation_service.dart';
import '../../features/preferences/preferences_view_model.dart';
import '../../shared/ui/app_theme.dart';
import '../../shared/ui/widgets.dart';
import '../../features/mascot/mascot_view.dart';
import '../../features/mascot/eggy_mascot_controller.dart';
import '../../features/physics/thermal_state.dart';
import '../../features/physics/thermal_heatmap.dart';

/// Screen 6 — "Eggy Chat" — AI assistant with scripted (Phase 1) or Gemini (Phase 2)
class EggyChatScreen extends StatefulWidget {
  const EggyChatScreen({super.key});

  @override
  State<EggyChatScreen> createState() => _EggyChatScreenState();
}

class _EggyChatScreenState extends State<EggyChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  late final EggyChatViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = context.read<EggyChatViewModel>();
    
    // Sync current app state safely after the first frame to avoid build-time rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final prefs = context.read<PreferencesViewModel>();
        context.read<EggyMascotController>().setProfessorMode(prefs.isProfessorMode);
        _vm.updateAppState(EggyAppState(
          activeRecipe: 'Browsing Egg Assistant',
          eggSize: prefs.eggSize,
          startTemp: prefs.startTemp,
        ));
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    await _vm.sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: EggyColors.warmWhite,
          appBar: AppBar(
            backgroundColor: Colors.white.withValues(alpha: 0.5),
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AntiGravityWrapper(
                  amplitude: 2,
                  child: Icon(
                    _vm.isProfessorMode ? Icons.school_rounded : Icons.egg_alt_rounded, 
                    size: 20, 
                    color: _vm.isProfessorMode ? EggyColors.slate : EggyColors.champagne
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _vm.isProfessorMode ? 'Eggy Professor' : 'Assistant', 
                  style: AppTheme.headline.copyWith(fontSize: 18)
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _vm.isProfessorMode ? Icons.soup_kitchen_rounded : Icons.school_outlined,
                  color: _vm.isProfessorMode ? EggyColors.champagne : EggyColors.onyx.withValues(alpha: 0.5),
                ),
                tooltip: _vm.isProfessorMode ? 'Switch to Chef Mode' : 'Switch to Professor Mode',
                onPressed: () {
                  final prefs = context.read<PreferencesViewModel>();
                  _vm.toggleProfessorMode(prefs);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              // Ambient Research Pulse (Dynamic Background)
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.5),
                    radius: 1.2,
                    colors: [
                      _vm.isTyping 
                        ? (_vm.isProfessorMode ? Colors.blueAccent : Colors.orangeAccent).withValues(alpha: 0.05) 
                        : EggyColors.warmWhite,
                      _vm.isProfessorMode ? Colors.blue.withValues(alpha: 0.02) : EggyColors.warmWhite,
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  // Spacer for the transparent app bar
                  SizedBox(height: MediaQuery.of(context).padding.top + 56),
                  // Messages
                  Expanded(
                    child: _vm.messages.isEmpty
                        ? _EmptyState(
                            prompts: _vm.suggestedPrompts,
                            onPrompt: _send,
                            isProfessorMode: _vm.isProfessorMode,
                          )
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _vm.messages.length + (_vm.isTyping ? 1 : 0),
                            itemBuilder: (_, i) {
                              if (i == _vm.messages.length) {
                                return _TypingIndicator(vm: _vm);
                              }
                              return _ChatBubble(message: _vm.messages[i]);
                            },
                          ),
                  ),

              // Suggested prompts (shown when there are messages)
              if (_vm.messages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: _vm.suggestedPrompts.take(4).map((p) =>
                        GestureDetector(
                          onTap: () => _send(p.text),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: EggyColors.shadowSoft.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                              border: Border.all(
                                  color: EggyColors.butterYellow.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (p.icon != null) ...[
                                  Icon(p.icon, size: 14, color: EggyColors.liquidGold.withValues(alpha: 0.7)),
                                  const SizedBox(width: 8),
                                ],
                                Text(p.text, style: AppTheme.caption.copyWith(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                ),

              // Marshmallow Input 2.0
              Padding(
                padding: EdgeInsets.only(
                  left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 12,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      // Deep atmospheric shadow for floating feel
                      BoxShadow(
                        color: EggyColors.shadowSoft.withValues(alpha: 0.12),
                        blurRadius: 32,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          style: AppTheme.body,
                          decoration: InputDecoration(
                            hintText: 'Ask Eggy about yolks, science...',
                            hintStyle: AppTheme.caption.copyWith(color: EggyColors.softCharcoal.withValues(alpha: 0.4)),
                            border: InputBorder.none,
                          ),
                          onSubmitted: _send,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _send(_ctrl.text),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _ctrl.text.isEmpty ? EggyColors.butterYellow.withValues(alpha: 0.5) : EggyColors.butterYellow,
                            shape: BoxShape.circle,
                            boxShadow: [
                              if (_ctrl.text.isNotEmpty)
                                BoxShadow(
                                  color: EggyColors.liquidGold.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: const Icon(Icons.send_rounded,
                              size: 20, color: EggyColors.softCharcoal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                  ],
                ),
              ],
            ),
          );
        },
      );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isCritical = message.alertLevel == AlertLevel.critical;
    final isCaution = message.alertLevel == AlertLevel.caution;
    // CAMA 4.0 Adaptive Persona Theming
    final isResearch = message.contexts?.any((c) => c.classification == 'Lab_Science' || c.classification == 'Research') ?? false;
    final isChef = message.contexts?.any((c) => c.classification == 'Culinary' || c.classification == 'Technique') ?? false;
    
    // Choose accent color based on persona
    final Color personaAccent = isResearch 
        ? EggyColors.slate // Classy Slate for Professor
        : (isChef ? EggyColors.champagne : EggyColors.champagne); 

    final isAlert = isCritical || isCaution;

    Color bubbleColor = isUser
        ? EggyColors.champagne.withValues(alpha: 0.15)
        : Colors.white;
    
    Color textColor = EggyColors.softCharcoal;
    Border? border = Border.all(color: EggyColors.onyx.withValues(alpha: 0.08), width: 0.5);

    Widget contentBubble = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bubbleColor,
        border: border,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Marshmallow Softness
          BoxShadow(
            color: (isResearch ? personaAccent : EggyColors.shadowSoft).withValues(alpha: 0.1),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          if (isUser)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAlert) ...[
            Text(
              isCritical ? 'SAFETY ALERT' : 'KITCHEN TIP',
              style: AppTheme.caption.copyWith(
                color: isCritical ? const Color(0xFFB71C1C) : const Color(0xFF856404),
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
          ],
                MarkdownBody(
                  data: message.text,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: AppTheme.body.copyWith(color: textColor, fontSize: 13.5),
                    strong: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: textColor),
                    listBullet: AppTheme.body.copyWith(color: textColor),
                  ),
                ),
                if (message.thermalState != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: personaAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: personaAccent.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.layers_rounded, size: 14, color: personaAccent.withOpacity(0.6)),
                            const SizedBox(width: 8),
                            Text(
                              'MOLECULAR LAB INSIGHT',
                              style: AppTheme.caption.copyWith(
                                color: personaAccent.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(message.thermalState!.threshold * 100).toInt()}% Set',
                              style: AppTheme.caption.copyWith(
                                color: personaAccent.withValues(alpha: 0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ThermalHeatmapWidget(
                            state: message.thermalState!,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: personaAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message.thermalState!.label.toUpperCase(),
                            style: AppTheme.caption.copyWith(
                              color: personaAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (message.suggestion != null) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      // Trigger the suggestion back as a message
                      context.read<EggyChatViewModel>().sendMessage(message.suggestion!);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded, size: 14, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(
                            message.suggestion!,
                            style: AppTheme.caption.copyWith(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
        ],
      ),
    );

    Widget finalBubble = contentBubble;
    if (message.rawError != null) {
      finalBubble = GestureDetector(
        onDoubleTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dev Info: ${message.rawError}'),
              backgroundColor: EggyColors.softCharcoal,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: contentBubble,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.85),
          child: finalBubble,
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final EggyChatViewModel vm;
  const _TypingIndicator({required this.vm});

  @override
  Widget build(BuildContext context) {
    final breadcrumbs = vm.researchBreadcrumbs;
    final isResearching = breadcrumbs.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const EggyEndorsementBadge(size: 32, isExcited: false)
              .animate()
              .scale(curve: Curves.easeOutBack)
              .fadeIn(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
                border: isResearching ? Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)) : null,
                boxShadow: [
                  if (isResearching)
                    BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 1),
                  BoxShadow(color: EggyColors.shadowSoft, blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isResearching ? 'Eggy is investigating...' : 'Eggy is thinking...',
                    style: AppTheme.caption.copyWith(
                      fontWeight: isResearching ? FontWeight.bold : FontWeight.normal,
                      color: isResearching ? Colors.blueAccent : EggyColors.softCharcoal,
                    ),
                  ),
                  if (isResearching) ...[
                    const SizedBox(height: 4),
                    ...breadcrumbs.map((b) => 
                      Text(
                        '• $b', 
                        style: AppTheme.caption.copyWith(fontSize: 10, color: Colors.blueAccent.withValues(alpha: 0.7)),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<ChatSuggestion> prompts;
  final void Function(String) onPrompt;
  final bool isProfessorMode;

  const _EmptyState({
    required this.prompts, 
    required this.onPrompt,
    required this.isProfessorMode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          AntiGravityWrapper(
            amplitude: 8,
            child: EggyProgressMascot(),
          )
          .animate()
          .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.easeOutBack)
          .fadeIn(),
          const SizedBox(height: 20),
          Text(
            isProfessorMode ? 'Professor Eggy' : 'I am Eggy', 
            style: AppTheme.display.copyWith(fontSize: 28), 
            textAlign: TextAlign.center
          ),
          const SizedBox(height: 12),
          Text(
            isProfessorMode 
              ? 'Ready for molecular analysis.\nAsk me about egg science & safety.'
              : 'Your professional culinary companion.\nHow can I help with your eggs today?',
            style: AppTheme.body.copyWith(
              color: EggyColors.onyx.withValues(alpha: 0.5),
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...prompts.map((p) => GestureDetector(
            onTap: () => onPrompt(p.text),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [EggyColors.creamFoam, Colors.white.withValues(alpha: 0.9)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: EggyColors.liquidGold.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                    color: EggyColors.butterYellow.withValues(alpha: 0.2),
                    width: 0.8),
              ),
              child: Row(
                children: [
                  if (p.icon != null) ...[
                    Icon(p.icon, size: 20, color: EggyColors.liquidGold),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(p.text, style: AppTheme.bodyMedium),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: EggyColors.shadowSoft),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
