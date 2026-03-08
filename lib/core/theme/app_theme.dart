import 'package:flutter/material.dart';

import 'package:mindease/core/constants/brand.dart';

ThemeData lightTheme({
  required double fontScale,
  required double spacingScale,
  required bool highContrast,
  required bool animationsEnabled,
}) {
  final base = ThemeData.light();
  final colorScheme = highContrast
      ? const ColorScheme.highContrastLight()
      : base.colorScheme;

  return base.copyWith(
    colorScheme: colorScheme,
    extensions: [Brand.light],
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: base.textTheme.apply(fontSizeFactor: fontScale),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: animationsEnabled
            ? const FadeUpwardsPageTransitionsBuilder()
            : const NoTransitionsBuilder(),
        TargetPlatform.iOS: animationsEnabled
            ? const CupertinoPageTransitionsBuilder()
            : const NoTransitionsBuilder(),
      },
    ),
  );
}

ThemeData darkTheme({
  required double fontScale,
  required double spacingScale,
  required bool highContrast,
  required bool animationsEnabled,
}) {
  final base = ThemeData.dark();
  final colorScheme = highContrast
      ? const ColorScheme.highContrastDark()
      : base.colorScheme;

  return base.copyWith(
    colorScheme: colorScheme,
    extensions: [Brand.dark],
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: base.textTheme.apply(fontSizeFactor: fontScale),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: animationsEnabled
            ? const FadeUpwardsPageTransitionsBuilder()
            : const NoTransitionsBuilder(),
        TargetPlatform.iOS: animationsEnabled
            ? const CupertinoPageTransitionsBuilder()
            : const NoTransitionsBuilder(),
      },
    ),
  );
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
