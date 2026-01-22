import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:counter_app/models/question_model.dart';

class ApiService {
  // ✅ baseUrl ديناميكي حسب المنصة
  static String get baseUrl {
    // على الويب: localhost غالبًا صحيح
    if (kIsWeb) return 'http://localhost/counter_app_v2/api';

    // على Android Emulator: 10.0.2.2
    // على iOS Simulator: localhost
    // بما أننا لا نملك Platform.isAndroid هنا (بدون dart:io)، نخليها قابلة للتغيير بسهولة
    // الأفضل: اجعلها ثابتة حسب جهازك:
    return 'http://10.0.2.2/counter_app_v2/api';
  }

  // ===========================
  // Categories
  // ===========================
  static Future<List<Map<String, dynamic>>> getAllCategories() async {
    final uri = Uri.parse('$baseUrl/categories/get_categories.php');
    final res = await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (res.statusCode != 200) {
      throw Exception('Failed to load categories: ${res.statusCode}');
    }

    final decoded = json.decode(res.body);
    if (decoded is! List) throw Exception('Invalid categories response');

    return List<Map<String, dynamic>>.from(decoded);
  }

  static Future<Map<String, dynamic>> createCategory(String name) async {
    final uri = Uri.parse('$baseUrl/categories/create_category.php');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to create category: ${res.statusCode}');
    }
    return Map<String, dynamic>.from(json.decode(res.body));
  }

  static Future<Map<String, dynamic>> updateCategory(int id, String name) async {
    final uri = Uri.parse('$baseUrl/categories/update_category.php');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'name': name}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update category: ${res.statusCode}');
    }
    return Map<String, dynamic>.from(json.decode(res.body));
  }

  static Future<Map<String, dynamic>> deleteCategory(int id) async {
    final uri = Uri.parse('$baseUrl/categories/delete_category.php');
    final res = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to delete category: ${res.statusCode}');
    }
    return Map<String, dynamic>.from(json.decode(res.body));
  }

  // ===========================
  // Questions
  // ===========================
  static Future<List<Map<String, dynamic>>> getAllQuestions({int? categoryId}) async {
    var url = '$baseUrl/questions/get_questions.php';
    if (categoryId != null) url += '?category_id=$categoryId';

    final uri = Uri.parse(url);
    final res = await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (res.statusCode != 200) {
      throw Exception('Failed to load questions: ${res.statusCode}');
    }

    final decoded = json.decode(res.body);
    if (decoded is! List) throw Exception('Invalid questions response');

    return List<Map<String, dynamic>>.from(decoded);
  }

  static Future<List<Question>> getAllQuestionsList({int? categoryId}) async {
    final data = await getAllQuestions(categoryId: categoryId);
    return data.map(_mapToQuestion).toList();
  }

  static Future<List<Question>> getRandomQuestions({
    required int count,
    int? categoryId,
  }) async {
    final params = <String, String>{
      'random': 'true',
      'count': count.toString(),
    };
    if (categoryId != null) params['category_id'] = categoryId.toString();

    final uri = Uri.parse('$baseUrl/questions/get_questions.php').replace(queryParameters: params);
    final res = await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (res.statusCode != 200) {
      throw Exception('Failed to load random questions: ${res.statusCode}');
    }

    final decoded = json.decode(res.body);
    if (decoded is! List) throw Exception('Invalid random questions response');

    final list = List<Map<String, dynamic>>.from(decoded);
    return list.map(_mapToQuestion).toList();
  }

  static Future<Map<String, dynamic>> createQuestion(Question q, int categoryId) async {
    final uri = Uri.parse('$baseUrl/questions/create_question.php');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'question': q.question,
        'option1': q.options[0],
        'option2': q.options[1],
        'option3': q.options[2],
        'option4': q.options[3],
        'correct_answer_index': q.correctAnswerIndex,
        'explanation': q.explanation,
        'difficulty': _difficultyToInt(q.difficulty),
        'time_limit_seconds': q.timeLimitSeconds,
        'category_id': categoryId,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to create question: ${res.statusCode}');
    }
    return Map<String, dynamic>.from(json.decode(res.body));
  }

  static Future<Map<String, dynamic>> updateQuestion(int id, Question q, int categoryId) async {
    final uri = Uri.parse('$baseUrl/questions/update_question.php');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': id,
        'question': q.question,
        'option1': q.options[0],
        'option2': q.options[1],
        'option3': q.options[2],
        'option4': q.options[3],
        'correct_answer_index': q.correctAnswerIndex,
        'explanation': q.explanation,
        'difficulty': _difficultyToInt(q.difficulty),
        'time_limit_seconds': q.timeLimitSeconds,
        'category_id': categoryId,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update question: ${res.statusCode}');
    }
    return Map<String, dynamic>.from(json.decode(res.body));
  }

  static Future<Map<String, dynamic>> deleteQuestion(int id) async {
    final uri = Uri.parse('$baseUrl/questions/delete_question.php');
    final res = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to delete question: ${res.statusCode}');
    }
    return Map<String, dynamic>.from(json.decode(res.body));
  }

  // ===========================
  // Helpers
  // ===========================
  static Question _mapToQuestion(Map<String, dynamic> map) {
    return Question(
      id: int.parse(map['id'].toString()),
      question: (map['question'] ?? '').toString(),
      options: [
        (map['option1'] ?? '').toString(),
        (map['option2'] ?? '').toString(),
        (map['option3'] ?? '').toString(),
        (map['option4'] ?? '').toString(),
      ],
      correctAnswerIndex: int.parse(map['correct_answer_index'].toString()),
      explanation: (map['explanation'] ?? '').toString(),
      difficulty: _intToDifficulty(int.tryParse(map['difficulty'].toString()) ?? 1),
      timeLimitSeconds: int.tryParse(map['time_limit_seconds'].toString()) ?? 30,
      categoryId: map['category_id'] == null ? null : int.tryParse(map['category_id'].toString()),
      category: (map['category'] ?? 'General').toString(),
      type: QuestionType.multipleChoice,
      answeredAt: null,
      isCorrect: null,
    );
  }

  static QuestionDifficulty _intToDifficulty(int v) {
    switch (v) {
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

  static int _difficultyToInt(QuestionDifficulty d) {
    switch (d) {
      case QuestionDifficulty.easy:
        return 0;
      case QuestionDifficulty.medium:
        return 1;
      case QuestionDifficulty.hard:
        return 2;
    }
  }
}
