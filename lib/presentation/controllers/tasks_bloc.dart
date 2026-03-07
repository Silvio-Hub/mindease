import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/domain/usecases/add_task_usecase.dart';
import 'package:mindease/domain/usecases/delete_task_usecase.dart';
import 'package:mindease/domain/usecases/get_current_user.dart';
import 'package:mindease/domain/usecases/get_tasks.dart';
import 'package:mindease/domain/usecases/update_task_usecase.dart';

abstract class TasksEvent {}

class LoadTasks extends TasksEvent {}

class TasksUpdated extends TasksEvent {
  final List<Task> tasks;
  TasksUpdated(this.tasks);
}

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
  final bool completed;
  MoveTask(this.id, {required this.inProgress, required this.completed});
}

class TasksState {
  final List<Task> tasks;
  final bool loading;
  final String? error;
  const TasksState({required this.tasks, this.loading = false, this.error});
}

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTasks getTasks;
  final AddTaskUseCase addTask;
  final UpdateTaskUseCase updateTask;
  final DeleteTaskUseCase deleteTask;
  final GetCurrentUser getCurrentUser;

  StreamSubscription<List<Task>>? _tasksSubscription;

  TasksBloc({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
    required this.getCurrentUser,
  }) : super(const TasksState(tasks: [])) {
    on<LoadTasks>(_onLoad);
    on<TasksUpdated>(_onTasksUpdated);
    on<AddTask>(_onAdd);
    on<UpdateTask>(_onUpdate);
    on<DeleteTask>(_onDelete);
    on<MoveTask>(_onMove);
  }

  Future<void> _onLoad(LoadTasks event, Emitter<TasksState> emit) async {
    emit(TasksState(tasks: state.tasks, loading: true));
    try {
      final user = await getCurrentUser();
      if (user != null) {
        await _tasksSubscription?.cancel();
        _tasksSubscription = getTasks(user.id).listen((tasks) {
          add(TasksUpdated(tasks));
        });
      } else {
        emit(const TasksState(tasks: [], loading: false));
      }
    } catch (e) {
      emit(TasksState(tasks: state.tasks, loading: false, error: e.toString()));
    }
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<TasksState> emit) {
    emit(TasksState(tasks: event.tasks, loading: false));
  }

  Future<void> _onAdd(AddTask event, Emitter<TasksState> emit) async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        final taskWithUserId = event.task.copyWith(userId: user.id);
        await addTask(taskWithUserId);
      }
    } catch (e) {
      emit(TasksState(tasks: state.tasks, error: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateTask event, Emitter<TasksState> emit) async {
    try {
      await updateTask(event.task);
    } catch (e) {
      emit(TasksState(tasks: state.tasks, error: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteTask event, Emitter<TasksState> emit) async {
    try {
      await deleteTask(event.id);
    } catch (e) {
      emit(TasksState(tasks: state.tasks, error: e.toString()));
    }
  }

  Future<void> _onMove(MoveTask event, Emitter<TasksState> emit) async {
    try {
      final taskIndex = state.tasks.indexWhere((t) => t.id == event.id);
      if (taskIndex != -1) {
        final task = state.tasks[taskIndex];
        final updatedTask = task.copyWith(
          inProgress: event.inProgress,
          completed: event.completed,
        );
        await updateTask(updatedTask);
      }
    } catch (e) {
      emit(TasksState(tasks: state.tasks, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
