import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mindease/domain/entities/user_preferences.dart';
import 'package:mindease/domain/usecases/load_preferences.dart';
import 'package:mindease/domain/usecases/save_preferences.dart';
import 'package:mindease/domain/usecases/update_contrast.dart';

class AccessibilityState extends Equatable {
  final bool focusMode;
  final bool highContrast;
  final double fontScale;
  final double spacingScale;
  final bool summaryMode;
  final bool animationsEnabled;

  const AccessibilityState({
    required this.focusMode,
    required this.highContrast,
    required this.fontScale,
    required this.spacingScale,
    required this.summaryMode,
    required this.animationsEnabled,
  });

  AccessibilityState copyWith({
    bool? focusMode,
    bool? highContrast,
    double? fontScale,
    double? spacingScale,
    bool? summaryMode,
    bool? animationsEnabled,
  }) {
    return AccessibilityState(
      focusMode: focusMode ?? this.focusMode,
      highContrast: highContrast ?? this.highContrast,
      fontScale: fontScale ?? this.fontScale,
      spacingScale: spacingScale ?? this.spacingScale,
      summaryMode: summaryMode ?? this.summaryMode,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
    focusMode,
    highContrast,
    fontScale,
    spacingScale,
    summaryMode,
    animationsEnabled,
  ];
}

class AccessibilityCubit extends Cubit<AccessibilityState> {
  final UpdateContrast updateContrast;
  final SavePreferences savePreferences;
  final LoadPreferences loadPreferences;

  AccessibilityCubit({
    required this.updateContrast,
    required this.savePreferences,
    required this.loadPreferences,
  }) : super(
         const AccessibilityState(
           focusMode: false,
           highContrast: false,
           fontScale: 1.0,
           spacingScale: 1.0,
           summaryMode: true,
           animationsEnabled: true,
         ),
       );

  Future<void> init() async {
    final prefs = await loadPreferences();
    emit(
      AccessibilityState(
        focusMode: prefs.focusMode,
        highContrast: prefs.highContrast,
        fontScale: prefs.fontScale,
        spacingScale: prefs.spacingScale,
        summaryMode: prefs.summaryMode,
        animationsEnabled: prefs.animationsEnabled,
      ),
    );
  }

  Future<void> setHighContrast(bool on) async {
    // [A11Y-Cog] Alto contraste melhora legibilidade em ambientes cognitivos
    await updateContrast(on);
    emit(state.copyWith(highContrast: on));
  }

  Future<void> setFocusMode(bool on) async {
    final updated = UserPreferences(
      focusMode: on,
      highContrast: state.highContrast,
      fontScale: state.fontScale,
      spacingScale: state.spacingScale,
      summaryMode: state.summaryMode,
      animationsEnabled: state.animationsEnabled,
    );
    await savePreferences(updated);
    emit(state.copyWith(focusMode: on));
  }
}
