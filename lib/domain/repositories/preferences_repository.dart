import '../entities/user_preferences.dart';

abstract class PreferencesRepository {
  Future<UserPreferences> load();
  Future<void> save(UserPreferences prefs);
}
