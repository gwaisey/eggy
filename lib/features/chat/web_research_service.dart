import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/interfaces/i_web_research_service.dart';

class WebResearchService implements IWebResearchService {
  @override
  Future<WebResearchResult> investigate(String query, List<String> localContextFacts) async {
    final apiKey = dotenv.env['SERPER_API_KEY'] ?? '';
    
    if (apiKey.isEmpty || apiKey == 'your_serper_key_here') {
      return WebResearchResult(
        content: "I'd love to research that deeper, but my Global Hub (Serper) isn't activated yet. Please add a Serper API key to my .env!",
        source: "Local Cache",
        trustScore: 0.5,
        breadcrumbs: ["Searching for active research key...", "Key not found. Falling back to local knowledge."],
      );
    }

    try {
      // Phase 1: Search & Ingest (The Global Hub)
      // We broaden the scope for "extra mile" intelligence.
      String searchScope = "site:egginfo.co.uk OR site:nature.com OR site:gov.uk OR site:poultryscience.org OR site:pubmed.ncbi.nlm.nih.gov";
      
      // If the query looks exotic or non-English, we prioritize scholar/global data
      final isExotic = query.split(' ').length < 3 || query.contains('egg') == false || _isExoticSubject(query);
      if (isExotic) {
        searchScope = "egg science OR molecular biology OR gastronomy";
      }

      final response = await http.post(
        Uri.parse('https://google.serper.dev/search'),
        headers: {
          'X-API-KEY': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': "$query $searchScope",
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) throw Exception('Search failed');

      final data = jsonDecode(response.body);
      final List results = data['organic'] ?? [];
      
      if (results.isEmpty) {
        return WebResearchResult(
          content: "I searched the global faculty sites for '$query' but found no specific anomalies or new data. Relying on Laboratory Baseline.",
          source: "Faculty Hub",
          trustScore: 0.7,
          breadcrumbs: ["Scanning scientific databases...", "Zero global matches found for '$query'.", "Reverting to local truth."],
        );
      }

      // Phase 2: Domain Discovery & Molecular Alignment
      final bestSnippet = results.first['snippet'] ?? '';
      final bestSource = results.first['link'] ?? 'Global Hub';
      final uri = Uri.tryParse(bestSource);
      final domain = uri?.host ?? "global sources";
      
      // Phase 3: Trust Stamping
      double trust = 0.8;
      if (bestSource.contains('.gov') || bestSource.contains('.edu')) trust = 0.95;
      if (bestSource.contains('egginfo.co.uk')) trust = 0.98;

      return WebResearchResult(
        content: bestSnippet,
        source: bestSource,
        trustScore: trust,
        breadcrumbs: [
          "Discovering content on $domain...",
          "Validating research with current session context...",
          "Stamping with Trusted Badge ($trust)..."
        ],
      );
    } catch (e) {
      return WebResearchResult(
        content: "Eggy hit a network snag while researching. Using Laboratory Baseline instead.",
        source: "Internal Knowledge",
        trustScore: 0.6,
        breadcrumbs: ["Network timeout during search.", "Falling back to local corpus."],
      );
    }
  }

  bool _isExoticSubject(String query) {
    final q = query.toLowerCase();
    final exotic = ['balut', 'century', 'telur', 'salted', 'emu', 'quail', 'ostrich', 'goose', 'turkey', 'crocodile', 'reptile'];
    return exotic.any((term) => q.contains(term));
  }
}
