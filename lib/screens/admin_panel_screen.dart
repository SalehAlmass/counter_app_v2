import 'package:counter_app/models/question_model.dart';
import 'package:counter_app/services/api_service.dart';
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
    final loadedCategories = await _dbHelper.getAllCategories();

    // تأكد أن كل id رقم (int) وليس String
    categories = loadedCategories.map((cat) {
      return {
        'id': int.parse(cat['id'].toString()),
        'name': cat['name'].toString(),
      };
    }).toList();

    setState(() {}); // تحديث واجهة المستخدم فورًا
  } catch (e) {
    if (kIsWeb) {
      categories = [
        {'id': 1, 'name': 'الرياضيات'},
        {'id': 2, 'name': 'الثقافة العامة'},
        {'id': 3, 'name': 'الدين الإسلامي'},
        {'id': 4, 'name': 'الألغاز'},
      ];
      setState(() {});
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
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

        // أعد تحميل الأقسام مباشرة بعد الإضافة
        await _loadCategories();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _addCategory,
            icon: const Icon(Icons.add),
            label: const Text('إضافة قسم'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  child: ListTile(
                    title: Text(category['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editCategory(
                            int.parse(category['id'].toString()),
                            category['name'],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(
                            int.parse(category['id'].toString()),
                            category['name'],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
  Map<int, String> categoryMap = {};
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadCategories();
  }

  Future<void> _loadQuestions() async {
    try {
      List<Map<String, dynamic>> allQuestions;
      if (selectedCategoryId != null) {
        allQuestions = await _dbHelper.getQuestionsByCategory(
          selectedCategoryId!,
        );
      } else {
        allQuestions = await _dbHelper.getAllQuestions();
      }

      questions = allQuestions;
      setState(() {});
    } catch (e) {
      // Handle web platform error gracefully
      if (kIsWeb) {
        questions = [];
        setState(() {});
      } else {
        // Show error for mobile platform
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في تحميل الأسئلة: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      categories = await _dbHelper.getAllCategories();
      categoryMap = {
        for (var category in categories)
          int.parse(category['id'].toString()): category['name'],
      };

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
        categoryMap = {
          for (var category in categories) category['id']: category['name'],
        };
        setState(() {});
      } else {
        // Show error for mobile platform
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في تحميل الأقسام: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _addQuestion() async {
    // Navigate to question form screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionFormScreen(
          categories: categories,
          onSave: (question, categoryId) async {
            await _dbHelper.insertQuestion(question, categoryId);
            _loadQuestions();
          },
        ),
      ),
    );
  }

  Future<void> _editQuestion(Map<String, dynamic> question) async {
    // Find the category for this question
    final questionCategoryId = int.parse(question['category_id'].toString());

    final category = categories.firstWhere(
      (cat) => int.parse(cat['id'].toString()) == questionCategoryId,
      orElse: () => {'id': 1, 'name': 'Default'},
    );

    // Navigate to question form screen with existing data
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionFormScreen(
          categories: categories,
          initialQuestion: _dbHelper.mapToQuestion(question),
          initialCategoryId: int.parse(question['category_id'].toString()),

          onSave: (updatedQuestion, updatedCategoryId) async {
            await _dbHelper.updateQuestion(
              updatedQuestion.id!,
              updatedQuestion,
              updatedCategoryId,
            );
            _loadQuestions();
          },
        ),
      ),
    );
  }

  Future<void> _deleteQuestion(int id, String questionText) async {
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      try {
        await _dbHelper.deleteQuestion(id);
        _loadQuestions();
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
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
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int?>(
                  value: selectedCategoryId,
                  hint: const Text('جميع الأقسام'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('جميع الأقسام'),
                    ),
                    ...categories.map(
                      (category) => DropdownMenuItem<int?>(
                        value: int.parse(category['id'].toString()),
                        child: Text(category['name']),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                    _loadQuestions();
                  },
                ),

                //  DropdownButtonFormField<int>(
                //   value: selectedCategoryId,
                //   hint: const Text('جميع الأقسام'),
                //   items: [
                //     DropdownMenuItem(
                //       value: null,
                //       child: const Text('جميع الأقسام'),
                //     ),
                //     ...categories.map(
                //       (category) => DropdownMenuItem(
                //         value: category['id'],
                //         child: Text(category['name']),
                //       ),
                //     ),
                //   ],
                //   onChanged: (value) {
                //     setState(() {
                //       selectedCategoryId = value;
                //     });
                //     _loadQuestions();
                //   },
                // ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadQuestions();
                await _loadCategories();
              },
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final categoryId = int.parse(
                    question['category_id'].toString(),
                  );
                  final categoryName = categoryMap[categoryId] ?? 'غير محدد';

                  return Card(
                    child: ExpansionTile(
                      title: Text(
                        question['question'] ?? 'سؤال غير محدد',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('القسم: $categoryName'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الخيارات:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              ...List.generate(4, (i) {
                                String option =
                                    question['option${i + 1}'] ?? '';
                                // bool isCorrect =
                                //     i ==
                                //     (question['correct_answer_index'] ?? 0);
                                final correctIndex = int.parse(
                                  question['correct_answer_index'].toString(),
                                );
                                bool isCorrect = i == correctIndex;
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? Colors.lightGreen.shade100
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    '${String.fromCharCode(65 + i)}) $option ${isCorrect ? '(الإجابة الصحيحة)' : ''}',
                                    style: TextStyle(
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              }),
                              if (question['explanation'] != null &&
                                  question['explanation'].isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      'الشرح:',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    Text(
                                      question['explanation'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _editQuestion(question),
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    label: const Text('تعديل'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _deleteQuestion(
                                      int.parse(question['id'].toString()),
                                      question['question'],
                                    ),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text('حذف'),
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
          ),
        ],
      ),
    );
  }
}

class QuestionFormScreen extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final Question? initialQuestion;
  final int? initialCategoryId;
  final Function(Question question, int categoryId) onSave;

  const QuestionFormScreen({
    super.key,
    required this.categories,
    required this.onSave,
    this.initialQuestion,
    this.initialCategoryId,
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
  final _timeLimitController = TextEditingController();

  String? _selectedCategory;
  int? _selectedCorrectOption;
  QuestionDifficulty _selectedDifficulty = QuestionDifficulty.medium;

  @override
  void initState() {
    super.initState();

    // Pre-populate form if editing existing question
    if (widget.initialQuestion != null) {
      final question = widget.initialQuestion!;
      _questionController.text = question.question;
      _option1Controller.text = question.options[0];
      _option2Controller.text = question.options[1];
      _option3Controller.text = question.options[2];
      _option4Controller.text = question.options[3];
      _explanationController.text = question.explanation;
      _timeLimitController.text = question.timeLimitSeconds.toString();
      _selectedCorrectOption = question.correctAnswerIndex;
      _selectedDifficulty = question.difficulty;
      _selectedCategory = widget.initialCategoryId.toString();
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _explanationController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialQuestion != null ? 'تعديل السؤال' : 'إضافة سؤال',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Question field
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'السؤال',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال السؤال';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'القسم',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category['id'].toString(),
                    child: Text(category['name']),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء اختيار القسم';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Options
              TextFormField(
                controller: _option1Controller,
                decoration: const InputDecoration(
                  labelText: 'الخيار الأول (A)',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'الخيار الثاني (B)',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'الخيار الثالث (C)',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'الخيار الرابع (D)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الخيار الرابع';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Correct answer selection
              const Text(
                'الإجابة الصحيحة:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...List.generate(4, (index) {
                return RadioListTile<int>(
                  title: Text('الخيار ${String.fromCharCode(65 + index)}'),
                  value: index,
                  groupValue: _selectedCorrectOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedCorrectOption = value;
                    });
                  },
                );
              }),
              const SizedBox(height: 16),

              // Difficulty level
              const Text(
                'مستوى الصعوبة:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...QuestionDifficulty.values.map((difficulty) {
                return RadioListTile<QuestionDifficulty>(
                  title: Text(_getDifficultyText(difficulty)),
                  value: difficulty,
                  groupValue: _selectedDifficulty,
                  onChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value!;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 16),

              // Time limit
              TextFormField(
                controller: _timeLimitController,
                decoration: const InputDecoration(
                  labelText: 'الوقت المخصص للإجابة (بالثواني)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الوقت';
                  }
                  final time = int.tryParse(value);
                  if (time == null || time <= 0) {
                    return 'الرجاء إدخال رقم صحيح';
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
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _selectedCorrectOption != null) {
                    final question = Question(
                      id:
                          widget.initialQuestion?.id ??
                          -1, // Use existing ID if editing, -1 for new
                      question: _questionController.text,
                      options: [
                        _option1Controller.text,
                        _option2Controller.text,
                        _option3Controller.text,
                        _option4Controller.text,
                      ],
                      correctAnswerIndex: _selectedCorrectOption!,
                      explanation: _explanationController.text,
                      difficulty: _selectedDifficulty,
                      timeLimitSeconds:
                          int.tryParse(_timeLimitController.text) ?? 30,
                    );

                    // Save the question
                    await widget.onSave(
                      question,
                      int.parse(_selectedCategory!),
                    );

                    // Pop back to the previous screen
                    Navigator.pop(context);
                  } else if (_selectedCorrectOption == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الرجاء اختيار الإجابة الصحيحة'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.initialQuestion != null
                      ? 'تحديث السؤال'
                      : 'إضافة السؤال',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDifficultyText(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return 'سهل';
      case QuestionDifficulty.medium:
        return 'متوسط';
      case QuestionDifficulty.hard:
        return 'صعب';
    }
  }
}
