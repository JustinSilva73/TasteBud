import 'package:flutter/material.dart';
import 'LogInPage.dart';
import 'package:tastebud/NotificationService.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'SettingsCheckControl.dart';
import 'ProfileView.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  await SettingsCheckControl.checkAndSetDefaults(); // Check settings and set defaults if necessary
  NotificationService notificationService = NotificationService();
  bool notificationsEnabled = await notificationService.getNotificationsEnabled();
  if(notificationsEnabled) {
    NotificationService().scheduleNotification(id: 1,
        title: 'TasteBud',
        body: 'Hey its time to eat',
        dateTime: DateTime(2099, 1, 1, 7, 0, 0));
    NotificationService().scheduleNotification(id: 2,
        title: 'TasteBud',
        body: 'Hey its time to eat',
        dateTime: DateTime(2099, 1, 1, 12, 00, 0));
    NotificationService().scheduleNotification(id: 3,
        title: 'TasteBud',
        body: 'Hey its time to eat',
        dateTime: DateTime(2099, 1, 1, 17, 0, 0));
  }
  runApp(const MyApp());

}

// MyApp is the top-level widget of your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget returns the MaterialApp, which provides Material Design visuals.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TasteBud',  // The title of the app, used for the task switcher.
      theme: ThemeData(
        primaryColor: Color(0xFFA30000), // Directly use the hex color
      ),
      home: const LoginPage(),  // The default route of the app.
    );
  }
}