import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks(String userId);
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Stream<List<TaskModel>> watchTasks(String userId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    final snapshot = await firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    final collection = firestore.collection('tasks');
    final docRef = task.id.isEmpty ? collection.doc() : collection.doc(task.id);
    
    // Create a new TaskModel with the generated ID (if it was empty)
    final taskToSave = TaskModel(
      id: docRef.id,
      userId: task.userId,
      title: task.title,
      subtasks: task.subtasks,
      inProgress: task.inProgress,
      completed: task.completed,
      scheduledFor: task.scheduledFor,
      focusDuration: task.focusDuration,
      energy: task.energy,
      createdAt: task.createdAt,
    );

    await docRef.set(taskToSave.toJson());
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    // Ensure we update the document with the correct ID
    if (task.id.isEmpty) {
      throw Exception('Cannot update task without ID');
    }
    await firestore.collection('tasks').doc(task.id).update(task.toJson());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    if (taskId.isEmpty) {
      throw Exception('Cannot delete task without ID');
    }
    await firestore.collection('tasks').doc(taskId).delete();
  }

  @override
  Stream<List<TaskModel>> watchTasks(String userId) {
    return firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
