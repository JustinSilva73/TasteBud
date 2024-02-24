class Question {
  final String questionText;
  List<String> answers;
  final bool isMultipleChoice;
  List<int> selectedAnswers;
  Question({required this.questionText, required this.answers, this.isMultipleChoice = false, selectedAnswers})
      : selectedAnswers = selectedAnswers ?? [];

  bool get isAnswerSelected => selectedAnswers.isNotEmpty;
}