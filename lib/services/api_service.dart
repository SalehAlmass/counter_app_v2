import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:counter_app/models/question_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/counter_app_v2/api'; // Change to your server URL
  // static const String baseUrl = 'http://10.0.2.2/counter_app_v2/api'; 
  // Categories API
  static Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/get_categories.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }

  static Future<Map<String, dynamic>> createCategory(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories/create_category.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  static Future<Map<String, dynamic>> updateCategory(int id, String name) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/categories/update_category.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id, 'name': name}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/delete_category.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }

  // Questions API
static Future<List<Map<String, dynamic>>> getAllQuestions({int? categoryId}) async {
  try {
    String url = '$baseUrl/questions/get_questions.php';
    if (categoryId != null) {
      url += '?category_id=$categoryId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid questions response');
      }

      return List<Map<String, dynamic>>.from(decoded);
    } else {
      throw Exception('Failed to load questions: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error loading questions: $e');
  }
}

  static Future<List<Question>> getQuestionsForCategory(String categoryName) async {
    try {
      // Get all categories first to find the ID
      final categories = await getAllCategories();
      final category = categories.firstWhere(
        (cat) => cat['name'] == categoryName,
        orElse: () => {'id': null},
      );

      if (category['id'] == null) {
        return QuizData.getQuestionsByCategory(categoryName); // fallback to local data
      }

      final questionsData = await getAllQuestions(categoryId: category['id']);

      return questionsData.map((q) => _mapToQuestion(q)).toList();
    } catch (e) {
      // Fallback to local data if API fails
      return QuizData.getQuestionsByCategory(categoryName);
    }
  }

  static Future<List<Question>> getAllQuestionsList() async {
    try {
      final questionsData = await getAllQuestions();

      return questionsData.map((q) => _mapToQuestion(q)).toList();
    } catch (e) {
      // Fallback to local data if API fails
      return QuizData.getQuestions();
    }
  }

  // static Question _mapToQuestion(Map<String, dynamic> map) {
  //   return Question(
  //     id: map['id'],
  //     question: map['question'],
  //     options: [map['option1'], map['option2'], map['option3'], map['option4']],
  //     correctAnswerIndex: map['correct_answer_index'],
  //     explanation: map['explanation'] ?? '',
  //     difficulty: _intToDifficulty(map['difficulty'] ?? 1),
  //     timeLimitSeconds: map['time_limit_seconds'] ?? 30,
  //   );
  // }
  static Question _mapToQuestion(Map<String, dynamic> map) {
  return Question(
    id: int.parse(map['id'].toString()),
    question: map['question'],
    options: [
      map['option1'],
      map['option2'],
      map['option3'],
      map['option4'],
    ],
    correctAnswerIndex: int.parse(map['correct_answer_index'].toString()),
    explanation: map['explanation'] ?? '',
    difficulty: _intToDifficulty(
      int.parse(map['difficulty'].toString()),
    ),
    timeLimitSeconds: int.parse(map['time_limit_seconds'].toString()),
    categoryId: int.parse(map['category_id'].toString()),
  );
}

  static QuestionDifficulty _intToDifficulty(int value) {
    switch (value) {
      case 0:
        return QuestionDifficulty.easy;
      case 1:
        return QuestionDifficulty.medium;
      case 2:
        return QuestionDifficulty.hard;
      default:
        return QuestionDifficulty.medium;
    }
  }

  static Future<Map<String, dynamic>> createQuestion(Question question, int categoryId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/questions/create_question.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'question': question.question,
          'option1': question.options[0],
          'option2': question.options[1],
          'option3': question.options[2],
          'option4': question.options[3],
          'correct_answer_index': question.correctAnswerIndex,
          'explanation': question.explanation,
          'difficulty': _difficultyToInt(question.difficulty),
          'time_limit_seconds': question.timeLimitSeconds,
          'category_id': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create question: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating question: $e');
    }
  }

  static Future<Map<String, dynamic>> updateQuestion(int id, Question question, int categoryId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/questions/update_question.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'question': question.question,
          'option1': question.options[0],
          'option2': question.options[1],
          'option3': question.options[2],
          'option4': question.options[3],
          'correct_answer_index': question.correctAnswerIndex,
          'explanation': question.explanation,
          'difficulty': _difficultyToInt(question.difficulty),
          'time_limit_seconds': question.timeLimitSeconds,
          'category_id': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update question: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating question: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteQuestion(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/questions/delete_question.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete question: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting question: $e');
    }
  }

  static int _difficultyToInt(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return 0;
      case QuestionDifficulty.medium:
        return 1;
      case QuestionDifficulty.hard:
        return 2;
    }
  }
}