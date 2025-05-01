import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class QuizGeneratorService {
  final String apiKey;

  QuizGeneratorService({required this.apiKey});

  Future<List<Map<String, dynamic>>> generateQuizFromPdf(File file) async {
    try {
      final extractedText = await _extractPdfText(file);

      if (extractedText.isEmpty) {
        throw Exception("PDF text extraction failed or was empty.");
      }

      final prompt = """
You are provided with content extracted from a study document.

Please:
- Generate 10 multiple choice questions (MCQs)
- Each question should have:
  - A question string
  - 4 answer options
  - 1 correct answer

Return ONLY valid JSON like:
[
  {
    "question": "What is Flutter?",
    "options": ["SDK", "IDE", "OS", "Compiler"],
    "correct_answer": "SDK"
  },
  ...
]

Study Material:
$extractedText
""";

      final response = await http.post(
        Uri.parse("https://models.github.ai/inference/chat/completions"),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "openai/gpt-4.1",
          "messages": [
            {"role": "system", "content": "You are a helpful quiz generator."},
            {"role": "user", "content": prompt}
          ],
          "max_tokens": 3000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final List<dynamic> quizList = jsonDecode(content);

        return quizList.map<Map<String, dynamic>>((q) => {
          "question": q["question"],
          "options": List<String>.from(q["options"]),
          "correct_answer": q["correct_answer"]
        }).toList();
      } else {
        throw Exception("GPT API error: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Quiz generation error: $e");
      rethrow;
    }
  }

  Future<String> _extractPdfText(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      String text = PdfTextExtractor(document).extractText();

      document.dispose();

      return text.length > 40000 ? text.substring(0, 40000) : text;
    } catch (e) {
      print("PDF extraction error: $e");
      return '';
    }
  }
}
