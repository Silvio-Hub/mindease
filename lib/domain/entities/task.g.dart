// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      inProgress: fields[2] as bool,
      done: fields[3] as bool,
      checklist: (fields[4] as List).cast<String>(),
      dueDate: fields[5] as DateTime?,
      durationMinutes: fields[6] as int?,
      energy: fields[7] as TaskEnergy?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.inProgress)
      ..writeByte(3)
      ..write(obj.done)
      ..writeByte(4)
      ..write(obj.checklist)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.durationMinutes)
      ..writeByte(7)
      ..write(obj.energy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskEnergyAdapter extends TypeAdapter<TaskEnergy> {
  @override
  final int typeId = 1;

  @override
  TaskEnergy read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskEnergy.high;
      case 1:
        return TaskEnergy.medium;
      case 2:
        return TaskEnergy.low;
      default:
        return TaskEnergy.high;
    }
  }

  @override
  void write(BinaryWriter writer, TaskEnergy obj) {
    switch (obj) {
      case TaskEnergy.high:
        writer.writeByte(0);
        break;
      case TaskEnergy.medium:
        writer.writeByte(1);
        break;
      case TaskEnergy.low:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskEnergyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
