import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_list/models/task.dart';

class DBHelper {
    static Database? _db;
    static final int _version = 1;
    static final String _tableName = "tasks";
    static Future<void> initDb() async {
      if(_db != null){
        return;
      }
      try{
        String _path = await getDatabasesPath()+'tasks.db';
        _db = await openDatabase(
            _path,
            version: _version,
            onCreate: (db, version){
              print("every thing is okey in db_helper");
              return db.execute(
                "CREATE TABLE $_tableName("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                    "title STRING, note TEXT, date STRING,"
                    "startTime STRING , endTime STRING,"
                    "remind STRING, repeat STRING,"
                    "color INTEGER, isCompleted INTEGER)",
              );
            }
            );
      }catch(e){
        print(e);
      }
    }

    static Future<int> insert(Task task) async {
      return await _db?.insert(_tableName, task.toJson())??1;
    }

    static Future<List<Map<String, dynamic>>> query() async{
      return await _db!.query(_tableName);

    }

    static delete(Task task)async{
      await _db!.delete(_tableName , where: 'id=?', whereArgs: [task.id]);
    }

    static update(int id) async{
      await _db!.rawUpdate('''Update tasks
       SET isCompleted = ?
       WHERE id = ?''',[1,id]);
    }

    static deleteThePreviousDayTasks(List<Task> tasks) {
      var _now = DateTime.now();
      String _currentDate = DateFormat.yMd().format(_now);
      int _day = int.parse(_currentDate.split("/")[1]);
      int _month = int.parse(_currentDate.split("/")[0]);
      int _year = int.parse(_currentDate.split("/")[2]);
      int _taskDay;
      int _taskMonth;
      int _taskYear;
      print(_currentDate);
      tasks.forEach((task) async {
        _taskDay =  int.parse(task.date!.split("/")[1]);
        _taskMonth = int.parse(task.date!.split("/")[0]);
        _taskYear = int.parse(task.date!.split("/")[2]);
        print(_taskYear);
        if(_taskDay < _day && _taskMonth <= _month && _taskYear <= _year){
          print("The deleted task date is "+'${task.date}');
          await delete(task);
        }else {
          print("The not deleted task date is "+'${task.date}');
        }
      });
    }
}
