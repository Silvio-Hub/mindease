import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindease/domain/entities/task.dart';

class TasksLocalDataSource {
  final Box<Task> box;
  TasksLocalDataSource(this.box);

  Future<List<Task>> list() async {
    try {
      return box.values.toList();
    } catch (e) {
      // If data is corrupted (e.g. Map instead of Task), clear the box to reset state
      await box.clear();
      return [];
    }
  }

  Future<void> put(String id, Task value) async => box.put(id, value);
  Future<void> delete(String id) async => box.delete(id);
}
