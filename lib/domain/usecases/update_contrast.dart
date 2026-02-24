import '../repositories/preferences_repository.dart';

class UpdateContrast {
  final PreferencesRepository repo;
  UpdateContrast(this.repo);

  Future<void> call(bool enable) async {
    final current = await repo.load();
    final updated = current.copyWith(highContrast: enable);
    await repo.save(updated);
  }
}
