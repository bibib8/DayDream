import 'package:flutter/material.dart';

/// Pre-curated soft pastel gradient presets matching Daydream's coquette aesthetic
class CoverGradientPreset {
  final String id;
  final String name;
  final Color startColor;
  final Color endColor;
  final String startHex;
  final String endHex;

  const CoverGradientPreset({
    required this.id,
    required this.name,
    required this.startColor,
    required this.endColor,
    required this.startHex,
    required this.endHex,
  });

  String get hexPair => "$startHex,$endHex";

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [startColor, endColor],
      );

  List<Color> get colors => [startColor, endColor];
}

const List<CoverGradientPreset> kCoverGradients = [
  // 1. Blush Rose (Pink) - Top-Left panel in user mockup
  CoverGradientPreset(
    id: 'blush_rose',
    name: 'Blush Rose',
    startColor: Color(0xFFFFF0F7),
    endColor: Color(0xFFFBCFE8),
    startHex: '#FFF0F7',
    endHex: '#FBCFE8',
  ),
  // 2. Buttercream (Warm Yellow) - Top-Right panel in user mockup
  CoverGradientPreset(
    id: 'buttercream',
    name: 'Buttercream',
    startColor: Color(0xFFFFFDF2),
    endColor: Color(0xFFFEF08A),
    startHex: '#FFFDF2',
    endHex: '#FEF08A',
  ),
  // 3. Periwinkle Dream (Lavender Blue) - Middle-Left panel in user mockup
  CoverGradientPreset(
    id: 'periwinkle_dream',
    name: 'Periwinkle Dream',
    startColor: Color(0xFFF1F4FF),
    endColor: Color(0xFFC7D2FE),
    startHex: '#F1F4FF',
    endHex: '#C7D2FE',
  ),
  // 4. Sweet Lilac (Pastel Purple) - Middle-Right panel in user mockup
  CoverGradientPreset(
    id: 'sweet_lilac',
    name: 'Sweet Lilac',
    startColor: Color(0xFFFAF5FF),
    endColor: Color(0xFFE9D5FF),
    startHex: '#FAF5FF',
    endHex: '#E9D5FF',
  ),
  // 5. Powder Sky (Fresh Ice Blue) - Bottom-Left panel in user mockup
  CoverGradientPreset(
    id: 'powder_sky',
    name: 'Powder Sky',
    startColor: Color(0xFFF0F9FF),
    endColor: Color(0xFFBAE6FD),
    startHex: '#F0F9FF',
    endHex: '#BAE6FD',
  ),
  // 6. Vintage Pearl (Silver Mist Gray) - Bottom-Right panel in user mockup
  CoverGradientPreset(
    id: 'vintage_pearl',
    name: 'Vintage Pearl',
    startColor: Color(0xFFFFFFFF),
    endColor: Color(0xFFCBD5E1),
    startHex: '#FFFFFF',
    endHex: '#CBD5E1',
  ),
];
