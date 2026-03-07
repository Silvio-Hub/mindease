import 'package:equatable/equatable.dart';

enum TaskEnergy {
  high,
  medium,
  low,
}

enum FocusDuration {
  short(15),
  medium(30),
  long(45),
  extraLong(60);

  final int minutes;
  const FocusDuration(this.minutes);
}

class Task extends Equatable {
  final String id;
  final String userId;
  final String title;
  final List<String> subtasks;
  final bool inProgress;
  final bool completed;
  final DateTime scheduledFor;
  final FocusDuration focusDuration;
  final TaskEnergy energy;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.subtasks = const [],
    this.inProgress = false,
    this.completed = false,
    required this.scheduledFor,
    required this.focusDuration,
    required this.energy,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    List<String>? subtasks,
    bool? inProgress,
    bool? completed,
    DateTime? scheduledFor,
    FocusDuration? focusDuration,
    TaskEnergy? energy,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      subtasks: subtasks ?? this.subtasks,
      inProgress: inProgress ?? this.inProgress,
      completed: completed ?? this.completed,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      focusDuration: focusDuration ?? this.focusDuration,
      energy: energy ?? this.energy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    subtasks,
    inProgress,
    completed,
    scheduledFor,
    focusDuration,
    energy,
    createdAt,
  ];
}
