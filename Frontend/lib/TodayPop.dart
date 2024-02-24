import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tastebud/CuisineTile.dart';
import 'package:tastebud/QuestionFormat.dart';
import 'package:http/http.dart' as http;

List<Question> popUpQuestions = [
  Question(
    questionText: "Cuisine Preferences",
    answers: [],
    isMultipleChoice: true
  )
];

class TodayPop extends StatefulWidget {
  final Function(List<String>) onCuisineSelected; // Callback function declaration

  const TodayPop({super.key, required this.onCuisineSelected});

  @override
  _TodayPopState createState() => _TodayPopState();
}


class _TodayPopState extends State<TodayPop> {
  int currentQuestion = 0;
  double boxHeight = 200.0; // Initial height

  @override
  void initState() {
    super.initState();
    setCuisineAnswers();
  }



  _loadStoredEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('storedEmail');
  }

  Future<int> getUserID() async {
    String email = await _loadStoredEmail(); // Ensure this returns a non-null, valid email string.
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/userInfo/user_id/$email'));

    if (response.statusCode == 200) {
      // Directly parse the response body as an integer.
      return int.parse(response.body);
    } else {
      throw Exception('Failed to load user ID with status code ${response.statusCode}');
    }
  }



  Future<List<String>> fetchTopCuisines(int userId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/userInfo/top_cuisines/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      // Assuming the response body is a JSON array of strings
      return body.map((dynamic item) => item.toString()).toList();
    } else {
      throw Exception('Failed to load top cuisines');
    }
  }
  void setCuisineAnswers() async {
    try {
      int userID = await getUserID();
      List<String> cuisines = await fetchTopCuisines(userID);
      setState(() {
        popUpQuestions[0].answers = cuisines;
        boxHeight = getBoxHeight(cuisines.length);
        print("Cuisines");
        print(cuisines);
      });
    } catch (e) {
      print('Error fetching top cuisines: $e');
    }
  }


  void _handleAnswerSelection(bool isSelected, int answerIndex) {
    setState(() {
      if (popUpQuestions[currentQuestion].isMultipleChoice) {
        if (isSelected) {
          popUpQuestions[currentQuestion].selectedAnswers.add(answerIndex);
        } else {
          popUpQuestions[currentQuestion].selectedAnswers.remove(answerIndex);
        }
      } else {
        // For single-choice questions, only allow one selected answer
        popUpQuestions[currentQuestion].selectedAnswers.clear();
        if (isSelected) {
          popUpQuestions[currentQuestion].selectedAnswers.add(answerIndex);
        }
      }
    });
  }

  double getBoxHeight(int numberOfAnswers) {
    switch (numberOfAnswers) {
      case 2:
        return 200.0;
      case 3:
        return 263.0;
      case 4:
        return 325.0;
      default:
        return 200.0; // Default case if there are not 2, 3, or 4 answers
    }
  }

  void addTempVals() {
    List<String> answersList = []; // Initialize an empty list for the answer strings.

    for (int index in popUpQuestions[currentQuestion].selectedAnswers) {
      String answer = popUpQuestions[currentQuestion].answers[index];
      answersList.add(answer);
    }

    // Use the callback to pass the selected cuisines back.
    widget.onCuisineSelected(answersList);
  }



  void _prevQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
        // Update the height for the previous question's answers
        boxHeight = getBoxHeight(popUpQuestions[currentQuestion].answers.length);
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestion < popUpQuestions.length - 1) {
      setState(() {
        currentQuestion++;
        // Update the height for the next question's answers
        boxHeight = getBoxHeight(popUpQuestions[currentQuestion].answers.length);
      });
    } else {
        addTempVals();
      // Close the pop-up
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text(
            "What do you feel like today?",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA30000)),
          ),
        ),
        const Divider(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500), // Animation duration
            curve: Curves.easeInOut, // Animation curve
            key: ValueKey<int>(currentQuestion), // Unique key for the AnimatedContainer child
            height: boxHeight, // Height is set here, within the AnimatedContainer
            child: buildPopQuestion(popUpQuestions[currentQuestion]),
          ),
        ),
      ],
    );
  }

  Widget buildPopQuestion(Question question) {
    return AnimatedSize(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: question.answers.length,
              itemBuilder: (context, index) {
                bool isSelected = question.selectedAnswers.contains(index);
                return CuisineTile(
                  key: UniqueKey(), // Provide a UniqueKey to force rebuild on every state change.
                  cuisine: question.answers[index],
                  isSelected: isSelected,
                  onSelected: (bool selected, int i) {
                    _handleAnswerSelection(selected, index);
                    // After handling the selection, force the list to rebuild with new state.
                  },
                  answerIndex: index,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 15.0, right: 15.0, bottom: 15.0), // Reduced top padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
              children: <Widget>[
                // "Back" button - only show if not on the first question
                if (currentQuestion > 0)
                  TextButton(
                    onPressed: _prevQuestion,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFFA30000),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                TextButton(
                  onPressed: _nextQuestion,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    currentQuestion == popUpQuestions.length - 1 ? "Submit" : "Next",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFFA30000),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}