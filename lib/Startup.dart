import 'package:flutter/material.dart';
import 'package:tastebud/LogInPage.dart';

// The main entry point of the app.
void main() => runApp(MyApp());

// MyApp is the top-level widget of your application.
class MyApp extends StatelessWidget {
  // This widget returns the MaterialApp, which provides Material Design visuals.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MainPage',  // The title of the app, used for the task switcher.
      theme: ThemeData(
        primarySwatch: Colors.red,  // The primary color palette of the app.
      ),
      home: LoginPage(),  // The default route of the app.
    );
  }
}