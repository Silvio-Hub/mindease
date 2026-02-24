import 'package:hive_flutter/hive_flutter.dart';

class TasksLocalDataSource {
  final Box<Map> box;
  TasksLocalDataSource(this.box);

  Future<List<Map>> list() async => box.values.cast<Map>().toList();
  Future<void> put(String id, Map value) async => box.put(id, value);
  Future<void> delete(String id) async => box.delete(id);
}
