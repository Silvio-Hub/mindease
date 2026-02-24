import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/domain/repositories/task_repository.dart';
import '../datasources/tasks_local_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TasksLocalDataSource local;
  TaskRepositoryImpl(this.local);

  @override
  Future<List<Task>> list() async {
    final list = await local.list();
    return list
        .map((m) => Task(
              id: (m['id'] as String?) ?? '',
              title: (m['title'] as String?) ?? '',
              inProgress: (m['inProgress'] as bool?) ?? false,
              done: (m['done'] as bool?) ?? false,
              checklist: (m['checklist'] as List?)?.cast<String>() ?? const [],
            ))
        .toList();
  }

  @override
  Future<void> save(Task task) async {
    await local.put(task.id, {
      'id': task.id,
      'title': task.title,
      'inProgress': task.inProgress,
      'done': task.done,
      'checklist': task.checklist,
    });
  }

  @override
  Future<void> delete(String id) => local.delete(id);

  @override
  Future<void> move(String id, {required bool inProgress, required bool done}) async {
    final list = await local.list();
    final idx = list.indexWhere((m) => m['id'] == id);
    if (idx == -1) return;
    final m = Map<String, dynamic>.from(list[idx]);
    m['inProgress'] = inProgress;
    m['done'] = done;
    await local.put(id, m);
  }
}
