import 'package:flutter/material.dart';

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
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: base.textTheme.apply(fontSizeFactor: fontScale),
    // [A11Y-Cog] Ritmo de navegação controlado: transições removíveis
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
    // [A11Y-Cog] Sem animação para reduzir estímulos visuais
    return child;
  }
}
