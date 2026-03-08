import 'package:flutter/material.dart';

class Brand {
  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF6C5CE7);
  static const Color tertiary = Color(0xFF5E548E);

  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color restPrimary = Color(0xFF10B981);
  static const Color restBackground = Color(0xFFECFDF5);

  static const Color energyHighText = Color(0xFFE11D48);
  static const Color energyHighBg = Color(0xFFFFE4E6);

  static const Color energyMediumText = Color(0xFFD97706);
  static const Color energyMediumBg = Color(0xFFFEF3C7);

  static const Color energyLowText = Color(0xFF2563EB);
  static const Color energyLowBg = Color(0xFFDBEAFE);

  static const Color background = Color(0xFFF8F9FE);
  static const Color backgroundAlt = Color(0xFFF5F7FB);
  static const Color backgroundGrey = Color(0xFFE8ECEF);
  static const Color backgroundFocus = Color(0xFFF7F4FF);
  static const Color surface = Colors.white;

  static const Color tipBg = Color(0xFFF0F1FA);
  static const Color tipBorder = Color(0xFFE0E0F0);

  static const Color textMain = Color(0xFF1E1E2D);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocus = Color(0xFF6366F1);

  static const Color selectedBg = Color(0xFFEEF2FF);

  static const Color neutralBg = Color(0xFFF5F6FA);

  static const Color transparent = Colors.transparent;

  static const Color shadow = Color(0x0D000000);

  // Helper to access colors from context
  static BrandColors of(BuildContext context) {
    return Theme.of(context).extension<BrandColors>() ?? light;
  }

  // Default light theme instance
  static final BrandColors light = BrandColors(
    primary: primary,
    secondary: secondary,
    tertiary: tertiary,
    success: success,
    warning: warning,
    error: error,
    info: info,
    restPrimary: restPrimary,
    restBackground: restBackground,
    energyHighText: energyHighText,
    energyHighBg: energyHighBg,
    energyMediumText: energyMediumText,
    energyMediumBg: energyMediumBg,
    energyLowText: energyLowText,
    energyLowBg: energyLowBg,
    background: background,
    backgroundAlt: backgroundAlt,
    backgroundGrey: backgroundGrey,
    backgroundFocus: backgroundFocus,
    surface: surface,
    tipBg: tipBg,
    tipBorder: tipBorder,
    textMain: textMain,
    textSecondary: textSecondary,
    textLight: textLight,
    textWhite: textWhite,
    border: border,
    borderFocus: borderFocus,
    selectedBg: selectedBg,
    neutralBg: neutralBg,
    shadow: shadow,
    transparent: transparent,
  );

  // Dark theme instance for cognitive accessibility
  static final BrandColors dark = BrandColors(
    primary: const Color(0xFF818CF8), // Lighter Indigo
    secondary: const Color(0xFFA78BFA), // Lighter Purple
    tertiary: const Color(0xFFC4B5FD),
    success: const Color(0xFF4ADE80),
    warning: const Color(0xFFFBBF24),
    error: const Color(0xFFF87171),
    info: const Color(0xFF60A5FA),
    restPrimary: const Color(0xFF34D399),
    restBackground: const Color(0xFF064E3B), // Dark Green bg
    energyHighText: const Color(0xFFFDA4AF), // Light Red text
    energyHighBg: const Color(0xFF881337), // Dark Red bg
    energyMediumText: const Color(0xFFFDE68A), // Light Amber text
    energyMediumBg: const Color(0xFF78350F), // Dark Amber bg
    energyLowText: const Color(0xFFBFDBFE), // Light Blue text
    energyLowBg: const Color(0xFF1E3A8A), // Dark Blue bg
    background: const Color(0xFF121212), // Dark Background
    backgroundAlt: const Color(0xFF1F2937),
    backgroundGrey: const Color(0xFF374151),
    backgroundFocus: const Color(0xFF1E1E2E),
    surface: const Color(0xFF1E1E2D), // Surface slightly lighter
    tipBg: const Color(0xFF312E81), // Dark Indigo bg
    tipBorder: const Color(0xFF4338CA),
    textMain: const Color(0xFFF3F4F6), // Off-white
    textSecondary: const Color(0xFF9CA3AF), // Light Grey
    textLight: const Color(0xFF6B7280),
    textWhite: const Color(0xFF111827), // Dark text on light components if any
    border: const Color(0xFF374151),
    borderFocus: const Color(0xFF818CF8),
    selectedBg: const Color(0xFF312E81),
    neutralBg: const Color(0xFF1F2937),
    shadow: const Color(0x80000000), // Stronger shadow for dark mode
    transparent: Colors.transparent,
  );
}

@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color restPrimary;
  final Color restBackground;
  final Color energyHighText;
  final Color energyHighBg;
  final Color energyMediumText;
  final Color energyMediumBg;
  final Color energyLowText;
  final Color energyLowBg;
  final Color background;
  final Color backgroundAlt;
  final Color backgroundGrey;
  final Color backgroundFocus;
  final Color surface;
  final Color tipBg;
  final Color tipBorder;
  final Color textMain;
  final Color textSecondary;
  final Color textLight;
  final Color textWhite;
  final Color border;
  final Color borderFocus;
  final Color selectedBg;
  final Color neutralBg;
  final Color shadow;
  final Color transparent;

  const BrandColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.restPrimary,
    required this.restBackground,
    required this.energyHighText,
    required this.energyHighBg,
    required this.energyMediumText,
    required this.energyMediumBg,
    required this.energyLowText,
    required this.energyLowBg,
    required this.background,
    required this.backgroundAlt,
    required this.backgroundGrey,
    required this.backgroundFocus,
    required this.surface,
    required this.tipBg,
    required this.tipBorder,
    required this.textMain,
    required this.textSecondary,
    required this.textLight,
    required this.textWhite,
    required this.border,
    required this.borderFocus,
    required this.selectedBg,
    required this.neutralBg,
    required this.shadow,
    required this.transparent,
  });

  @override
  BrandColors copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? restPrimary,
    Color? restBackground,
    Color? energyHighText,
    Color? energyHighBg,
    Color? energyMediumText,
    Color? energyMediumBg,
    Color? energyLowText,
    Color? energyLowBg,
    Color? background,
    Color? backgroundAlt,
    Color? backgroundGrey,
    Color? backgroundFocus,
    Color? surface,
    Color? tipBg,
    Color? tipBorder,
    Color? textMain,
    Color? textSecondary,
    Color? textLight,
    Color? textWhite,
    Color? border,
    Color? borderFocus,
    Color? selectedBg,
    Color? neutralBg,
    Color? shadow,
    Color? transparent,
  }) {
    return BrandColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      restPrimary: restPrimary ?? this.restPrimary,
      restBackground: restBackground ?? this.restBackground,
      energyHighText: energyHighText ?? this.energyHighText,
      energyHighBg: energyHighBg ?? this.energyHighBg,
      energyMediumText: energyMediumText ?? this.energyMediumText,
      energyMediumBg: energyMediumBg ?? this.energyMediumBg,
      energyLowText: energyLowText ?? this.energyLowText,
      energyLowBg: energyLowBg ?? this.energyLowBg,
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      backgroundGrey: backgroundGrey ?? this.backgroundGrey,
      backgroundFocus: backgroundFocus ?? this.backgroundFocus,
      surface: surface ?? this.surface,
      tipBg: tipBg ?? this.tipBg,
      tipBorder: tipBorder ?? this.tipBorder,
      textMain: textMain ?? this.textMain,
      textSecondary: textSecondary ?? this.textSecondary,
      textLight: textLight ?? this.textLight,
      textWhite: textWhite ?? this.textWhite,
      border: border ?? this.border,
      borderFocus: borderFocus ?? this.borderFocus,
      selectedBg: selectedBg ?? this.selectedBg,
      neutralBg: neutralBg ?? this.neutralBg,
      shadow: shadow ?? this.shadow,
      transparent: transparent ?? this.transparent,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) {
      return this;
    }
    return BrandColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      restPrimary: Color.lerp(restPrimary, other.restPrimary, t)!,
      restBackground: Color.lerp(restBackground, other.restBackground, t)!,
      energyHighText: Color.lerp(energyHighText, other.energyHighText, t)!,
      energyHighBg: Color.lerp(energyHighBg, other.energyHighBg, t)!,
      energyMediumText: Color.lerp(
        energyMediumText,
        other.energyMediumText,
        t,
      )!,
      energyMediumBg: Color.lerp(energyMediumBg, other.energyMediumBg, t)!,
      energyLowText: Color.lerp(energyLowText, other.energyLowText, t)!,
      energyLowBg: Color.lerp(energyLowBg, other.energyLowBg, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      backgroundGrey: Color.lerp(backgroundGrey, other.backgroundGrey, t)!,
      backgroundFocus: Color.lerp(backgroundFocus, other.backgroundFocus, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      tipBg: Color.lerp(tipBg, other.tipBg, t)!,
      tipBorder: Color.lerp(tipBorder, other.tipBorder, t)!,
      textMain: Color.lerp(textMain, other.textMain, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      textWhite: Color.lerp(textWhite, other.textWhite, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      selectedBg: Color.lerp(selectedBg, other.selectedBg, t)!,
      neutralBg: Color.lerp(neutralBg, other.neutralBg, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      transparent: Color.lerp(transparent, other.transparent, t)!,
    );
  }
}
