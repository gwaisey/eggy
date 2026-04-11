import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

class VectorEntry {
  final String text;
  final List<double> embedding;
  final Map<String, dynamic> metadata;

  VectorEntry({
    required this.text,
    required this.embedding,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'embedding': embedding,
    'metadata': metadata,
  };

  factory VectorEntry.fromJson(Map<String, dynamic> json) => VectorEntry(
    text: json['text'],
    embedding: List<double>.from(json['embedding']),
    metadata: Map<String, dynamic>.from(json['metadata']),
  );
}

class VectorSemanticService {
  final List<VectorEntry> _store = [];
  bool _initialized = false;

  VectorSemanticService(String apiKey);

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }
    
    try {
      final file = await _getStoreFile();
      if (file != null && await file.exists()) {
        final raw = await file.readAsString();
        final List<dynamic> json = jsonDecode(raw);
        _store.addAll(json.map((e) => VectorEntry.fromJson(e)));
      }
    } catch (e) {
      print('Vector Store Init Error: $e');
    }
    _initialized = true;
  }

  Future<File?> _getStoreFile() async {
    if (kIsWeb) return null;
    // For now, let's keep it in-memory on Web to avoid path_provider issues
    return null;
  }

  Future<void> _persist() async {
    // Persistence disabled temporarily while we switch providers
  }

  /// Stores a new piece of knowledge (Keyword-only fallback)
  Future<void> ingest(String text, {Map<String, dynamic>? metadata}) async {
    if (!_initialized) await init();
    try {
      _store.add(VectorEntry(
        text: text,
        embedding: [], // Zero vectors during transition
        metadata: metadata ?? {},
      ));
      if (_store.length > 2000) _store.removeAt(0); 
    } catch (e) {
      print('Ingestion Error: $e');
    }
  }

  /// Finds Top-K Similar entries (Keyword fallback)
  Future<List<VectorEntry>> query(String text, {int limit = 3}) async {
    if (!_initialized) await init();
    if (_store.isEmpty) return [];

    try {
      final queryLower = text.toLowerCase();
      // Keyword intersection as a temporary fallback for semantic search
      final scoredEntries = _store.map((entry) {
        final entryText = entry.text.toLowerCase();
        double score = 0.0;
        final words = queryLower.split(' ').where((w) => w.length > 3);
        for (final word in words) {
          if (entryText.contains(word)) score += 1.0;
        }
        return _ScoredEntry(entry, score);
      }).toList();

      scoredEntries.sort((a, b) => b.score.compareTo(a.score));
      
      return scoredEntries
          .where((e) => e.score > 0) 
          .take(limit)
          .map((e) => e.entry)
          .toList();
    } catch (e) {
      print('Query Error: $e');
      return [];
    }
  }

  double _cosineSimilarity(List<double> v1, List<double> v2) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < v1.length; i++) {
      dotProduct += v1[i] * v2[i];
      normA += v1[i] * v1[i];
      normB += v2[i] * v2[i];
    }
    if (normA == 0 || normB == 0) return 0;
    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }
}

class _ScoredEntry {
  final VectorEntry entry;
  final double score;
  _ScoredEntry(this.entry, this.score);
}
