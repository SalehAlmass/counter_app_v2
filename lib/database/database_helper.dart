// Only import sqflite for non-web platforms
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:counter_app/models/question_model.dart';
import '../services/api_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  
  // Flag to determine if we should use API instead of local database
  static bool useApi = true; // Always use MySQL API

  // Categories CRUD operations
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      return await ApiService.getAllCategories();
    } catch (e) {
      // Fallback to default categories if API fails
      return [
        {'id': 1, 'name': 'الرياضيات'},
        {'id': 2, 'name': 'الثقافة العامة'},
        {'id': 3, 'name': 'الدين الإسلامي'},
        {'id': 4, 'name': 'الألغاز'},
      ];
    }
  }

  Future<int> insertCategory(String name) async {
    try {
      final result = await ApiService.createCategory(name);
      return result['id'] ?? -1; // Return the ID from API or -1 if not available
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<int> updateCategory(int id, String name) async {
    try {
      final result = await ApiService.updateCategory(id, name);
      return result['id'] ?? -1; // Return the ID from API or -1 if not available
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<int> deleteCategory(int id) async {
    try {
      await ApiService.deleteCategory(id);
      return 1; // Indicate successful deletion
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  // Questions CRUD operations
  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    try {
      return await ApiService.getAllQuestions();
      
    } catch (e) {
      // Fallback to empty list if API fails
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsByCategory(int categoryId) async {
    try {
      print('Getting questions for category ID: $categoryId');
      return await ApiService.getAllQuestions(categoryId: categoryId);
    } catch (e) {
      print('Error getting questions for category ID $categoryId: $e');
      // Fallback to empty list if API fails
      return [];
    }
  }

 Future<int> insertQuestion(Question question, int categoryId) async {
  try {
    final result = await ApiService.createQuestion(question, categoryId);

    final idValue = result['id'];

    if (idValue == null) {
      return -1;
    }

    return int.parse(idValue.toString());
  } catch (e) {
    throw Exception('API Error: $e');
  }
}


  Future<int> updateQuestion(int id, Question question, int categoryId) async {
    try {
      final result = await ApiService.updateQuestion(id, question, categoryId);
      return result['id'] ?? -1; // Return the ID from API or -1 if not available
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<int> deleteQuestion(int id) async {
    try {
      await ApiService.deleteQuestion(id);
      return 1; // Indicate successful deletion
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  int _difficultyToInt(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return 0;
      case QuestionDifficulty.medium:
        return 1;
      case QuestionDifficulty.hard:
        return 2;
    }
  }

  QuestionDifficulty _intToDifficulty(int value) {
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

  // Convert database map to Question object
  // Question mapToQuestion(Map<String, dynamic> map) {
  //   return Question(
  //     id: map['id'],
  //     question: map['question'],
  //     options: [map['option1'], map['option2'], map['option3'], map['option4']],
  //     correctAnswerIndex: map['correct_answer_index'],
  //     explanation: map['explanation'] ?? '',
  //     difficulty: _intToDifficulty(map['difficulty']),
  //     timeLimitSeconds: map['time_limit_seconds'],
  //     categoryId: map['category_id'],
  //   );
  // }
  Question mapToQuestion(Map<String, dynamic> map) {
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


  // Get all questions for a specific category
  Future<List<Question>> getQuestionsForCategory(String categoryName) async {
    try {
      return await ApiService.getQuestionsForCategory(categoryName);
    } catch (e) {
      // Return default questions if API fails
      return QuizData.getQuestionsByCategory(categoryName);
    }
  }

  // Get all questions
  Future<List<Question>> getAllQuestionsList() async {
    try {
      return await ApiService.getAllQuestionsList();
    } catch (e) {
      // Return default questions if API fails
      return QuizData.getQuestions();
    }
  }
}