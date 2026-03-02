import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
enum TaskEnergy {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
}

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final bool inProgress;
  @HiveField(3)
  final bool done;
  @HiveField(4)
  final List<String> checklist;
  @HiveField(5)
  final DateTime? dueDate;
  @HiveField(6)
  final int? durationMinutes;
  @HiveField(7)
  final TaskEnergy? energy;

  const Task({
    required this.id,
    required this.title,
    this.inProgress = false,
    this.done = false,
    this.checklist = const [],
    this.dueDate,
    this.durationMinutes,
    this.energy,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? inProgress,
    bool? done,
    List<String>? checklist,
    DateTime? dueDate,
    int? durationMinutes,
    TaskEnergy? energy,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      inProgress: inProgress ?? this.inProgress,
      done: done ?? this.done,
      checklist: checklist ?? this.checklist,
      dueDate: dueDate ?? this.dueDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      energy: energy ?? this.energy,
    );
  }
}
