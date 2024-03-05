import 'package:flutter/material.dart';
import 'package:tastebud/LogInPage.dart';
import 'package:tastebud/NotificationService.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tastebud/MainPage.dart';
import 'package:tastebud/SettingsView.dart';
// The main entry point of the app.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  runApp(MyApp());
  NotificationService().scheduleNotification(id: 1, title: 'TasteBud', body: 'Hey its time to eat', dateTime: DateTime(2099, 1, 1, 7, 0, 0));
  NotificationService().scheduleNotification(id: 2, title: 'TasteBud', body: 'Hey its time to eat', dateTime: DateTime(2099, 1, 1, 12, 0, 0));
  NotificationService().scheduleNotification(id: 3, title: 'TasteBud', body: 'Hey its time to eat', dateTime: DateTime(2099, 1, 1, 19, 0, 0));
}

// MyApp is the top-level widget of your application.
class MyApp extends StatelessWidget {
  // This widget returns the MaterialApp, which provides Material Design visuals.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TasteBud',  // The title of the app, used for the task switcher.
      theme: ThemeData(
        primarySwatch: Colors.red,  // The primary color palette of the app.
      ),
      home: LogInPage(),  // The default route of the app.
    );
  }
}