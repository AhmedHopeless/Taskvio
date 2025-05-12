import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const QuizScreen({Key? key, required this.questions}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isQuizFinished = false;

  void _answerQuestion(String selectedAnswer) {
    if (!_isQuizFinished) {
      if (selectedAnswer ==
          widget.questions[_currentQuestionIndex]['correct_answer']) {
        _score++;
      }

      widget.questions[_currentQuestionIndex]['user_answer'] = selectedAnswer;

      if (_currentQuestionIndex < widget.questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        setState(() {
          _isQuizFinished = true;
        });
      }
    }
  }

  void _viewMistakes() {
    final mistakes = widget.questions
        .asMap()
        .entries
        .where((entry) =>
            entry.value['correct_answer'] != entry.value['user_answer'])
        .map((entry) => {
              'question': entry.value['question'],
              'user_answer': entry.value['user_answer'],
              'correct_answer': entry.value['correct_answer'],
            })
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Mistakes',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: mistakes.map((mistake) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '- ${mistake['question']}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Your Answer: ${mistake['user_answer']}',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                    Text(
                      'Correct Answer: ${mistake['correct_answer']}',
                      style: GoogleFonts.poppins(color: Colors.green),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Quiz', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isQuizFinished)
              Text(
                'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            if (!_isQuizFinished) const SizedBox(height: 16),
            if (!_isQuizFinished)
              Text(
                widget.questions[_currentQuestionIndex]['question'],
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            if (!_isQuizFinished) const SizedBox(height: 16),
            if (!_isQuizFinished)
              ...widget.questions[_currentQuestionIndex]['options']
                  .map<Widget>((answer) => Container(
                        margin: const EdgeInsets.only(
                            bottom: 12), // Adjust as needed
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo,
                          ),
                          onPressed: () => _answerQuestion(answer),
                          child: Text(
                            answer,
                            style: GoogleFonts.poppins(
                              color: Colors.indigo,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            if (_isQuizFinished)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Quiz Finished!',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Score: $_score/${widget.questions.length}',
                      style: GoogleFonts.poppins(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    if (_score < widget.questions.length)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _viewMistakes();
                        },
                        child:
                            Text('View Mistakes', style: GoogleFonts.poppins()),
                      ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
