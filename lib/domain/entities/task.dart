class Task {
  final String id;
  final String title;
  final bool inProgress;
  final bool done;
  final List<String> checklist;

  const Task({
    required this.id,
    required this.title,
    this.inProgress = false,
    this.done = false,
    this.checklist = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    bool? inProgress,
    bool? done,
    List<String>? checklist,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      inProgress: inProgress ?? this.inProgress,
      done: done ?? this.done,
      checklist: checklist ?? this.checklist,
    );
  }
}
