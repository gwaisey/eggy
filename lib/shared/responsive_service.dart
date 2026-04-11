import 'dart:ui';
import 'package:flutter/material.dart';

class EggyResponsive {
  final BuildContext context;
  EggyResponsive(this.context);

  // Use a "Mobile-First" base (iPhone 13/14 size)
  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  // sp (Scale Pixels) for fonts and icons
  double sp(double size) => (screenWidth / _baseWidth) * size;

  // clamp() to prevent "Giant Text" on tablets or unreadable text on small devices
  double spClamped(double size, {double? max}) =>
      ((screenWidth / _baseWidth) * size).clamp(size * 0.8, max ?? size * 1.5);

  // hp (Height Pixels) for vertical spacing
  double hp(double size) {
    double scale = screenHeight / _baseHeight;
    // Extra breathing room for Flagship Tall Devices (S24 Ultra, etc.)
    if (screenHeight / screenWidth > 2.0) {
      scale *= 1.05; 
    }
    return scale * size;
  }

  // Device characteristics
  bool get isTablet => screenWidth >= 600;
  bool get isLandscape => screenWidth > screenHeight;
  bool get isExtraTall => (screenHeight / screenWidth) > 2.05; // S24 Ultra is ~2.16
  bool get hasHinge => MediaQuery.displayFeaturesOf(context).any((f) => f.type == DisplayFeatureType.hinge);

  // Responsive Grid aspect ratio
  double get gridAspectRatio {
    if (isLandscape) {
       return isTablet ? 1.25 : 1.1; 
    }
    // Adjust aspect ratio for tall screens to keep cards from getting excessively long
    return isExtraTall ? 0.88 : 0.95; 
  }
}
