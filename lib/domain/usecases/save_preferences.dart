import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';

class SavePreferences {
  final PreferencesRepository repo;
  SavePreferences(this.repo);
  Future<void> call(UserPreferences prefs) => repo.save(prefs);
}
