import 'package:counter_app/models/question_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Import database helper conditionally
import 'package:counter_app/database/database_helper.dart';
import 'package:counter_app/models/question_model.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة الإدارة'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'الأقسام'),
              Tab(text: 'الأسئلة'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [CategoryManagementScreen(), QuestionManagementScreen()],
        ),
      ),
    );
  }
}

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      categories = await _dbHelper.getAllCategories();
      setState(() {});
    } catch (e) {
      // Handle web platform error gracefully
      if (kIsWeb) {
        categories = [
          {'id': 1, 'name': 'الرياضيات'},
          {'id': 2, 'name': 'الثقافة العامة'},
          {'id': 3, 'name': 'الدين الإسلامي'},
          {'id': 4, 'name': 'الألغاز'},
        ];
        setState(() {});
      } else {
        // Show error for mobile platform
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _addCategory() async {
    try {
      String? categoryName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('إضافة قسم جديد'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'اسم القسم'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      );

      if (categoryName != null && categoryName.isNotEmpty) {
        await _dbHelper.insertCategory(categoryName);
        _loadCategories();
      }
    } catch (e) {
      // Handle web platform error
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('التعديلات غير مدعومة على الويب')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _editCategory(int id, String currentName) async {
    try {
      String? newName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          final controller = TextEditingController(text: currentName);
          return AlertDialog(
            title: const Text('تعديل القسم'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'اسم القسم'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('تحديث'),
              ),
            ],
          );
        },
      );

      if (newName != null && newName.isNotEmpty) {
        await _dbHelper.updateCategory(id, newName);
        _loadCategories();
      }
    } catch (e) {
      // Handle web platform error
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('التعديلات غير مدعومة على الويب')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _deleteCategory(int id, String name) async {
    try {
      bool confirm =
          await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('تأكيد الحذف'),
                content: Text(
                  'هل أنت متأكد من حذف القسم "$name"؟ سيتم حذف جميع الأسئلة المرتبطة به.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('حذف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (confirm) {
        await _dbHelper.deleteCategory(id);
        _loadCategories();
      }
    } catch (e) {
      // Handle web platform error
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الحذف غير مدعوم على الويب')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: categories.isEmpty
          ? const Center(child: Text('لا توجد أقسام'))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(category['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _editCategory(category['id'], category['name']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteCategory(category['id'], category['name']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class QuestionManagementScreen extends StatefulWidget {
  const QuestionManagementScreen({super.key});

  @override
  State<QuestionManagementScreen> createState() =>
      _QuestionManagementScreenState();
}

class _QuestionManagementScreenState extends State<QuestionManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      questions = await _dbHelper.getAllQuestions();
      categories = await _dbHelper.getAllCategories();

      setState(() {});
    } catch (e) {
      // Handle web platform error
      if (kIsWeb) {
        questions = [];
        categories = [
          {'id': 1, 'name': 'الرياضيات'},
          {'id': 2, 'name': 'الثقافة العامة'},
          {'id': 3, 'name': 'الدين الإسلامي'},
          {'id': 4, 'name': 'الألغاز'},
        ];

        setState(() {});
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _loadQuestionsByCategory(int? categoryId) async {
    try {
      if (categoryId == null) {
        final allQuestions = await _dbHelper.getAllQuestionsList();
        questions = allQuestions.map((q) => q.toJson()).toList();
      } else {
        final categoryQuestions = await _dbHelper.getQuestionsForCategory(
          categories.firstWhere((cat) => cat['id'] == categoryId)['name'],
        );
        questions = categoryQuestions.map((q) => q.toJson()).toList();
      }
      setState(() {});
    } catch (e) {
      // Handle web platform error
      if (kIsWeb) {
        questions = [];
        setState(() {});
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _addQuestion() async {
    try {
      final question = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionFormScreen(
            categories: categories,
            onSave: (question, categoryId) async {
              try {
                await _dbHelper.insertQuestion(question, categoryId);
                if (selectedCategoryId != null) {
                  await _loadQuestionsByCategory(selectedCategoryId);
                } else {
                  await _loadData();
                }
              } catch (e) {
                // Handle web platform error
                if (kIsWeb) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('الإضافة غير مدعومة على الويب'),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: ${e.toString()}')),
                    );
                  }
                }
              }
            },
          ),
        ),
      );
    } catch (e) {
      // Handle web platform error
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الإضافة غير مدعومة على الويب')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _editQuestion(Map<String, dynamic> question) async {
    try {
      final updatedQuestion = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionFormScreen(
            categories: categories,
            existingQuestion: _dbHelper.mapToQuestion(question),
            existingCategoryId: question['category_id'],
            onSave: (updatedQ, categoryId) async {
              try {
                await _dbHelper.updateQuestion(
                  updatedQ.id!,
                  updatedQ,
                  categoryId,
                );
                if (selectedCategoryId != null) {
                  await _loadQuestionsByCategory(selectedCategoryId);
                } else {
                  await _loadData();
                }
              } catch (e) {
                // Handle web platform error
                if (kIsWeb) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('التحديث غير مدعوم على الويب'),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: ${e.toString()}')),
                    );
                  }
                }
              }
            },
          ),
        ),
      );
    } catch (e) {
      // Handle web platform error
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('التعديل غير مدعوم على الويب')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _deleteQuestion(int id, String questionText) async {
    try {
      bool confirm =
          await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('تأكيد الحذف'),
                content: Text('هل أنت متأكد من حذف السؤال "$questionText"؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('حذف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (confirm) {
        await _dbHelper.deleteQuestion(id);
        if (selectedCategoryId != null) {
          await _loadQuestionsByCategory(selectedCategoryId);
        } else {
          await _loadData();
        }
      }
    } catch (e) {
      // Handle web platform error
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الحذف غير مدعوم على الويب')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<int>(
            value: selectedCategoryId,
            decoration: const InputDecoration(
              labelText: 'اختر القسم',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('جميع الأقسام')),
              ...categories.map(
                (category) => DropdownMenuItem<int>(
                  value: category['id'] as int? ?? 0,
                  child: Text(category['name']),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedCategoryId = value;
              });
              _loadQuestionsByCategory(value);
            },
          ),
        ),
        Expanded(
          child: questions.isEmpty
              ? const Center(child: Text('لا توجد أسئلة'))
              : ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        title: Text(question['question']),
                        subtitle: Text(
                          'القسم: ${_getCategoryName(question['category_id'] as int?)}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الخيارات:'),
                                ...List.generate(4, (i) {
                                  bool isCorrect =
                                      question['correct_answer_index'] !=
                                          null &&
                                      i ==
                                          (question['correct_answer_index']
                                              as int);
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCorrect
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.grey,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${['أ', 'ب', 'ج', 'د'][i]}) ${question['option${i + 1}'] ?? 'N/A'}',
                                            style: TextStyle(
                                              color: isCorrect
                                                  ? Colors.green
                                                  : Colors.black,
                                              fontWeight: isCorrect
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 8),
                                Text(
                                  'الصعوبة: ${_getDifficultyText(question['difficulty'] ?? 1)}',
                                ),
                                Text(
                                  'الوقت: ${question['time_limit_seconds'] ?? 30} ثانية',
                                ),
                                if ((question['explanation'] as String?)
                                        ?.isNotEmpty ==
                                    true)
                                  Text('الشرح: ${question['explanation']}'),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _editQuestion(question),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteQuestion(
                                        question['id'],
                                        question['question'],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add),
            label: const Text('إضافة سؤال'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _getCategoryName(int? categoryId) {
    print('categoryId: $categoryId');
    print('categories: $categories');

    if (categoryId == null) return 'غير محدد';

    final category = categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'name': 'غير محدد'},
    );

    return category['name']?.toString() ?? 'غير محدد';
  }

  // String _getCategoryName(int categoryId) {
  //   final category = categories.firstWhere(
  //     (cat) => cat['id'] == categoryId,
  //     orElse: () => {'name': 'غير محدد'},
  //   );
  //   return category['name'];
  // }

  String _getDifficultyText(dynamic difficultyValue) {
    int difficultyInt = 1; // Default to medium

    if (difficultyValue is int) {
      difficultyInt = difficultyValue;
    } else if (difficultyValue is String) {
      difficultyInt = int.tryParse(difficultyValue) ?? 1;
    } else if (difficultyValue == null) {
      difficultyInt = 1; // Default to medium if null
    }

    switch (difficultyInt) {
      case 0:
        return 'سهل';
      case 1:
        return 'متوسط';
      case 2:
        return 'صعب';
      default:
        return 'متوسط';
    }
  }
}

class QuestionFormScreen extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final Question? existingQuestion;
  final int? existingCategoryId;
  final Function(Question question, int categoryId) onSave;

  const QuestionFormScreen({
    super.key,
    required this.categories,
    this.existingQuestion,
    this.existingCategoryId,
    required this.onSave,
  });

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _explanationController = TextEditingController();
  int _selectedCategory = 0;
  int _correctAnswerIndex = 0;
  int _difficulty = 1; // Default to medium
  int _timeLimit = 30;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuestion != null) {
      _questionController.text = widget.existingQuestion!.question;
      _option1Controller.text = widget.existingQuestion!.options[0];
      _option2Controller.text = widget.existingQuestion!.options[1];
      _option3Controller.text = widget.existingQuestion!.options[2];
      _option4Controller.text = widget.existingQuestion!.options[3];
      _explanationController.text = widget.existingQuestion!.explanation;
      _correctAnswerIndex = widget.existingQuestion!.correctAnswerIndex;
      _difficulty = widget.existingQuestion!.difficulty.index;
      _timeLimit = widget.existingQuestion!.timeLimitSeconds;
      _selectedCategory =
          widget.existingCategoryId ??
          (widget.categories.isNotEmpty
              ? (widget.categories[0]['id'] as int? ?? 0)
              : 0);
    } else if (widget.existingCategoryId != null) {
      _selectedCategory = widget.existingCategoryId!;
    } else {
      // Set default category if available
      _selectedCategory = widget.categories.isNotEmpty
          ? (widget.categories[0]['id'] as int? ?? 0)
          : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingQuestion != null ? 'تعديل السؤال' : 'إضافة سؤال',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Selection
              DropdownButtonFormField<int>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'القسم',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories
                    .map(
                      (category) => DropdownMenuItem<int>(
                        value: category['id'] as int? ?? 0,
                        child: Text(category['name']),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Question Text
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'نص السؤال',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال نص السؤال';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Options
              TextFormField(
                controller: _option1Controller,
                decoration: InputDecoration(
                  labelText: 'الخيار الأول (أ)',
                  border: const OutlineInputBorder(),
                  suffixIcon: Radio<int>(
                    value: 0,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) =>
                        setState(() => _correctAnswerIndex = value ?? 0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الخيار الأول';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _option2Controller,
                decoration: InputDecoration(
                  labelText: 'الخيار الثاني (ب)',
                  border: const OutlineInputBorder(),
                  suffixIcon: Radio<int>(
                    value: 1,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) =>
                        setState(() => _correctAnswerIndex = value ?? 0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الخيار الثاني';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _option3Controller,
                decoration: InputDecoration(
                  labelText: 'الخيار الثالث (ج)',
                  border: const OutlineInputBorder(),
                  suffixIcon: Radio<int>(
                    value: 2,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) =>
                        setState(() => _correctAnswerIndex = value ?? 0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الخيار الثالث';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _option4Controller,
                decoration: InputDecoration(
                  labelText: 'الخيار الرابع (د)',
                  border: const OutlineInputBorder(),
                  suffixIcon: Radio<int>(
                    value: 3,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) =>
                        setState(() => _correctAnswerIndex = value ?? 0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الخيار الرابع';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Explanation
              TextFormField(
                controller: _explanationController,
                decoration: const InputDecoration(
                  labelText: 'الشرح (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Difficulty
              const Text('مستوى الصعوبة:'),
              Wrap(
                children: [
                  FilterChip(
                    label: const Text('سهل'),
                    selected: _difficulty == 0,
                    onSelected: (selected) =>
                        setState(() => _difficulty = selected ? 0 : 1),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('متوسط'),
                    selected: _difficulty == 1,
                    onSelected: (selected) =>
                        setState(() => _difficulty = selected ? 1 : 1),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('صعب'),
                    selected: _difficulty == 2,
                    onSelected: (selected) =>
                        setState(() => _difficulty = selected ? 2 : 1),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time Limit
              const Text('الوقت المحدد للإجابة (بالثواني):'),
              Slider(
                value: _timeLimit.toDouble(),
                min: 10,
                max: 120,
                divisions: 11,
                label: '${_timeLimit.toInt()} ثانية',
                onChanged: (value) =>
                    setState(() => _timeLimit = value.toInt()),
              ),
              Text('$_timeLimit ثانية', textAlign: TextAlign.center),
              const SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Question question = Question(
                      id:
                          widget.existingQuestion?.id ??
                          0, // Provide a default value
                      question: _questionController.text,
                      options: [
                        _option1Controller.text,
                        _option2Controller.text,
                        _option3Controller.text,
                        _option4Controller.text,
                      ],
                      correctAnswerIndex: _correctAnswerIndex,
                      explanation: _explanationController.text,
                      difficulty: QuestionDifficulty.values[_difficulty],
                      timeLimitSeconds: _timeLimit,
                    );
                    widget.onSave(question, _selectedCategory);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  widget.existingQuestion != null
                      ? 'تحديث السؤال'
                      : 'حفظ السؤال',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
