import 'package:get/get.dart';
import 'package:to_do_list/db/db_helper.dart';

import '../models/task.dart';

class TaskController extends GetxController{
  var taskList = <Task>[].obs;
  @override
  onReady(){
   getTask();
   // to delete the tasks of the day that user has no access to it

    super.onReady();
   print("The task controller is ready");
  }
  Future<int> addTask({required Task task}) async{
    return await DBHelper.insert(task);
  }

  void getTask() async{
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll((tasks.map((data) => Task.fromJson(data))).toList());
  }

  void delete(Task task){
    DBHelper.delete(task);
    getTask();
  }

  void markTaskCompleted(int id) async{
    await DBHelper.update(id);
    getTask();
  }

  // to delete the unreachable old tasks from the database
  void deleteThePreviousDayTasks(){
     getTask();
     DBHelper.deleteThePreviousDayTasks(taskList);
  }
}
