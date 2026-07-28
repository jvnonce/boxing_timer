import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff8a5022),
      surfaceTint: Color(0xff8a5022),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdcc5),
      onPrimaryContainer: Color(0xff6d390b),
      secondary: Color(0xff755845),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdcc5),
      onSecondaryContainer: Color(0xff5b412f),
      tertiary: Color(0xff5f6135),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffe4e6ae),
      onTertiaryContainer: Color(0xff474920),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff221a15),
      onSurfaceVariant: Color(0xff52443b),
      outline: Color(0xff84746a),
      outlineVariant: Color(0xffd6c3b7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382f29),
      inversePrimary: Color(0xffffb784),
      primaryFixed: Color(0xffffdcc5),
      onPrimaryFixed: Color(0xff301400),
      primaryFixedDim: Color(0xffffb784),
      onPrimaryFixedVariant: Color(0xff6d390b),
      secondaryFixed: Color(0xffffdcc5),
      onSecondaryFixed: Color(0xff2a1708),
      secondaryFixedDim: Color(0xffe4bfa7),
      onSecondaryFixedVariant: Color(0xff5b412f),
      tertiaryFixed: Color(0xffe4e6ae),
      onTertiaryFixed: Color(0xff1b1d00),
      tertiaryFixedDim: Color(0xffc8ca94),
      onTertiaryFixedVariant: Color(0xff474920),
      surfaceDim: Color(0xffe7d7ce),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ea),
      surfaceContainer: Color(0xfffbebe2),
      surfaceContainerHigh: Color(0xfff6e5dc),
      surfaceContainerHighest: Color(0xfff0dfd6),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff582a00),
      surfaceTint: Color(0xff8a5022),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff9b5e2f),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff493120),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff856753),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff363810),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff6d7042),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff17100b),
      onSurfaceVariant: Color(0xff40342b),
      outline: Color(0xff5e5047),
      outlineVariant: Color(0xff7a6a60),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382f29),
      inversePrimary: Color(0xffffb784),
      primaryFixed: Color(0xff9b5e2f),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff7e4719),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff856753),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff6a4f3c),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6d7042),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff55572c),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd3c4bb),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ea),
      surfaceContainer: Color(0xfff6e5dc),
      surfaceContainerHigh: Color(0xffeadad1),
      surfaceContainerHighest: Color(0xffdecfc6),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff492100),
      surfaceTint: Color(0xff8a5022),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff703b0e),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3d2717),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5e4431),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2c2e07),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff494c22),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff362a22),
      outlineVariant: Color(0xff54463e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382f29),
      inversePrimary: Color(0xffffb784),
      primaryFixed: Color(0xff703b0e),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff532700),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5e4431),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff452d1d),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff494c22),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff33350d),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc5b6ad),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffeeee4),
      surfaceContainer: Color(0xfff0dfd6),
      surfaceContainerHigh: Color(0xffe1d1c9),
      surfaceContainerHighest: Color(0xffd3c4bb),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb784),
      surfaceTint: Color(0xffffb784),
      onPrimary: Color(0xff4f2500),
      primaryContainer: Color(0xff6d390b),
      onPrimaryContainer: Color(0xffffdcc5),
      secondary: Color(0xffe4bfa7),
      onSecondary: Color(0xff422b1b),
      secondaryContainer: Color(0xff5b412f),
      onSecondaryContainer: Color(0xffffdcc5),
      tertiary: Color(0xffc8ca94),
      onTertiary: Color(0xff30330b),
      tertiaryContainer: Color(0xff474920),
      onTertiaryContainer: Color(0xffe4e6ae),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff19120d),
      onSurface: Color(0xfff0dfd6),
      onSurfaceVariant: Color(0xffd6c3b7),
      outline: Color(0xff9f8d83),
      outlineVariant: Color(0xff52443b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd6),
      inversePrimary: Color(0xff8a5022),
      primaryFixed: Color(0xffffdcc5),
      onPrimaryFixed: Color(0xff301400),
      primaryFixedDim: Color(0xffffb784),
      onPrimaryFixedVariant: Color(0xff6d390b),
      secondaryFixed: Color(0xffffdcc5),
      onSecondaryFixed: Color(0xff2a1708),
      secondaryFixedDim: Color(0xffe4bfa7),
      onSecondaryFixedVariant: Color(0xff5b412f),
      tertiaryFixed: Color(0xffe4e6ae),
      onTertiaryFixed: Color(0xff1b1d00),
      tertiaryFixedDim: Color(0xffc8ca94),
      onTertiaryFixedVariant: Color(0xff474920),
      surfaceDim: Color(0xff19120d),
      surfaceBright: Color(0xff413731),
      surfaceContainerLowest: Color(0xff140d08),
      surfaceContainerLow: Color(0xff221a15),
      surfaceContainer: Color(0xff261e18),
      surfaceContainerHigh: Color(0xff312822),
      surfaceContainerHighest: Color(0xff3c332d),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd4b8),
      surfaceTint: Color(0xffffb784),
      onPrimary: Color(0xff3f1c00),
      primaryContainer: Color(0xffc5814e),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffbd5bc),
      onSecondary: Color(0xff362111),
      secondaryContainer: Color(0xffab8a74),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffdee0a8),
      onTertiary: Color(0xff252802),
      tertiaryContainer: Color(0xff929463),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff19120d),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffedd8cc),
      outline: Color(0xffc1aea3),
      outlineVariant: Color(0xff9e8d82),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd6),
      inversePrimary: Color(0xff6f3a0d),
      primaryFixed: Color(0xffffdcc5),
      onPrimaryFixed: Color(0xff200b00),
      primaryFixedDim: Color(0xffffb784),
      onPrimaryFixedVariant: Color(0xff582a00),
      secondaryFixed: Color(0xffffdcc5),
      onSecondaryFixed: Color(0xff1e0d02),
      secondaryFixedDim: Color(0xffe4bfa7),
      onSecondaryFixedVariant: Color(0xff493120),
      tertiaryFixed: Color(0xffe4e6ae),
      onTertiaryFixed: Color(0xff111200),
      tertiaryFixedDim: Color(0xffc8ca94),
      onTertiaryFixedVariant: Color(0xff363810),
      surfaceDim: Color(0xff19120d),
      surfaceBright: Color(0xff4d423c),
      surfaceContainerLowest: Color(0xff0c0603),
      surfaceContainerLow: Color(0xff241c17),
      surfaceContainer: Color(0xff2f2620),
      surfaceContainerHigh: Color(0xff3a312b),
      surfaceContainerHighest: Color(0xff463c35),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffece2),
      surfaceTint: Color(0xffffb784),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xfffeb27b),
      onPrimaryContainer: Color(0xff180700),
      secondary: Color(0xffffece2),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffe0bba4),
      onSecondaryContainer: Color(0xff170700),
      tertiary: Color(0xfff2f4bb),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffc4c691),
      onTertiaryContainer: Color(0xff0b0c00),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff19120d),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffece2),
      outlineVariant: Color(0xffd2bfb3),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd6),
      inversePrimary: Color(0xff6f3a0d),
      primaryFixed: Color(0xffffdcc5),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb784),
      onPrimaryFixedVariant: Color(0xff200b00),
      secondaryFixed: Color(0xffffdcc5),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffe4bfa7),
      onSecondaryFixedVariant: Color(0xff1e0d02),
      tertiaryFixed: Color(0xffe4e6ae),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffc8ca94),
      onTertiaryFixedVariant: Color(0xff111200),
      surfaceDim: Color(0xff19120d),
      surfaceBright: Color(0xff594e47),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff261e18),
      surfaceContainer: Color(0xff382f29),
      surfaceContainerHigh: Color(0xff433933),
      surfaceContainerHighest: Color(0xff4f453e),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
