import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tastebud/MainPage.dart';

//Question Class meant for a list in order to hold all quesitons and answers
class Question {
  final String questionText;
  final List<String> answers;
  final bool isMultipleChoice;
  List<int> selectedAnswers;

  Question({required this.questionText, required this.answers, this.isMultipleChoice = false, selectedAnswers})
      : selectedAnswers = selectedAnswers ?? [];

  bool get isAnswerSelected => selectedAnswers.isNotEmpty;
}

//ALL QUESTIONS ENTERED TO THIS LIST
List<Question> surveyQuestions = [
  Question(
    questionText: "What is your preferred price?",
    answers: ["\$", "\$\$", "\$\$\$", "\$\$\$\$"],
  ),
  Question(
    questionText: "What is your preferred distance?",
    answers: ["Near (<5mi)", "Somewhat Near (5-10mi)", "Far (>10mi)"],
  ),
  Question(
    questionText: "What are your favorite cuisines?",
    answers: ["American", "Italian", "Chinese", "Japanese", "Mexican", "Indian", "Mediterranean", "Thai"],
    isMultipleChoice: true,
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
            stops: const [
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
    double baseRatio = question.answers.length > 4 ? 2.4 : 4;
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
                      onTap: () => setState(() {
                        if (question.isMultipleChoice) {
                          if (question.selectedAnswers.contains(index)) {
                            question.selectedAnswers.remove(index);
                          } else {
                            question.selectedAnswers.add(index);
                          }
                        } else {
                          question.selectedAnswers = [index];
                        }
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color: question.selectedAnswers.contains(index) ? Color(0xFF3D0000) : Color(0xFFA30000),
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
                      // Iterate through each question to prepare data for endpoint calls
                      for (var question in questions) {
                        var answerTexts = question.selectedAnswers.map((index) => question.answers[index]).toList();

                        // Prepare data for an individual question
                        var questionData = {
                          'question': question.questionText,
                          'answers': answerTexts,
                        };

                        // Example: await sendQuestionDataToEndpoint(questionData);

                        // You can also print or handle the questionData as needed
                        print('Submitting question: ${question.questionText}');
                        print('Question Data: $questionData');
                      }

                      print('All questions submitted!');

                      // Navigate to the MainPage
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