import 'package:mindease/domain/entities/user_preferences.dart';
import 'package:mindease/domain/repositories/preferences_repository.dart';
import '../datasources/preferences_local_datasource.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesLocalDataSource local;
  PreferencesRepositoryImpl(this.local);

  @override
  Future<UserPreferences> load() async {
    final map = await local.get();
    if (map == null) {
      return const UserPreferences(
        focusMode: false,
        highContrast: false,
        fontScale: 1.0,
        spacingScale: 1.0,
        summaryMode: true,
        animationsEnabled: true,
      );
    }
    return UserPreferences(
      focusMode: (map['focusMode'] as bool?) ?? false,
      highContrast: (map['highContrast'] as bool?) ?? false,
      fontScale: (map['fontScale'] as double?) ?? 1.0,
      spacingScale: (map['spacingScale'] as double?) ?? 1.0,
      summaryMode: (map['summaryMode'] as bool?) ?? true,
      animationsEnabled: (map['animationsEnabled'] as bool?) ?? true,
    );
  }

  @override
  Future<void> save(UserPreferences prefs) async {
    await local.put({
      'focusMode': prefs.focusMode,
      'highContrast': prefs.highContrast,
      'fontScale': prefs.fontScale,
      'spacingScale': prefs.spacingScale,
      'summaryMode': prefs.summaryMode,
      'animationsEnabled': prefs.animationsEnabled,
    });
  }
}
