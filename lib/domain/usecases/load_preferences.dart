import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';

class LoadPreferences {
  final PreferencesRepository repo;
  LoadPreferences(this.repo);
  Future<UserPreferences> call() => repo.load();
}
