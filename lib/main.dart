import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_startup/flutter_startup.dart';

void doSomeWork(String arg) async {
  // Below throws an exception on Android; likely expected as flutter_startup is for IOS
  // FlutterStartup.startupReason.then((reason) {print("Isolate1 $reason");});

  // below works
  Timer.periodic(Duration(seconds: 1), (timer) => print("$arg, isolate 1"));
}

void scheduleNotification(msg) async {
  // initialization
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // show a notification
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(0, 'plain title', msg, platformChannelSpecifics, payload: 'item x');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // below works
  // scheduleNotification("notification from UI isolate");

  // below works
  // FlutterIsolate.spawn(doSomeWork, "hello from another isolate");

  // below fails with: MissingPluginException(No implementation found for method initialize on channel dexterous.com/flutter/local_notifications)
  FlutterIsolate.spawn(scheduleNotification, "notification from other isolate");
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage());
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("flutter_isolate and flutter_local_notification"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text('Testing running from isolate')],
          ),
        ));
  }
}
