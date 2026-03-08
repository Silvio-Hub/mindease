import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/domain/repositories/task_repository.dart';

class GetTasks {
  final TaskRepository repository;

  GetTasks(this.repository);

  Stream<List<Task>> call(String userId) {
    return repository.watchTasks(userId);
  }
}
