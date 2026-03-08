import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.subtasks,
    super.inProgress,
    super.completed,
    required super.scheduledFor,
    required super.focusDuration,
    required super.energy,
    required super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json, String id) {
    return TaskModel(
      id: id,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: (json['description'] ?? '') as String,
      subtasks: List<String>.from(json['subtasks'] ?? []),
      inProgress: json['inProgress'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
      scheduledFor: DateTime.parse(json['scheduledFor'] as String),
      focusDuration: _parseFocusDuration(json['focusDuration']),
      energy: _parseEnergy(json['energy']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'subtasks': subtasks,
      'inProgress': inProgress,
      'completed': completed,
      'scheduledFor': scheduledFor.toIso8601String().split('T').first,
      'focusDuration': focusDuration.minutes,
      'energy': energy.name,
      'createdAt': createdAt.toIso8601String().split('T').first,
    };
  }

  static FocusDuration _parseFocusDuration(dynamic value) {
    if (value is int) {
      return FocusDuration.values.firstWhere(
        (e) => e.minutes == value,
        orElse: () => FocusDuration.medium,
      );
    }
    return FocusDuration.medium;
  }

  static TaskEnergy _parseEnergy(dynamic value) {
    if (value is String) {
      return TaskEnergy.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TaskEnergy.medium,
      );
    }
    return TaskEnergy.medium;
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      subtasks: task.subtasks,
      inProgress: task.inProgress,
      completed: task.completed,
      scheduledFor: task.scheduledFor,
      focusDuration: task.focusDuration,
      energy: task.energy,
      createdAt: task.createdAt,
    );
  }
}
