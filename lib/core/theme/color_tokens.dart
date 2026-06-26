import 'package:flutter/material.dart';

abstract class ColorTokens {
  static Color _hsl(double h, double s, double l) =>
      HSLColor.fromAHSL(1.0, h, s / 100, l / 100).toColor();

  // Light mode
  static final Color primary = _hsl(215, 55, 45);
  static final Color background = _hsl(0, 0, 100);
  static final Color surface = _hsl(210, 20, 98);
  static final Color surfaceElevated = _hsl(210, 16, 96);
  static final Color border = _hsl(215, 20, 90);
  static final Color text = _hsl(215, 28, 17);
  static final Color textMuted = _hsl(215, 15, 45);
  static final Color accentBrass = _hsl(38, 85, 50);
  static final Color accentGreen = _hsl(150, 45, 38);
  static final Color accentPlum = _hsl(285, 55, 48);
  static final Color danger = _hsl(0, 70, 50);

  // Dark mode
  static final Color primaryDark = _hsl(215, 65, 60);
  static final Color backgroundDark = _hsl(215, 30, 10);
  static final Color surfaceDark = _hsl(215, 28, 14);
  static final Color surfaceElevatedDark = _hsl(215, 26, 18);
  static final Color borderDark = _hsl(215, 20, 25);
  static final Color textDark = _hsl(210, 40, 96);
  static final Color textMutedDark = _hsl(215, 15, 65);
  static final Color accentBrassDark = _hsl(38, 85, 55);
  static final Color accentGreenDark = _hsl(150, 50, 50);
  static final Color accentPlumDark = _hsl(285, 65, 64);
}
