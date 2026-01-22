import 'dart:async';

import 'package:counter_app/cubit/counter_cubit.dart';
import 'package:counter_app/cubit/counter_state.dart';
import 'package:counter_app/database/database_helper.dart';
import 'package:counter_app/models/question_model.dart';
import 'package:counter_app/screens/QuizScreen.dart';
import 'package:counter_app/utils/app_constants.dart';
import 'package:counter_app/widgets/CustomAppbar.dart';
import 'package:counter_app/widgets/QuestionSection.dart';
import 'package:counter_app/widgets/ResultsTableWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PointsCounterScreen extends StatefulWidget {
  final List<Question>? initialQuestions;
  final String? categoryName;

  const PointsCounterScreen({
    super.key,
    this.initialQuestions,
    this.categoryName,
  });

  @override
  State<PointsCounterScreen> createState() => _PointsCounterScreenState();
}

class _PointsCounterScreenState extends State<PointsCounterScreen> {
  bool showWinner = false;
  bool _winnerEffectTriggered = false;

  int currentQuestionIndex = 0;
  String? selectedOption;

  // ✅ لا تستخدم late هنا
  List<Question> questions = [];
  bool _isLoadingQuestions = false;
  String? _questionsError;

  // Teams default
  List<Team> teams = [
    Team(name: "الفريق الأول", members: [TeamMember(name: "عضو 1")]),
    Team(name: "الفريق الثاني", members: [TeamMember(name: "عضو 2")]),
  ];

  // Timer
  Timer? _questionTimer;
  int timeRemaining = 30;
  bool isTimeExpired = false;
  bool showCorrectAnswerOnly = false;
  bool isTimerRunning = false;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();

    // إذا تم تمرير أسئلة جاهزة من صفحة أخرى
    if (widget.initialQuestions != null && widget.initialQuestions!.isNotEmpty) {
      questions = widget.initialQuestions!;
      _prepareTimerForCurrentQuestion();
    } else {
      _loadQuestionsFromDatabase();
    }
  }

  
  
Future<void> _loadQuestionsFromDatabase() async {
  setState(() {
    _isLoadingQuestions = true;
    _questionsError = null;
    questions = [];
    currentQuestionIndex = 0;
  });

  try {
    List<Question> fetched;

    // ✅ إذا عندك اسم قسم: حوّله لـ id ثم اجلب أسئلته
    if (widget.categoryName != null && widget.categoryName!.trim().isNotEmpty) {
      final catId = await _resolveCategoryIdByName(widget.categoryName!.trim());
      if (catId == null) {
        fetched = [];
      } else {
        fetched = await _dbHelper.getAllQuestionsList(categoryId: catId);
      }
    } else {
      fetched = await _dbHelper.getAllQuestionsList();
    }

    questions = fetched;

    if (!mounted) return;
    setState(() => _isLoadingQuestions = false);

    if (questions.isNotEmpty) {
      _prepareTimerForCurrentQuestion();
    }
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _questionsError = e.toString();
      _isLoadingQuestions = false;
      questions = [];
    });
  }
}
Future<int?> _resolveCategoryIdByName(String categoryName) async {
  final cats = await _dbHelper.getAllCategories();
  for (final c in cats) {
    final name = (c['name'] ?? '').toString().trim();
    if (name == categoryName.trim()) {
      return int.tryParse(c['id'].toString());
    }
  }
  return null;
}


  // ================== Timer helpers ==================
  int _totalContestSeconds() {
    int sum = 0;
    for (final q in questions) {
      sum += q.timeLimitSeconds;
    }
    return sum;
  }

  int _remainingContestSeconds() {
    if (questions.isEmpty) return 0;
    int sum = timeRemaining;
    for (int i = currentQuestionIndex + 1; i < questions.length; i++) {
      sum += questions[i].timeLimitSeconds;
    }
    return sum;
  }

  void _prepareTimerForCurrentQuestion() {
    if (questions.isEmpty) return;

    _questionTimer?.cancel();
    timeRemaining = questions[currentQuestionIndex].timeLimitSeconds;
    isTimeExpired = false;
    showCorrectAnswerOnly = false;
    isTimerRunning = false;

    if (mounted) setState(() {});
  }

  void _startOrResumeTimer() {
    if (questions.isEmpty) return;
    if (isTimeExpired) return;

    _questionTimer?.cancel();
    isTimerRunning = true;
    if (mounted) setState(() {});

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        timeRemaining--;
      });

      if (timeRemaining <= 0) {
        _handleTimeExpiration();
        timer.cancel();
      }
    });
  }

  void _pauseTimer() {
    _questionTimer?.cancel();
    isTimerRunning = false;
    if (mounted) setState(() {});
  }

  void _toggleStartPause() {
    if (isTimerRunning) {
      _pauseTimer();
    } else {
      _startOrResumeTimer();
    }
  }

  void _handleTimeExpiration() {
    setState(() {
      isTimeExpired = true;
      showCorrectAnswerOnly = true;
      isTimerRunning = false;
    });
  }

  void _restartTimer() => _resetTimer();

  void _resetTimer() {
    if (questions.isEmpty) return;

    _questionTimer?.cancel();
    setState(() {
      showCorrectAnswerOnly = false;
      isTimeExpired = false;
      timeRemaining = questions[currentQuestionIndex].timeLimitSeconds;
      isTimerRunning = false; // المستخدم يتحكم
    });
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    super.dispose();
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    // ✅ شاشة تحميل قبل أي شيء
    if (_isLoadingQuestions) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ إذا فشل التحميل (لكن fallback قد يكون موجود)
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('لا توجد أسئلة')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('لا توجد أسئلة متاحة حالياً'),
              if (_questionsError != null) ...[
                const SizedBox(height: 12),
                Text(
                  'تفاصيل الخطأ:\n$_questionsError',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadQuestionsFromDatabase,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ تأمين الفهرس
    if (currentQuestionIndex >= questions.length) {
      currentQuestionIndex = 0;
      _prepareTimerForCurrentQuestion();
    }

    return BlocConsumer<CounterCubit, CounterState>(
      listener: (context, state) {},
      builder: (context, state) {
        final counterCubit = context.read<CounterCubit>();

        final winner = counterCubit.getWinner();
        final winnerScore = counterCubit.getWinnerScore();
        final teamNames = counterCubit.getTeamNames();

        return Scaffold(
          appBar: CustomAppbar(initialDuration: const Duration(minutes: 2)),
          body: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ResultsTableWidget(
                      counterCubit: counterCubit,
                      teamNames: teamNames,
                      onResetTable: () => counterCubit.resetTable(),
                      getTotalScore: _getTeamTotalScore,
                      onShowWinner: () => setState(() => showWinner = true),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: QuestionSection(
                        onOptionSelected: (option) => setState(() => selectedOption = option),
                        onNextQuestion: _handleNextQuestion,
                        onPreviousQuestion: _handlePreviousQuestion,
                        currentQuestionIndex: currentQuestionIndex,
                        totalQuestions: questions.length,
                        currentQuestion: questions[currentQuestionIndex],
                        timeRemaining: timeRemaining,
                        showCorrectAnswerOnly: showCorrectAnswerOnly,
                        isTimeExpired: isTimeExpired,
                        onTimerTap: _restartTimer,
                        isTimerRunning: isTimerRunning,
                        onStartPause: _toggleStartPause,
                        onResetTimer: _restartTimer,
                        totalTimeTotalSeconds: _totalContestSeconds(),
                        totalTimeRemainingSeconds: _remainingContestSeconds(),
                      ),
                    ),
                  ),
                ],
              ),

              // ✅ Overlay الفائز بشكل صحيح داخل Stack
              if (showWinner) _buildWinnerOverlay(winner, winnerScore),
            ],
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'team_competition_fab',
                onPressed: _showTeamSetupDialog,
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.group),
                label: const Text('مسابقة الفرق'),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: 'individual_quiz_fab',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                ),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.quiz),
                label: const Text('اختبار فردي'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================== Navigation ==================
  void _handleNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
        showCorrectAnswerOnly = false;
        isTimeExpired = false;
      });
      _prepareTimerForCurrentQuestion();
    }
  }

  void _handlePreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        selectedOption = null;
        showCorrectAnswerOnly = false;
        isTimeExpired = false;
      });
      _prepareTimerForCurrentQuestion();
    }
  }

  // ================== Winner ==================
  void _playWinnerSound() {
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  Widget _buildWinnerOverlay(String winner, int winnerScore) {
    if (!_winnerEffectTriggered) {
      _winnerEffectTriggered = true;
      _playWinnerSound();
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() {
          showWinner = false;
          _winnerEffectTriggered = false;
        }),
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(AppConstants.largePadding),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.deepOrangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const WinnerCelebrationAnimation(),
                const SizedBox(height: 12),
                Text(
                  winner.isEmpty ? "لا توجد فرق" : "الفائز: $winner",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$winnerScore نقطة',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(() {
                    showWinner = false;
                    _winnerEffectTriggered = false;
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("إغلاق"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================== Team Setup ==================
  void _showTeamSetupDialog() {
    final teamNameController = TextEditingController();
    final tempTeams = List<Team>.from(teams);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('إعداد الفرق'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: teamNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الفريق الجديد',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        final teamName = teamNameController.text.trim();
                        if (teamName.isNotEmpty) {
                          setLocalState(() {
                            tempTeams.add(
                              Team(
                                name: teamName,
                                members: [TeamMember(name: "عضو 1")],
                              ),
                            );
                            teamNameController.clear();
                          });
                        }
                      },
                      child: const Text('إضافة فريق'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'الفرق المشاركة:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: tempTeams.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(tempTeams[index].name),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setLocalState(() {
                                    tempTeams.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: tempTeams.length >= 2
                      ? () {
                          Navigator.pop(context);
                          _startTeamCompetition(tempTeams);
                        }
                      : null,
                  child: const Text('ابدأ المسابقة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startTeamCompetition(List<Team> competitionTeams) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedQuizScreen(teams: competitionTeams),
      ),
    );
  }

  // ================== Score helper ==================
  int _getTeamTotalScore(int teamIndex) {
    final counterCubit = context.read<CounterCubit>();
    int totalScore = 0;

    for (final row in counterCubit.scoreTable) {
      if (row.length > teamIndex) {
        totalScore += row[teamIndex];
      }
    }

    return totalScore;
  }
}

/// ================== Winner animation ==================
class WinnerCelebrationAnimation extends StatefulWidget {
  const WinnerCelebrationAnimation({super.key});

  @override
  State<WinnerCelebrationAnimation> createState() => _WinnerCelebrationAnimationState();
}

class _WinnerCelebrationAnimationState extends State<WinnerCelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ConfettiPainter(progress: _controller.value),
                );
              },
            ),
          ),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              return Transform.scale(
                scale: _pulse.value,
                child: const Icon(
                  Icons.emoji_events,
                  size: 72,
                  color: Colors.yellow,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final centers = <Offset>[
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.30, size.height * 0.10),
      Offset(size.width * 0.55, size.height * 0.18),
      Offset(size.width * 0.75, size.height * 0.30),
      Offset(size.width * 0.85, size.height * 0.12),
      Offset(size.width * 0.40, size.height * 0.35),
      Offset(size.width * 0.65, size.height * 0.42),
    ];

    final colors = <Color>[
      Colors.white,
      Colors.yellowAccent,
      Colors.white70,
      Colors.amberAccent,
    ];

    for (int i = 0; i < centers.length; i++) {
      final c = centers[i];
      final dy = (progress - 0.5) * 40 * (i.isEven ? 1 : -1);
      final dx = (progress - 0.5) * 18 * (i % 3 == 0 ? 1 : -1);
      final p = Offset(c.dx + dx, c.dy + dy);

      paint.color = colors[i % colors.length].withValues(alpha: 0.85);
      canvas.drawCircle(p, 3.2 + (i % 3) * 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
