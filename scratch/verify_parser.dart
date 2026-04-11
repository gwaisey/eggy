import 'dart:io';

void main() {
  final corpusContent = File('assets/data/egg_science_corpus.md').readAsStringSync();
  final blocks = corpusContent.split('[BLOCK_START]');
  
  print('Total Blocks Found: ${blocks.length - 1}');
  
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

    print('--- Data Pack ---');
    print('Entity: ${metadata['Entity']}');
    print('Source: ${lineage['dc:source']}');
    print('Trust: $trustScore');
    print('Class: $classification');
    print('Content Preview: ${contentBuffer.toString().substring(0, 30).replaceAll('\n', ' ')}...');
  }
}

Map<String, String> _parseTags(String tagLine) {
  final Map<String, String> result = {};
  final parts = tagLine.split(';');
  for (var part in parts) {
    if (part.contains(':')) {
      final lastColonSpace = part.lastIndexOf(': ');
      if (lastColonSpace != -1) {
        final key = part.substring(0, lastColonSpace).trim();
        final value = part.substring(lastColonSpace + 1).trim();
        result[key] = value;
      } else {
        final firstColon = part.indexOf(':');
        final key = part.substring(0, firstColon).trim();
        final value = part.substring(firstColon + 1).trim();
        result[key] = value;
      }
    }
  }
  return result;
}
