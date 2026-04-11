import 'package:flutter/material.dart';

/// A professional chat suggestion chip model.
/// Replaces text-only strings with icon/asset support.
class ChatSuggestion {
  final String text;
  final IconData? icon;
  final String? assetPath;

  const ChatSuggestion({
    required this.text,
    this.icon,
    this.assetPath,
  });
}
