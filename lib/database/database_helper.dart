import 'package:counter_app/models/question_model.dart';
import 'package:counter_app/services/api_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // ========= Categories =========
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final cats = await ApiService.getAllCategories();
    // توحيد شكل البيانات
    return cats
        .map((c) => {
              'id': int.parse(c['id'].toString()),
              'name': c['name'].toString(),
            })
        .toList();
  }

  Future<int> insertCategory(String name) async {
    final res = await ApiService.createCategory(name);
    final id = res['id'];
    return id == null ? -1 : int.parse(id.toString());
  }

  Future<int> updateCategory(int id, String name) async {
    final res = await ApiService.updateCategory(id, name);
    final rid = res['id'];
    return rid == null ? -1 : int.parse(rid.toString());
  }

  Future<int> deleteCategory(int id) async {
    await ApiService.deleteCategory(id);
    return 1;
  }

  // ========= Questions (raw maps for admin list) =========
  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    return await ApiService.getAllQuestions();
  }

  Future<List<Map<String, dynamic>>> getQuestionsByCategory(int categoryId) async {
    return await ApiService.getAllQuestions(categoryId: categoryId);
  }

  Future<int> insertQuestion(Question q, int categoryId) async {
    final res = await ApiService.createQuestion(q, categoryId);
    final id = res['id'];
    return id == null ? -1 : int.parse(id.toString());
  }

  Future<int> updateQuestion(int id, Question q, int categoryId) async {
    final res = await ApiService.updateQuestion(id, q, categoryId);
    final rid = res['id'];
    return rid == null ? -1 : int.parse(rid.toString());
  }

  Future<int> deleteQuestion(int id) async {
    await ApiService.deleteQuestion(id);
    return 1;
  }

  // ========= Questions (as models for gameplay screens) =========
  Future<List<Question>> getAllQuestionsList({int? categoryId}) async {
    return await ApiService.getAllQuestionsList(categoryId: categoryId);
  }

  Future<List<Question>> getRandomQuestionsList({required int count, int? categoryId}) async {
    return await ApiService.getRandomQuestions(count: count, categoryId: categoryId);
  }

  /// يساعد في شاشة الإدارة (تحويل map لسؤال عند التعديل)
  Question mapToQuestion(Map<String, dynamic> map) {
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

  QuestionDifficulty _intToDifficulty(int v) {
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
}
