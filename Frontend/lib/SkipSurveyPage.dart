import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tastebud/MainPage.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class SkipSurveyPage extends StatefulWidget {
  const SkipSurveyPage({super.key});

  @override
  _SkipSurveyPageState createState() => _SkipSurveyPageState();
}

class _SkipSurveyPageState extends State<SkipSurveyPage> {
  StreamController<int> controller = StreamController<int>.broadcast();
  var selectedValue = 0;
  bool spinButtonVisible = true;

  @override
  void initState() {
    super.initState();
    items.shuffle();
    controller.stream.listen((value) {
      setState(() {
        selectedValue = value;
        spinButtonVisible = false; // Hide the spin button
      });
      // You need some logic to wait until the wheel stops, before showing the dialog
      Future.delayed(const Duration(seconds: 5), () {
        _showResultDialog();
      });
    });
  }

  void _showResultDialog() {
    // The dialog shows the result to the user
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            items[selectedValue],
            style: const TextStyle(
              fontSize: 24.0, // Set the font size as per your requirement
              fontWeight: FontWeight.bold, // Make the font weight bold
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  final items = <String>[
    'Mexican',
    'Japanese',
    'Thai',
    'American',
    'Indian',
    'Turkish',
    'Italian',
    'Chinese',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Spinner Wheel'),
        ),
        body: Column(
          children: [
            Expanded(
              child: FortuneWheel(
                selected: controller.stream,
                indicators: const <FortuneIndicator>[
                  FortuneIndicator(
                    alignment: Alignment.topCenter,
                    child: TriangleIndicator(
                      color: Color.fromARGB(255, 225, 6, 6),
                    ),
                  ),
                ],
                items: [
                  FortuneItem(
                    child: Text(items[0]),
                    style: const FortuneItemStyle(
                      color: Color.fromARGB(255, 148, 207, 255),
                      borderColor: Color.fromARGB(255, 76, 95, 201),
                      borderWidth: 3,
                    ),
                  ),
                  FortuneItem(
                    child: Text(items[1]),
                    style: const FortuneItemStyle(
                      color: Color.fromARGB(255, 255, 135, 201),
                      borderColor: Color.fromARGB(255, 255, 45, 192),
                      borderWidth: 3,
                    ),
                  ),
                  FortuneItem(
                    child: Text(items[2]),
                    style: const FortuneItemStyle(
                      color: Color.fromARGB(255, 32, 235, 144),
                      borderColor: Color.fromARGB(255, 99, 255, 104),
                      borderWidth: 3,
                    ),
                  ),
                  FortuneItem(
                    child: Text(items[3]),
                    style: const FortuneItemStyle(
                      color: Color.fromARGB(255, 228, 88, 88),
                      borderColor: Color.fromARGB(255, 227, 59, 59),
                      borderWidth: 3,
                    ),
                  ),
                  FortuneItem(
                    child: Text(items[4]),
                    style: const FortuneItemStyle(
                      color: Color.fromARGB(255, 57, 233, 221),
                      borderColor: Color.fromARGB(255, 99, 190, 243),
                      borderWidth: 3,
                    ),
                  ),
                  FortuneItem(
                    child: Text(items[5]),
                    style: const FortuneItemStyle(
                      color: Color.fromARGB(255, 190, 110, 243),
                      borderColor: Color.fromARGB(255, 59, 16, 159),
                      borderWidth: 3,
                    ),
                  ),
                  FortuneItem(
                    child: Text(items[6]),
                    style: const FortuneItemStyle(
                      color: Color.fromARGB(255, 255, 143, 82),
                      borderColor: Color.fromARGB(255, 217, 125, 44),
                      borderWidth: 3,
                    ),
                  ),
                  FortuneItem(
                    child: Text(items[7]),
                    style: const FortuneItemStyle(
                      color: Color.fromRGBO(255, 241, 88, 1),
                      borderColor: Color.fromARGB(255, 255, 188, 2),
                      borderWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
            if (spinButtonVisible)
              ElevatedButton(
                onPressed: () {
                  controller.add(Fortune.randomInt(0, items.length));
                },
                child: const Text('SPIN'),
              ),
          ],
        ),
    );
  }
}

