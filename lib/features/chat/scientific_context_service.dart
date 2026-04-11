import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/models/data_context.dart';

/// Service to handle Data Context Framework (DCF).
/// It pulls structured "Data Packs" with Metadata, Lineage, Observability, and Governance.
class ScientificContextService {
  final List<DataContext> _knowledgeCorpus = [];
  bool _initialized = false;

  /// Loads and parses the scientific corpus using the 4-pillar tag syntax.
  Future<void> init() async {
    if (_initialized) return;

    try {
      final String corpusText = await rootBundle.loadString('assets/data/egg_science_corpus.md');
      
      // Split by [BLOCK_START] and [BLOCK_END]
      final blocks = corpusText.split('[BLOCK_START]');
      
      for (var block in blocks) {
        if (!block.contains('[BLOCK_END]')) continue;
        
        final cleanBlock = block.split('[BLOCK_END]')[0].trim();
        final lines = cleanBlock.split('\n');
        
        Map<String, String> metadata = {};
        Map<String, String> lineage = {};
        double trustScore = 1.0;
        String classification = 'Scientific';
        String policy = 'Knowledge_Base';
        StringBuffer contentBuffer = StringBuffer();

        for (var line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.startsWith('@Metadata:')) {
            metadata = _parseTags(trimmedLine.replaceFirst('@Metadata:', ''));
          } else if (trimmedLine.startsWith('@Lineage:')) {
            lineage = _parseTags(trimmedLine.replaceFirst('@Lineage:', ''));
          } else if (trimmedLine.startsWith('@Observability:')) {
            final obs = _parseTags(trimmedLine.replaceFirst('@Observability:', ''));
            trustScore = double.tryParse(obs['Trust'] ?? '1.0') ?? 1.0;
          } else if (trimmedLine.startsWith('@Governance:')) {
            final gov = _parseTags(trimmedLine.replaceFirst('@Governance:', ''));
            classification = gov['Class'] ?? 'Scientific';
            policy = gov['Policy'] ?? 'Knowledge_Base';
          } else if (trimmedLine.startsWith('Content:')) {
            contentBuffer.writeln(trimmedLine.replaceFirst('Content:', '').trim());
          } else if (trimmedLine.isNotEmpty && !trimmedLine.startsWith('@')) {
            contentBuffer.writeln(trimmedLine);
          }
        }

        _knowledgeCorpus.add(DataContext(
          content: contentBuffer.toString().trim(),
          metadata: metadata,
          lineage: lineage,
          trustScore: trustScore,
          classification: classification,
          policy: policy,
        ));
      }

      _initialized = true;
    } catch (e) {
      // Fallback
    }
  }

  /// Helper to parse "Key: Value; Key2: Value2" strings into a Map
  Map<String, String> _parseTags(String tagLine) {
    final Map<String, String> result = {};
    // Split by semicolon to get Key: Value pairs
    final parts = tagLine.split(';');
    for (var part in parts) {
      if (part.contains(':')) {
        // Use the LAST colon followed by a space to separate Key from Value
        // This allows keys like "dc:source" to be parsed correctly.
        final lastColonSpace = part.lastIndexOf(': ');
        if (lastColonSpace != -1) {
          final key = part.substring(0, lastColonSpace).trim();
          final value = part.substring(lastColonSpace + 1).trim();
          result[key] = value;
        } else {
          // Fallback to first colon if no space exists
          final firstColon = part.indexOf(':');
          final key = part.substring(0, firstColon).trim();
          final value = part.substring(firstColon + 1).trim();
          result[key] = value;
        }
      }
    }
    return result;
  }

  /// Returns relevant DataContext packs based on keyword proximity.
  Future<List<DataContext>> getRelevantContexts(String query) async {
    if (!_initialized) await init();

    final lowerQuery = query.toLowerCase();
    final List<DataContext> results = [];

    for (var pack in _knowledgeCorpus) {
      // Check metadata and content for relevance
      final entity = pack.metadata['Entity']?.toLowerCase() ?? '';
      final property = pack.metadata['Property']?.toLowerCase() ?? '';
      final domain = pack.metadata['Domain']?.toLowerCase() ?? '';
      
      if (lowerQuery.contains(entity) || 
          lowerQuery.contains(property) || 
          lowerQuery.contains(domain) ||
          pack.content.toLowerCase().contains(lowerQuery)) {
        results.add(pack);
      }
    }

    return results;
  }

  /// Legacy helper for backward compatibility during refactor
  @Deprecated('Use getRelevantContexts instead')
  Future<String> getRelevantFacts(String query) async {
    final contexts = await getRelevantContexts(query);
    if (contexts.isEmpty) return "";
    
    return "RELEVANT SCIENTIFIC DATA FOUND:\n" + 
           contexts.map((c) => "SOURCE: ${c.lineage['dc:source']}\n${c.content}").join('\n\n');
  }
}
