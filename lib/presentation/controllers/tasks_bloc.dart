import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/domain/repositories/task_repository.dart';

abstract class TasksEvent {}

class LoadTasks extends TasksEvent {}

class AddTask extends TasksEvent {
  final Task task;
  AddTask(this.task);
}

class UpdateTask extends TasksEvent {
  final Task task;
  UpdateTask(this.task);
}

class DeleteTask extends TasksEvent {
  final String id;
  DeleteTask(this.id);
}

class MoveTask extends TasksEvent {
  final String id;
  final bool inProgress;
  final bool done;
  MoveTask(this.id, {required this.inProgress, required this.done});
}

class TasksState {
  final List<Task> tasks;
  final bool loading;
  const TasksState({required this.tasks, this.loading = false});
}

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository repo;
  TasksBloc(this.repo) : super(const TasksState(tasks: [])) {
    on<LoadTasks>(_onLoad);
    on<AddTask>(_onAdd);
    on<UpdateTask>(_onUpdate);
    on<DeleteTask>(_onDelete);
    on<MoveTask>(_onMove);
  }

  Future<void> _onLoad(LoadTasks event, Emitter<TasksState> emit) async {
    emit(TasksState(tasks: state.tasks, loading: true));
    final list = await repo.list();
    emit(TasksState(tasks: list, loading: false));
  }

  Future<void> _onAdd(AddTask event, Emitter<TasksState> emit) async {
    await repo.save(event.task);
    add(LoadTasks());
  }

  Future<void> _onUpdate(UpdateTask event, Emitter<TasksState> emit) async {
    await repo.save(event.task);
    add(LoadTasks());
  }

  Future<void> _onDelete(DeleteTask event, Emitter<TasksState> emit) async {
    await repo.delete(event.id);
    add(LoadTasks());
  }

  Future<void> _onMove(MoveTask event, Emitter<TasksState> emit) async {
    await repo.move(event.id, inProgress: event.inProgress, done: event.done);
    add(LoadTasks());
  }
}
