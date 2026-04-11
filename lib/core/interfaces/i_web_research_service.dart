import '../../features/chat/conversation_service.dart';

abstract class IWebResearchService {
  /// Entry point for global egg research.
  /// Follows the Tri-Phase Protocol: Search -> Align -> Stamp.
  Future<WebResearchResult> investigate(String query, List<String> localContextFacts);
}

class WebResearchResult {
  final String content;
  final String source;
  final double trustScore;
  final List<String> breadcrumbs;

  WebResearchResult({
    required this.content,
    required this.source,
    required this.trustScore,
    required this.breadcrumbs,
  });
}
