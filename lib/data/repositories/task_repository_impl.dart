import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/domain/repositories/task_repository.dart';
import '../datasources/tasks_local_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TasksLocalDataSource local;
  TaskRepositoryImpl(this.local);

  @override
  Future<List<Task>> list() async {
    return local.list();
  }

  @override
  Future<void> save(Task task) async {
    await local.put(task.id, task);
  }

  @override
  Future<void> delete(String id) => local.delete(id);

  @override
  Future<void> move(
    String id, {
    required bool inProgress,
    required bool done,
  }) async {
    final list = await local.list();
    try {
      final task = list.firstWhere((t) => t.id == id);
      final updated = task.copyWith(inProgress: inProgress, done: done);
      await local.put(id, updated);
    } catch (_) {
      // Task not found
    }
  }
}
