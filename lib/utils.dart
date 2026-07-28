import 'package:flutter/material.dart';

extension TimerValueX on int {
  String get timeMinSecs {
    int minutes = this ~/ 60;
    int seconds = this % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// High-contrast text color via bitwise inversion of the background RGB.
extension ColorContrastX on Color {
  Color get contrastingXor {
    return withValues(
      red: r * 0.6,
      green: g * 0.6,
      blue: b * 0.6,
    );
    // int channel(double c) => (255 - (c * 255.0).round()).clamp(0, 255);
    // return Color.fromARGB(
    //   255,
    //   channel(r),
    //   channel(g),
    //   channel(b),
    // );
  }
}
