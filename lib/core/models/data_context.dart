/// DataContext Pillar Model
/// 
/// Represents a structured "Data Pack" with Metadata, Lineage, 
/// Observability, and Governance attributes.
class DataContext {
  final String content;
  final Map<String, String> metadata;
  final Map<String, String> lineage;
  final double trustScore;
  final String classification;
  final String policy;

  const DataContext({
    required this.content,
    required this.metadata,
    required this.lineage,
    required this.trustScore,
    required this.classification,
    required this.policy,
  });

  factory DataContext.fromJson(Map<String, dynamic> json) {
    return DataContext(
      content: json['content'] as String,
      metadata: Map<String, String>.from(json['metadata'] as Map),
      lineage: Map<String, String>.from(json['lineage'] as Map),
      trustScore: (json['trustScore'] as num).toDouble(),
      classification: json['classification'] as String,
      policy: json['policy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'metadata': metadata,
      'lineage': lineage,
      'trustScore': trustScore,
      'classification': classification,
      'policy': policy,
    };
  }
}
