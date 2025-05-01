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
      if (selectedAnswer == widget.questions[_currentQuestionIndex]['correct_answer']) {
        _score++;
      }

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

  @override
  Widget build(BuildContext context) {
    final currentQuestion = !_isQuizFinished ? widget.questions[_currentQuestionIndex] : null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Quiz", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isQuizFinished
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Quiz Finished!", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    Text("Your Score: $_score / ${widget.questions.length}", style: GoogleFonts.poppins(fontSize: 20)),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Back to Home", style: GoogleFonts.poppins(color: Colors.white)),
                    )
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Question ${_currentQuestionIndex + 1} of ${widget.questions.length}",
                      style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[700])),
                  SizedBox(height: 20),
                  Text(currentQuestion!['question'],
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
                  SizedBox(height: 30),
                  ...currentQuestion['options'].map<Widget>((option) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () => _answerQuestion(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.indigo),
                          foregroundColor: Colors.indigo,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(option, style: GoogleFonts.poppins(fontSize: 16)),
                      ),
                    );
                  }).toList(),
                ],
              ),
      ),
    );
  }
}
