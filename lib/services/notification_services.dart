import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/ui/pages/notification_screen.dart';

class NotifyHelper {
  FlutterLocalNotificationsPlugin
      // an instance from flutterLocalNotificationsPlugin that we will use later
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // this a function that we will call from the home page
  initializeNotification() async {
    _configureLocalTimezone();
    // tz.initializeTimeZones();
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    // the first parameter is for initialization
    // and the second one is for showing the content when some one click on
    // notification
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  displayNotification({required String title, required String body}) async {
    print("doing test");
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      // this field is responsible for sound
      payload: 'It could be anything you pass',
    );
  }

  scheduledNotification(int hour, int minutes, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!.toInt(),
      task.title,
      task.note,
      _convertTime(hour, minutes, task),
      // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
          android: AndroidNotificationDetails(
              'your channel id', 'your channel name',
              channelDescription: 'your channel description')),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: "${task.title}|${task.note}|${task.date}|",
    );
  }

  tz.TZDateTime _convertTime(int hour, int minutes, Task task) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print("The current time is $now");
    tz.TZDateTime scheduleDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minutes);
    print("the scheduleDate is "+'$scheduleDate');

    int remind = task.remind!;
    if (scheduleDate.subtract(Duration(minutes: remind)).isBefore(now)) {

      // if daily task
      if (task.repeat == "Daily") {
        scheduleDate = scheduleDate
            .add(const Duration(days: 1))
            .subtract(Duration(minutes: remind));
        return scheduleDate;
      }

      // if weekly task
      if (task.repeat == "Weekly") {
        scheduleDate = scheduleDate
            .add(const Duration(days: 7))
            .subtract(Duration(minutes: remind));
        return scheduleDate;
      }

    }

    return scheduleDate.subtract(Duration(minutes: remind));
  }

  // to get the local time zone and local location
  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    // here I first get the timeZone and than get the location based on that time zone
    final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }

  // we see whether these things has been initialized or not
  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future selectNotification(String? payload) async {
    if (payload != null) {
      print('notification payload: $payload');
    } else {
      print("Notification Done");
    }
    Get.to(() => NotificationScreen(payload: payload!));
  }

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    Get.dialog(Text("Welcome to flutter"));
  }
}
