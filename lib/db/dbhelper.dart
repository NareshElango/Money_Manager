import 'package:hive/hive.dart';

class dbhelper {
  static final dbhelper _instance = dbhelper._internal();
  Box? _box;

  dbhelper._internal();

  factory dbhelper() {
    return _instance;
  }

  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox('money');
    }
  }

  Future<void> addData(int amt, DateTime date, String note, String type) async {
    await init(); // Ensure box is initialized
    final value = {'amount': amt, 'Date': date, 'Note': note, 'Type': type};
    await _box!.add(value);
  }

  

  Future<Map<String, dynamic>> fetch() async {
    await init(); // Ensure box is initialized
    Map<String, dynamic> data = {};
    for (int i = 0; i < _box!.length; i++) {
      data[i.toString()] = _box!.getAt(i);
    }
    return data;
  }
}
