import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mindease/domain/entities/task.dart';
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
  final TaskEnergy? energyLevel;
  final InfoDensity? infoDensity;
  final AppThemeMode themeMode;

  const AccessibilityState({
    required this.focusMode,
    required this.highContrast,
    required this.fontScale,
    required this.spacingScale,
    required this.summaryMode,
    required this.animationsEnabled,
    this.energyLevel,
    this.infoDensity,
    this.themeMode = AppThemeMode.system,
  });

  AccessibilityState copyWith({
    bool? focusMode,
    bool? highContrast,
    double? fontScale,
    double? spacingScale,
    bool? summaryMode,
    bool? animationsEnabled,
    TaskEnergy? energyLevel,
    InfoDensity? infoDensity,
    AppThemeMode? themeMode,
  }) {
    return AccessibilityState(
      focusMode: focusMode ?? this.focusMode,
      highContrast: highContrast ?? this.highContrast,
      fontScale: fontScale ?? this.fontScale,
      spacingScale: spacingScale ?? this.spacingScale,
      summaryMode: summaryMode ?? this.summaryMode,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      energyLevel: energyLevel ?? this.energyLevel,
      infoDensity: infoDensity ?? this.infoDensity,
      themeMode: themeMode ?? this.themeMode,
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
    energyLevel,
    infoDensity,
    themeMode,
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
           themeMode: AppThemeMode.system,
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
        energyLevel: prefs.energyLevel,
        infoDensity: prefs.infoDensity,
        themeMode: prefs.themeMode,
      ),
    );
  }

  Future<void> setHighContrast(bool on) async {
    await updateContrast(on);
    emit(state.copyWith(highContrast: on));
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final updated = UserPreferences(
      focusMode: state.focusMode,
      highContrast: state.highContrast,
      fontScale: state.fontScale,
      spacingScale: state.spacingScale,
      summaryMode: state.summaryMode,
      animationsEnabled: state.animationsEnabled,
      energyLevel: state.energyLevel,
      infoDensity: state.infoDensity,
      themeMode: mode,
    );
    await savePreferences(updated);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setFocusMode(bool on) async {
    final updated = UserPreferences(
      focusMode: on,
      highContrast: state.highContrast,
      fontScale: state.fontScale,
      spacingScale: state.spacingScale,
      summaryMode: state.summaryMode,
      animationsEnabled: state.animationsEnabled,
      energyLevel: state.energyLevel,
      infoDensity: state.infoDensity,
      themeMode: state.themeMode,
    );
    await savePreferences(updated);
    emit(state.copyWith(focusMode: on));
  }

  Future<void> setEnergyLevel(TaskEnergy? level) async {
    final updated = UserPreferences(
      focusMode: state.focusMode,
      highContrast: state.highContrast,
      fontScale: state.fontScale,
      spacingScale: state.spacingScale,
      summaryMode: state.summaryMode,
      animationsEnabled: state.animationsEnabled,
      energyLevel: level,
      infoDensity: state.infoDensity,
      themeMode: state.themeMode,
    );
    await savePreferences(updated);
    emit(state.copyWith(energyLevel: level));
  }

  Future<void> updateSettings({
    bool? focusMode,
    TaskEnergy? energyLevel,
    InfoDensity? infoDensity,
    AppThemeMode? themeMode,
  }) async {
    final nextFocusMode = focusMode ?? state.focusMode;
    // Note: this logic assumes we don't want to set energyLevel to null explicitly via this method if it was not null.
    // If energyLevel is passed as null, we keep current.
    // This is fine for the current use case where we always have a value selected in UI.
    final nextEnergyLevel = energyLevel ?? state.energyLevel;
    final nextInfoDensity = infoDensity ?? state.infoDensity;
    final nextThemeMode = themeMode ?? state.themeMode;

    final updated = UserPreferences(
      focusMode: nextFocusMode,
      highContrast: state.highContrast,
      fontScale: state.fontScale,
      spacingScale: state.spacingScale,
      summaryMode: state.summaryMode,
      animationsEnabled: state.animationsEnabled,
      energyLevel: nextEnergyLevel,
      infoDensity: nextInfoDensity,
      themeMode: nextThemeMode,
    );
    await savePreferences(updated);
    emit(
      state.copyWith(
        focusMode: nextFocusMode,
        energyLevel: nextEnergyLevel,
        infoDensity: nextInfoDensity,
        themeMode: nextThemeMode,
      ),
    );
  }
}
