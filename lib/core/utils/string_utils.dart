extension EmojiScrubber on String {
  /// Robust regex guard to strip all Unicode emojis from LLM output.
  /// Ensures a Zero-Emoji codebase as per project requirements.
  String scrubEmojis() {
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FA7F}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return replaceAll(emojiRegex, '').trim();
  }
}
