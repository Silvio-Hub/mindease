import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks(String userId);
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Stream<List<Task>> watchTasks(String userId);
}
