import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tastebud/MainPage.dart';
import 'package:http/http.dart' as http;

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
  const SurveyPage({super.key});

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  late PageController _controller;
  List<Question> questions = surveyQuestions; // Initialize immediately
  int _currentPage = 0;  // Initialize _currentPage
  String? storedEmail;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: _currentPage,
      keepPage: true,
    );
    questions = surveyQuestions; // Initialize the questions list here
  }

  Future<String?> _loadStoredEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('storedEmail');
    setState(() {
      storedEmail = email;
    });
    return email;
  }


  Future<void> submitAllAnswers() async {
    // Here we'll store the answers in the format that the backend expects.
    List<String> priceAnswers = [];
    List<String> distanceAnswers = [];
    List<String> cuisineAnswers = [];

    // This is just an example. You would need to map your answers to these categories based on the actual questions.
    for (var question in questions) {
      var answerTexts = question.selectedAnswers.map((index) => question.answers[index]).toList();
      switch (question.questionText) {
        case "What is your preferred price?":
          priceAnswers = answerTexts;
          break;
        case "What is your preferred distance?":
          distanceAnswers = answerTexts;
          break;
        case "What are your favorite cuisines?":
          cuisineAnswers = answerTexts;
          break;
        default:
          break;
      }
    }
    String? userEmail = await _loadStoredEmail(); // Make sure to await the result
    if (userEmail == null) {
      // Handle the case where userEmail is null
      print('No stored email found');
      return;
    } // Implement this method based on where you store the email

    // Now submit the data
    bool success = await submitSurveyData(
      email: userEmail,
      prices: priceAnswers,
      distances: distanceAnswers,
      cuisines: cuisineAnswers,
    );

    if (success) {
      // Navigate to the MainPage or handle success
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
            (Route<dynamic> route) => false,
      );
    } else {
      // Handle failure
      print('Failed to submit survey data');
    }
  }
  Map<String, dynamic> mapAnswersToColumnNames(List<String> selectedPrices, List<String> selectedDistances, List<String> selectedCuisines) {
    Map<String, dynamic> mappedData = {
      'price': [],
      'distance': [],
      'cuisine': []
    };

    // Define the base weights for each type of question
    const int selectedScore = 25;
    const int unselectedScore = -25;

    // Define all possible options
    const List<String> allPrices = ['\$', '\$\$', '\$\$\$', '\$\$\$\$'];
    const List<String> allDistances = ['Near (<5mi)', 'Somewhat Near (5-10mi)', 'Far (>10mi)'];
    const List<String> allCuisines = ['American', 'Italian', 'Chinese', 'Japanese', 'Mexican', 'Indian', 'Mediterranean', 'Thai'];

    // Mapping weights
    const Map<String, String> priceWeights = {
      '\$': 'one_weight',
      '\$\$': 'two_weight',
      '\$\$\$': 'three_weight',
      '\$\$\$\$': 'four_weight',
    };
    const Map<String, String> distanceWeights = {
      'Near (<5mi)': 'near_weight',
      'Somewhat Near (5-10mi)': 'middle_weight',
      'Far (>10mi)': 'far_weight',
    };
    const Map<String, String> cuisineWeights = {
      'American': 'american_weight',
      'Italian': 'italian_weight',
      'Chinese': 'chinese_weight',
      'Japanese': 'japanese_weight',
      'Mexican': 'mexican_weight',
      'Indian': 'indian_weight',
      'Mediterranean': 'mediterranean_weight',
      'Thai': 'thai_weight',
      // Add other cuisine mappings here
    };

    // Assign weights to each price option
    for (var price in allPrices) {
      mappedData['price'].add({priceWeights[price] ?? '': selectedPrices.contains(price) ? selectedScore : unselectedScore});
    }

    // Assign weights to each distance option
    for (var distance in allDistances) {
      mappedData['distance'].add({distanceWeights[distance] ?? '': selectedDistances.contains(distance) ? selectedScore : unselectedScore});
    }

    // Assign weights to each cuisine option
    for (var cuisine in allCuisines) {
      mappedData['cuisine'].add({cuisineWeights[cuisine] ?? '': selectedCuisines.contains(cuisine) ? selectedScore : unselectedScore});
    }

    return mappedData;
  }



  Future<bool> submitSurveyData({
    required String email,
    required List<String> prices,
    required List<String> distances,
    required List<String> cuisines,
  }) async {
    final mappedData = mapAnswersToColumnNames(prices, distances, cuisines);

    // Add email to the mapped data
    mappedData['email'] = email;
    print(mappedData); // Should show keys and values for email, price, distance, and cuisine

    final uri = Uri.parse('http://10.0.2.2:3000/survey/survey');
    final body = json.encode(mappedData);

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Survey data submitted successfully');
        return true;
      } else {
        print('Failed to submit survey data: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting survey data: $e');
      return false;
    }
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
                      margin: const EdgeInsets.only(top: 10), // Margin above the text
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
                          color: question.selectedAnswers.contains(index) ? const Color(0xFF3D0000) : const Color(0xFFA30000),
                          border: Border.all(
                            color: const Color(0xFFA30000), // Red as the border color
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), // Adjust color opacity for shadow intensity
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(2, 2), // Changes position of shadow
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
                  physics: const NeverScrollableScrollPhysics(),
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
                  // Replace the onTap method for the 'Submit' button
                  onTap: question.isAnswerSelected ? () async {
                    if (questionIndex < questions.length - 1) {
                      setState(() {
                        _currentPage += 1;
                      });
                      _controller.animateToPage(
                        _currentPage,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      // Call the function to submit all answers
                      await submitAllAnswers();
                    }
                  } : null,
                  child: Opacity(
                    opacity: question.isAnswerSelected ? 1.0 : 0.0, // Control the opacity
                    child: Text(
                      questionIndex < questions.length - 1 ? "Next" : "Submit",
                      style: TextStyle(
                        fontSize: 24,
                        color: question.isAnswerSelected ? const Color(0xFFA30000) : Colors.transparent, // Use transparent color when inactive
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