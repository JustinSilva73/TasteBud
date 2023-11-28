import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tastebud/MainPage.dart';

//Question Class meant for a list in order to hold all quesitons and answers
class Question {
  final String questionText;
  final List<String> answers;
  int? selectedAnswer;

  Question({required this.questionText, required this.answers});

  bool get isAnswerSelected =>
      selectedAnswer != null; // Check if an answer is selected}
}
//ALL QUESTIONS ENTERED TO THIS LIST
List<Question> surveyQuestions = [
  Question(
    questionText: "What day do you typically go out to eat?",
    answers: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
  ),
  Question(
    questionText: "2 Answer Question?",
    answers: ["Yes", "No"],
  ),
  Question(
    questionText: "4 choice question?",
    answers: ["What", "Cuisine", "You", "Like"],
  ),
];

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  late PageController _controller;
  List<Question> questions = surveyQuestions; // Initialize immediately
  int _currentPage = 0;  // Initialize _currentPage

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: _currentPage,
      keepPage: true,
    );
    questions = surveyQuestions; // Initialize the questions list here
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double questionTopPadding = screenHeight * 0.1678;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.1),  // Darker color for the shadow at the edges
              Colors.white,                   // Middle color for the center of the container
              Colors.white,
              Colors.black.withOpacity(0.1),  // Darker color for the shadow at the edges
            ],
            stops: [
              0.0,  // Start of the gradient
              0.05, // Start transitioning to the next color quickly
              0.95, // Start transitioning back to darker color near the end
              1.0   // End of the gradient
            ],
          ),
        ),
        child: PageView.builder(
          controller: _controller,
          onPageChanged: (index) {
            if (index > _currentPage) {
              // Prevent swiping forward
              _controller.jumpToPage(_currentPage);
            } else {
              // Update the current page index when swiping back
              setState(() {
                _currentPage = index;
              });
            }
          },
          itemCount: questions.length,
          itemBuilder: (context, index) => buildQuestionPage(questions[index], index, MediaQuery.of(context).size.width, questionTopPadding),
        ),
      ),
    );
  }


  Widget buildQuestionPage(Question question, int questionIndex, double screenWidth, double questionTopPadding) {
    int crossAxisCount = question.answers.length <= 4 ? 1 : 2;
    double horizontalMargin = 32.0;
    double buttonSpacing = 12.0;
    double buttonWidth = (screenWidth - (2 * horizontalMargin) - ((crossAxisCount - 1) * buttonSpacing)) / crossAxisCount;
    double baseRatio = question.answers.length > 4 ? 3.0 : 4;
    double ratioDecreasePerAnswer = 0.001;
    double buttonHeightRatio = baseRatio - (question.answers.length - 2) * ratioDecreasePerAnswer;
    buttonHeightRatio = max(buttonHeightRatio, 2.0);
    double buttonHeight = buttonWidth / buttonHeightRatio;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: questionTopPadding), // Adjusted padding
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      question.questionText,
                      style: const TextStyle(
                        fontSize: 26,
                        fontFamily: 'Kadwa',
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10), // Margin above the text
                      height: 2,
                      color: Colors.black, // Border color
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: buttonSpacing,
                    mainAxisSpacing: buttonSpacing,
                    childAspectRatio: buttonWidth / buttonHeight,
                  ),
                  itemCount: question.answers.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => setState(() => question.selectedAnswer = index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: question.selectedAnswer == index ? Color(0xFF3D0000) : Color(0xFFA30000),
                          border: Border.all(
                            color: Color(0xFFA30000), // Red as the border color
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), // Adjust color opacity for shadow intensity
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(2, 2), // Changes position of shadow
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          question.answers[index],
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                  padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 40),
              child: Visibility(
                maintainSize: true, // Always maintain the size in the layout
                maintainAnimation: true,
                maintainState: true,
                visible: question.isAnswerSelected, // Control visibility based on answer selection
                child: GestureDetector(
                  onTap: question.isAnswerSelected ? () {
                    if (questionIndex < questions.length - 1) {
                      setState(() {
                        _currentPage += 1;
                      });
                      _controller.animateToPage(
                        _currentPage,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      print('All questions answered! Submitting...');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                            (Route<dynamic> route) => false, // Removes all previous routes
                      );
                    }
                  } : null, // Disable tap when the answer is not selected
                  child: Opacity(
                    opacity: question.isAnswerSelected ? 1.0 : 0.0, // Control the opacity
                    child: Text(
                      questionIndex < questions.length - 1 ? "Next" : "Submit",
                      style: TextStyle(
                        fontSize: 24,
                        color: question.isAnswerSelected ? Color(0xFFA30000) : Colors.transparent, // Use transparent color when inactive
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
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
}*/