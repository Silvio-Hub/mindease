class UserPreferences {
  final bool focusMode;
  final bool highContrast;
  final double fontScale;
  final double spacingScale;
  final bool summaryMode;
  final bool animationsEnabled;

  const UserPreferences({
    required this.focusMode,
    required this.highContrast,
    required this.fontScale,
    required this.spacingScale,
    required this.summaryMode,
    required this.animationsEnabled,
  });

  UserPreferences copyWith({
    bool? focusMode,
    bool? highContrast,
    double? fontScale,
    double? spacingScale,
    bool? summaryMode,
    bool? animationsEnabled,
  }) {
    return UserPreferences(
      focusMode: focusMode ?? this.focusMode,
      highContrast: highContrast ?? this.highContrast,
      fontScale: fontScale ?? this.fontScale,
      spacingScale: spacingScale ?? this.spacingScale,
      summaryMode: summaryMode ?? this.summaryMode,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }
}
