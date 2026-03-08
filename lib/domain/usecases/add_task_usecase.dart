import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/domain/repositories/task_repository.dart';

class AddTaskUseCase {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  Future<void> call(Task task) {
    return repository.addTask(task);
  }
}
