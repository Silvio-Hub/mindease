enum TaskEnergy { high, medium, low }

class Task {
  final String id;
  final String title;
  final bool inProgress;
  final bool done;
  final List<String> checklist;
  final DateTime? dueDate;
  final int? durationMinutes;
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
