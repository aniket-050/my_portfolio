import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const Color ink = Color(0xFF0D1020);
  static const Color canvas = Color(0xFFF5F1EA);
  static const Color surface = Color(0xFFFFFCF7);
  static const Color surfaceAlt = Color(0xFFECE6DB);
  static const Color line = Color(0x1A0D1020);
  static const Color cobalt = Color(0xFF2937F6);
  static const Color cobaltDeep = Color(0xFF1924A8);
  static const Color sky = Color(0xFF98C8FF);
  static const Color coral = Color(0xFFFF7A5C);
  static const Color amber = Color(0xFFFFB249);
  static const Color magenta = Color(0xFFE95EE8);
  static const Color violet = Color(0xFF7D57FF);
  static const Color success = Color(0xFF1E9E74);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [cobalt, cobaltDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [coral, amber, magenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient highlightGradient = LinearGradient(
    colors: [Color(0xFFFF865C), Color(0xFFD95DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
