import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> list();
  Future<void> save(Task task);
  Future<void> delete(String id);
  Future<void> move(String id, {required bool inProgress, required bool done});
}
