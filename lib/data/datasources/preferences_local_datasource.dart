import 'package:hive_flutter/hive_flutter.dart';

class PreferencesLocalDataSource {
  static const String prefsKey = 'prefs';
  final Box<Map> box;
  PreferencesLocalDataSource(this.box);

  Future<Map?> get() async => box.get(prefsKey);
  Future<void> put(Map value) async => box.put(prefsKey, value);
}
