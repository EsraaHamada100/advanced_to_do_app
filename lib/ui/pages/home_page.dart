import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list/controllers/task_controller.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/last_date_storage.dart';
import 'package:to_do_list/services/notification_services.dart';
import 'package:to_do_list/services/theme_services.dart';
import 'package:to_do_list/ui/pages/add_task_page.dart';
import 'package:to_do_list/ui/theme.dart';
import 'package:to_do_list/ui/widgets/button.dart';
import 'package:to_do_list/ui/widgets/input_field.dart';
import 'package:to_do_list/ui/widgets/task_tile.dart';

import '../size_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late Icon modeIcon = ThemeServices().loadThemeFromBox()
  //     ? Icon(Icons.light_mode_outlined)
  //     : Icon(Icons.dark_mode_outlined);
  final TaskController _taskController = Get.put(TaskController());
  var notifyHelper;
  @override
  void initState() {
    // TODO: implement initState
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    // to ask for IOS notifications
    notifyHelper.requestIOSPermissions();
    print("hello we are in init state");

    super.initState();
  }

  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    LastDateStorage lastDateStorage = LastDateStorage();
    if (lastDateStorage.shouldDeletePreviousDayData()) {
      _taskController.deleteThePreviousDayTasks();
    }
    return Scaffold(
      appBar: _appBar(),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Column(
            children: [
              _addTaskBar(),
              _addDateBar(),
              SizedBox(height: 20),
              _showTasks(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      // this background color is come from theme.dart lightTheme/darkTheme backgroundColor
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          ThemeServices().switchTheme();
          // notifyHelper.displayNotification(
          //   title: "Theme changes",
          //   body: Get.isDarkMode
          //       ? "Activated Light Theme"
          //       : "Activated Dark Theme",
          // );
          // notifyHelper.scheduledNotification();
        },
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: const [
        CircleAvatar(
          backgroundImage: AssetImage("images/person.jpeg"),
        ),
        SizedBox(width: 20),
      ],
    );
  }

  Row _addTaskBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              DateFormat.yMMMd().format(DateTime.now()),
              style: subHeadingStyle,
            ),
            Text(
              "Today",
              style: headingStyle,
            ),
          ],
        ),
        MyButton(
          label: '+  add Task',
          onTap: () async {
            // we will wait until he returns and than we will update our taskList
            // by getting the new data from the database
            await Get.to(() => const AddTaskPage());
            _taskController.getTask();
          },
        ),
      ],
    );
  }

  Container _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 20),
      child: DatePicker(
        height: 100,
        width: 80,
        DateTime.now(),
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        dateTextStyle: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        monthTextStyle: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        dayTextStyle: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
        onDateChange: (newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
      ),
    );
  }

  Expanded _showTasks() {
    // _taskController.getTask();
    return Expanded(
      // I do that because I make the list.obs
      child: Obx(() {
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              Task task = _taskController.taskList[index];
              if (task.repeat == "Daily" || task.repeat == "Weekly") {
                // return the string to date againg
                DateTime date =
                    DateFormat.jm().parse(task.startTime.toString());
                String hour;
                String minutes = task.startTime!.split(":")[1].split(" ")[0];

                if (task.startTime!.split(":")[1].split(" ")[1] == "PM" &&
                    int.parse(task.startTime!.split(":")[0]) != 12) {
                  int hourInteger =
                      int.parse(task.startTime!.split(":")[0]) + 12;
                  hour = hourInteger.toString();
                } else if (task.startTime!.split(":")[1].split(" ")[1] ==
                        "AM" &&
                    int.parse(task.startTime!.split(":")[0]) != 12) {

                  hour = task.startTime!.split(":")[0];

                } else {
                  // it means that task is at 12 AM
                  hour = "0";
                }

                print(task.startTime);
                print("$hour:$minutes");
                notifyHelper.scheduledNotification(
                    int.parse(hour), int.parse(minutes), task);
              }
              else if (task.date == DateFormat.yMd().format(_selectedDate)) {
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomShoot(
                                    context, _taskController.taskList[index]);
                                // _taskController.delete(_taskController.taskList[index]);
                                // // to update our list with the latest value from database
                                // _taskController.getTask();
                              },
                              child: TaskTile(_taskController.taskList[index]),
                            )
                          ],
                        ),
                      ),
                    ));
              } else {
                return Container();
              }
              return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                    child: FadeInAnimation(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showBottomShoot(
                                  context, _taskController.taskList[index]);
                              // _taskController.delete(_taskController.taskList[index]);
                              // // to update our list with the latest value from database
                              // _taskController.getTask();
                            },
                            child: TaskTile(_taskController.taskList[index]),
                          )
                        ],
                      ),
                    ),
                  ));
            });
      }),
    );
  }

  _showBottomShoot(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        color: Get.isDarkMode ? darkGreyClr : Colors.white,
        height: task.isCompleted == 1
            ? MediaQuery.of(context).size.height * 0.24
            : MediaQuery.of(context).size.height * 0.32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
            ),
            task.isCompleted == 1
                ? Container()
                : _bottomShootButton(
                    label: "Task Completed",
                    onTap: () {
                      _taskController.markTaskCompleted(task.id!);
                      Get.back();
                    },
                    color: primaryClr,
                    context: context),
            _bottomShootButton(
                label: "Delete Task",
                onTap: () {
                  _taskController.delete(task);
                  Get.back();
                },
                color: Colors.redAccent,
                context: context),
            _bottomShootButton(
                label: "Close",
                onTap: () {
                  Get.back();
                },
                color: Colors.white,
                context: context,
                isClose: true),
          ],
        ),
      ),
    );
  }
}

_bottomShootButton(
    {required String label,
    required void Function() onTap,
    required Color color,
    bool isClose = false,
    required BuildContext context}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: MediaQuery.of(context).size.width * 0.9,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
            width: 1, color: isClose ? const Color(0xFF303030) : color),
        borderRadius: BorderRadius.circular(20),
        color: isClose
            ? (Get.isDarkMode ? Colors.grey[500] : Colors.white)
            : color,
      ),
      child: Center(
        child: Text(
          label,
          style:
              isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
        ),
      ),
    ),
  );
}
