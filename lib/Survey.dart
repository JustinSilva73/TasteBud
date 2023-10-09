import 'package:flutter/material.dart';
import 'package:tastebud/MainPage.dart';

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  int? answer1;
  int? answer2;
  int? answer3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Survey'),
      ),
      body: Scrollbar(
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Question 1
            Text("How many days a week do you like to go out"),
            RadioListTile(
              value: 1,
              groupValue: answer1,
              onChanged: (int? value) {
                setState(() {
                  answer1 = value;
                });
              },
              title: Text("1"),
            ),
            RadioListTile(
              value: 2,
              groupValue: answer1,
              onChanged: (int? value) {
                setState(() {
                  answer1 = value;
                });
              },
              title: Text("2-3"),
            ),
            RadioListTile(
              value: 3,
              groupValue: answer1,
              onChanged: (int? value) {
                setState(() {
                  answer1 = value;
                });
              },
              title: Text("4-5"),
            ),
            RadioListTile(
              value: 4,
              groupValue: answer1,
              onChanged: (int? value) {
                setState(() {
                  answer1 = value;
                });
              },
              title: Text("6-7"),
            ),

            // Question 2
            Text("Average Cost of a night out"),
            RadioListTile(
              value: 1,
              groupValue: answer2,
              onChanged: (int? value) {
                setState(() {
                  answer2 = value;
                });
              },
              title: Text("\$"),
            ),
            RadioListTile(
              value: 2,
              groupValue: answer2,
              onChanged: (int? value) {
                setState(() {
                  answer2 = value;
                });
              },
              title: Text("\$-\$\$"),
            ),
            RadioListTile(
              value: 3,
              groupValue: answer2,
              onChanged: (int? value) {
                setState(() {
                  answer2 = value;
                });
              },
              title: Text("Bird"),
            ),
            RadioListTile(
              value: 4,
              groupValue: answer2,
              onChanged: (int? value) {
                setState(() {
                  answer2 = value;
                });
              },
              title: Text("Fish"),
            ),

            // Question 3
            Text("Question 3: Your favorite season?"),
            RadioListTile(
              value: 1,
              groupValue: answer3,
              onChanged: (int? value) {
                setState(() {
                  answer3 = value;
                });
              },
              title: Text("Summer"),
            ),
            RadioListTile(
              value: 2,
              groupValue: answer3,
              onChanged: (int? value) {
                setState(() {
                  answer3 = value;
                });
              },
              title: Text("Winter"),
            ),
            RadioListTile(
              value: 3,
              groupValue: answer3,
              onChanged: (int? value) {
                setState(() {
                  answer3 = value;
                });
              },
              title: Text("Spring"),
            ),
            RadioListTile(
              value: 4,
              groupValue: answer3,
              onChanged: (int? value) {
                setState(() {
                  answer3 = value;
                });
              },
              title: Text("Autumn"),
            ),

            SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (answer1 != null && answer2 != null && answer3 != null) {
                  // Handle submission here
                  print('All questions answered! Submitting...');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()), // Assumes you have a CreateAccountPage widget
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please answer all questions!')),
                  );
                }
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
