import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:counter_app/models/question_model.dart';

// Only import sqflite for non-web platforms
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    if (!kIsWeb) {
      // Mobile platform - use SQLite
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    } else {
      // For web platform, throw an error that will be handled gracefully
      throw UnsupportedError("Database operations are not supported on web platform");
    }
  }

  Future<sqflite.Database> _initDatabase() async {
    String dbPath = path.join(await sqflite.getDatabasesPath(), 'quiz_app.db');
    return await sqflite.openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        option1 TEXT NOT NULL,
        option2 TEXT NOT NULL,
        option3 TEXT NOT NULL,
        option4 TEXT NOT NULL,
        correct_answer_index INTEGER NOT NULL,
        explanation TEXT,
        difficulty INTEGER NOT NULL DEFAULT 1, -- 0: easy, 1: medium, 2: hard
        time_limit_seconds INTEGER NOT NULL DEFAULT 30,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Insert default categories
    await db.insert('categories', {'name': 'الرياضيات'});
    await db.insert('categories', {'name': 'الثقافة العامة'});
    await db.insert('categories', {'name': 'الدين الإسلامي'});
    await db.insert('categories', {'name': 'الألغاز'});
  }

  // Categories CRUD operations
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    if (kIsWeb) {
      // Return default categories for web
      return [
        {'id': 1, 'name': 'الرياضيات'},
        {'id': 2, 'name': 'الثقافة العامة'},
        {'id': 3, 'name': 'الدين الإسلامي'},
        {'id': 4, 'name': 'الألغاز'},
      ];
    }
    
    try {
      final db = await database;
      return await db.query('categories', orderBy: 'name');
    } catch (e) {
      // Fallback to default categories if database fails
      return [
        {'id': 1, 'name': 'الرياضيات'},
        {'id': 2, 'name': 'الثقافة العامة'},
        {'id': 3, 'name': 'الدين الإسلامي'},
        {'id': 4, 'name': 'الألغاز'},
      ];
    }
  }

  Future<int> insertCategory(String name) async {
    if (kIsWeb) {
      throw UnsupportedError("Insert operations are not supported on web platform");
    }
    
    final db = await database;
    return await db.insert('categories', {'name': name});
  }

  Future<int> updateCategory(int id, String name) async {
    if (kIsWeb) {
      throw UnsupportedError("Update operations are not supported on web platform");
    }
    
    final db = await database;
    return await db.update('categories', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    if (kIsWeb) {
      throw UnsupportedError("Delete operations are not supported on web platform");
    }
    
    final db = await database;
    // First delete all questions in this category
    await db.delete('questions', where: 'category_id = ?', whereArgs: [id]);
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Questions CRUD operations
  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    if (kIsWeb) {
      // Return sample questions for web
      return [];
    }
    
    try {
      final db = await database;
      return await db.query('questions', orderBy: 'category_id, id');
    } catch (e) {
      // Return empty list if database fails
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsByCategory(int categoryId) async {
    if (kIsWeb) {
      // Return sample questions for web
      return [];
    }
    
    try {
      final db = await database;
      return await db.query(
        'questions',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'id',
      );
    } catch (e) {
      // Return empty list if database fails
      return [];
    }
  }

  Future<int> insertQuestion(Question question, int categoryId) async {
    if (kIsWeb) {
      throw UnsupportedError("Insert operations are not supported on web platform");
    }
    
    final db = await database;
    return await db.insert('questions', {
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
    });
  }

  Future<int> updateQuestion(int id, Question question, int categoryId) async {
    if (kIsWeb) {
      throw UnsupportedError("Update operations are not supported on web platform");
    }
    
    final db = await database;
    return await db.update('questions', {
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
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteQuestion(int id) async {
    if (kIsWeb) {
      throw UnsupportedError("Delete operations are not supported on web platform");
    }
    
    final db = await database;
    return await db.delete('questions', where: 'id = ?', whereArgs: [id]);
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
  Question mapToQuestion(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      question: map['question'],
      options: [map['option1'], map['option2'], map['option3'], map['option4']],
      correctAnswerIndex: map['correct_answer_index'],
      explanation: map['explanation'] ?? '',
      difficulty: _intToDifficulty(map['difficulty']),
      timeLimitSeconds: map['time_limit_seconds'],
      categoryId: map['category_id'],
    );
  }

  // Get all questions for a specific category
  Future<List<Question>> getQuestionsForCategory(String categoryName) async {
    if (kIsWeb) {
      // Return sample questions for web based on category
      return QuizData.getQuestionsByCategory(categoryName);
    }
    
    try {
      final db = await database;
      final categoryResult = await db.query(
        'categories',
        where: 'name = ?',
        whereArgs: [categoryName],
      );

      if (categoryResult.isEmpty) return [];

      // Safely extract the category ID
      var categoryIdValue = categoryResult.first['id'];
      int categoryId = (categoryIdValue is int) ? categoryIdValue : 0;

      final questionMaps = await db.query(
        'questions',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'id',
      );

      return questionMaps.map((map) => mapToQuestion(map)).toList();
    } catch (e) {
      // Return default questions if database fails
      return QuizData.getQuestionsByCategory(categoryName);
    }
  }

  // Get all questions
  Future<List<Question>> getAllQuestionsList() async {
    if (kIsWeb) {
      return QuizData.getQuestions(); // Use default questions for web
    }
    
    try {
      final db = await database;
      final questionMaps = await db.query('questions', orderBy: 'category_id, id');
      return questionMaps.map((map) => mapToQuestion(map)).toList();
    } catch (e) {
      // Return default questions if database fails
      return QuizData.getQuestions();
    }
  }
}