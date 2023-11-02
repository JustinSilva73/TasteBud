import 'package:flutter/material.dart';
import 'package:tastebud/MainPage.dart';
import 'package:tastebud/SkipSurveyPage.dart';

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  int? answer1;
  int? answer2;
  int? answer3;
  int? answer4;
  int? answer5;
  int? answer6;
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
            Text("What day do you typically go out to eat?"),
            RadioListTile(
              value: 1,
              groupValue: answer1,
              onChanged: (int? value) {
                setState(() {
                  answer1 = value;
                });
              },
              title: Text("Monday"),
            ),
            RadioListTile(
              value: 2,
              groupValue: answer1,
              onChanged: (int? value) {
                setState(() {
                  answer1 = value;
                });
              },
              title: Text("Tuesday"),
            ),
            RadioListTile(
              value: 3,
              groupValue: answer1,
              onChanged: (int? value) {
                setState(() {
                  answer1 = value;
                });
              },
              title: Text("Wednesday"),
            ),
            RadioListTile(
              value: 4,
              groupValue: answer1,
              onChanged: (int? value) {
                setState(() {
                  answer1 = value;
                });
              },
              title: Text("Thursday"),
            ),
            RadioListTile(
              value: 5,
              groupValue: answer1,
              onChanged: (int? value) {
                setState(() {
                  answer1 = value;
                });
              },
              title: Text("Friday"),
            ),
            RadioListTile(
              value: 6,
              groupValue: answer1,
              onChanged: (int? value) {
                setState(() {
                  answer1 = value;
                });
              },
              title: Text("Saturday"),
            ),
            RadioListTile(
              value: 7,
              groupValue: answer1,
              onChanged: (int? value) {
                setState(() {
                  answer1 = value;
                });
              },
              title: Text("Sunday"),
            ),


            // Question 2
            Text("What time do you usually go out to eat?"),
            RadioListTile(
              value: 1,
              groupValue: answer2,
              onChanged: (int? value) {
                setState(() {
                  answer2 = value;
                });
              },
              title: Text("Early afternoon (12:00 PM - 3:00 PM)"),
            ),
            RadioListTile(
              value: 2,
              groupValue: answer2,
              onChanged: (int? value) {
                setState(() {
                  answer2 = value;
                });
              },
              title: Text("Late afternoon (3:00 PM - 6:00 PM)"),
            ),
            RadioListTile(
              value: 3,
              groupValue: answer2,
              onChanged: (int? value) {
                setState(() {
                  answer2 = value;
                });
              },
              title: Text("Early evening (6:00 PM - 8:00 PM)"),
            ),
            RadioListTile(
              value: 4,
              groupValue: answer2,
              onChanged: (int? value) {
                setState(() {
                  answer2 = value;
                });
              },
              title: Text("Late evening (8:00 PM - 10:00 PM)"),
            ),

            // Question 3
            Text("What type of cuisine do you prefer for dinner when dining out?"),
            RadioListTile(
              value: 1,
              groupValue: answer3,
              onChanged: (int? value) {
                setState(() {
                  answer3 = value;
                });
              },
              title: Text("Italian"),
            ),
            RadioListTile(
              value: 2,
              groupValue: answer3,
              onChanged: (int? value) {
                setState(() {
                  answer3 = value;
                });
              },
              title: Text("Mexican"),
            ),
            RadioListTile(
              value: 3,
              groupValue: answer3,
              onChanged: (int? value) {
                setState(() {
                  answer3 = value;
                });
              },
              title: Text("Asian"),
            ),
            RadioListTile(
              value: 4,
              groupValue: answer3,
              onChanged: (int? value) {
                setState(() {
                  answer3 = value;
                });
              },
              title: Text("American"),
            ),

            // Question 4
            Text("How far within range do you prefer restaurants when choosing where to dine?"),
            RadioListTile(
              value: 1,
              groupValue: answer4,
              onChanged: (int? value) {
                setState(() {
                  answer4 = value;
                });
              },
              title: Text("Within walking distance"),
            ),
            RadioListTile(
              value: 2,
              groupValue: answer4,
              onChanged: (int? value) {
                setState(() {
                  answer4 = value;
                });
              },
              title: Text("Within a 5-minute drive"),
            ),
            RadioListTile(
              value: 3,
              groupValue: answer4,
              onChanged: (int? value) {
                setState(() {
                  answer4 = value;
                });
              },
              title: Text("Within a 15-minute drive"),
            ),
            RadioListTile(
              value: 4,
              groupValue: answer4,
              onChanged: (int? value) {
                setState(() {
                  answer4 = value;
                });
              },
              title: Text("Any distance is acceptable"),
            ),
            // Question 5
            Text("What is your preferred price range when dining out?"),
            RadioListTile(
              value: 1,
              groupValue: answer5,
              onChanged: (int? value) {
                setState(() {
                  answer5 = value;
                });
              },
              title: Text("Budget-friendly"),
            ),
            RadioListTile(
              value: 2,
              groupValue: answer5,
              onChanged: (int? value) {
                setState(() {
                  answer5 = value;
                });
              },
              title: Text("Moderately priced"),
            ),
            RadioListTile(
              value: 3,
              groupValue: answer5,
              onChanged: (int? value) {
                setState(() {
                  answer5 = value;
                });
              },
              title: Text("Fine dining"),
            ),
            RadioListTile(
              value: 4,
              groupValue: answer5,
              onChanged: (int? value) {
                setState(() {
                  answer5 = value;
                });
              },
              title: Text("No specific budget"),
            ),

            // Question 6
            Text(" What features are most important to you in a food app for recommendations?"),
            RadioListTile(
              value: 1,
              groupValue: answer6,
              onChanged: (int? value) {
                setState(() {
                  answer6 = value;
                });
              },
              title: Text(" User reviews and ratings"),
            ),
            RadioListTile(
              value: 2,
              groupValue: answer6,
              onChanged: (int? value) {
                setState(() {
                  answer6 = value;
                });
              },
              title: Text("Restaurant menu and prices"),
            ),
            RadioListTile(
              value: 3,
              groupValue: answer6,
              onChanged: (int? value) {
                setState(() {
                  answer6 = value;
                });
              },
              title: Text("Location-based suggestions"),
            ),
            RadioListTile(
              value: 4,
              groupValue: answer6,
              onChanged: (int? value) {
                setState(() {
                  answer6 = value;
                });
              },
              title: Text("Special dietary options (e.g., vegetarian, vegan)"),
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
            ElevatedButton(
              onPressed: () {
                   Navigator.pushReplacement(
                     context,
                     MaterialPageRoute(builder: (context) => SkipSurveyPage()), // Assumes you have a CreateAccountPage widget
                   );
                 },
              child: Text("Skip survey"),
            ),
          ],
        ),
      ),
    );
  }
}