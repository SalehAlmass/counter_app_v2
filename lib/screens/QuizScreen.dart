import 'dart:async';
import 'package:flutter/material.dart';

import 'package:counter_app/models/question_model.dart';
import 'package:counter_app/database/database_helper.dart';

// ================================
// QuizScreen (Individual)
// ================================
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final DatabaseHelper _db = DatabaseHelper();

  List<Question> questions = [];
  bool _isLoading = true;
  String? _error;

  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  bool showFeedback = false;
  bool isAnswerCorrect = false;

  int score = 0;
  bool quizCompleted = false;

  static const int _individualQuizCount = 30;
  static const int _pointsPerCorrect = 10;

  int _totalQuizSeconds() {
    int sum = 0;
    for (final q in questions) {
      sum += q.timeLimitSeconds;
    }
    return sum;
  }

  int _remainingQuizSeconds() {
    if (questions.isEmpty) return 0;
    int sum = 0;
    for (int i = currentQuestionIndex; i < questions.length; i++) {
      sum += questions[i].timeLimitSeconds;
    }
    return sum;
  }

  String _fmt(int secs) {
    if (secs < 0) secs = 0;
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
      questions = [];
      currentQuestionIndex = 0;
      selectedOptionIndex = null;
      showFeedback = false;
      isAnswerCorrect = false;
      score = 0;
      quizCompleted = false;
    });

    try {
      final fetched = await _db.getRandomQuestionsList(count: _individualQuizCount);
      if (!mounted) return;

      setState(() {
        questions = fetched;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('اختبار فردي'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('لا توجد أسئلة متاحة حالياً'),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadQuestions, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }

    if (quizCompleted) {
      return _buildCompletionScreen();
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار فردي (أسئلة منوعة)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${currentQuestionIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'النقاط:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  Text(
                    '$score',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الوقت المتوقع:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الكلي: ${_fmt(_totalQuizSeconds())}'),
                      Text('المتبقي: ${_fmt(_remainingQuizSeconds())}'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                currentQuestion.question,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  return _buildOption(
                    option: currentQuestion.options[index],
                    optionIndex: index,
                    isSelected: selectedOptionIndex == index,
                    showFeedback: showFeedback,
                    isCorrect: currentQuestion.correctAnswerIndex == index,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            if (showFeedback) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isAnswerCorrect ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isAnswerCorrect ? Colors.green : Colors.red),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isAnswerCorrect ? Icons.check_circle : Icons.cancel,
                          color: isAnswerCorrect ? Colors.green : Colors.red,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isAnswerCorrect ? 'إجابة صحيحة! 👍' : 'إجابة خاطئة ❌',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isAnswerCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentQuestion.explanation,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    currentQuestionIndex < questions.length - 1 ? 'السؤال التالي' : 'إنهاء الاختبار',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String option,
    required int optionIndex,
    required bool isSelected,
    required bool showFeedback,
    required bool isCorrect,
  }) {
    Color backgroundColor;
    Color borderColor;
    IconData? icon;

    if (!showFeedback) {
      backgroundColor = isSelected ? Colors.blue[100]! : Colors.grey[50]!;
      borderColor = isSelected ? Colors.blue : Colors.grey[300]!;
    } else {
      if (isCorrect) {
        backgroundColor = Colors.green[100]!;
        borderColor = Colors.green;
        icon = Icons.check;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red[100]!;
        borderColor = Colors.red;
        icon = Icons.close;
      } else {
        backgroundColor = Colors.grey[50]!;
        borderColor = Colors.grey[300]!;
      }
    }

    return GestureDetector(
      onTap: showFeedback ? null : () => _selectOption(optionIndex),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, color: borderColor, size: 24)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: isSelected ? Icon(Icons.circle, color: borderColor, size: 16) : null,
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: showFeedback && (isCorrect || (isSelected && !isCorrect))
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: showFeedback && (isCorrect || (isSelected && !isCorrect)) ? borderColor : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectOption(int optionIndex) {
    setState(() {
      selectedOptionIndex = optionIndex;
      showFeedback = true;

      final currentQuestion = questions[currentQuestionIndex];
      isAnswerCorrect = currentQuestion.isCorrectAnswer(optionIndex);

      if (isAnswerCorrect) {
        score += _pointsPerCorrect;
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOptionIndex = null;
        showFeedback = false;
        isAnswerCorrect = false;
      });
    } else {
      setState(() => quizCompleted = true);
    }
  }

  Widget _buildCompletionScreen() {
    final maxScore = questions.length * _pointsPerCorrect;
    final percentage = maxScore == 0 ? 0.0 : (score / maxScore) * 100;
    final grade = _getGrade(percentage);
    final gradeColor = _getGradeColor(grade);

    final correct = (score ~/ _pointsPerCorrect);
    final incorrect = questions.length - correct;

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة الاختبار'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 100, color: gradeColor),
            const SizedBox(height: 30),
            Text(grade, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: gradeColor)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text('النتيجة النهائية',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  const SizedBox(height: 20),
                  Text('$score / $maxScore',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 10),
                  Text('${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('الأسئلة', '${questions.length}'),
                      _buildStatCard('الصحيحة', '$correct'),
                      _buildStatCard('الخاطئة', '$incorrect'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loadQuestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('إعادة الاختبار',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    child: const Text('العودة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }

  String _getGrade(double percentage) {
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 80) return 'جيد جداً';
    if (percentage >= 70) return 'جيد';
    if (percentage >= 60) return 'مقبول';
    return 'ضعيف';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'ممتاز':
        return Colors.green;
      case 'جيد جداً':
        return Colors.lightGreen;
      case 'جيد':
        return Colors.orange;
      case 'مقبول':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }
}

// ================================
// EnhancedQuizScreen (Teams)
// ================================
class EnhancedQuizScreen extends StatefulWidget {
  final List<Team> teams;

  const EnhancedQuizScreen({super.key, required this.teams});

  @override
  State<EnhancedQuizScreen> createState() => _EnhancedQuizScreenState();
}

class _EnhancedQuizScreenState extends State<EnhancedQuizScreen> with TickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();

  List<Question> questions = [];
  bool _isLoading = true;
  String? _error;

  int currentQuestionIndex = 0;

  Map<String, int?> teamAnswers = {};
  Map<String, bool> showTeamFeedback = {};
  bool questionCompleted = false;

  late CompetitionSession session;

  late AnimationController _timerController;
  Timer? _questionTimer;
  int timeRemaining = 0;

  static const int _teamQuizCount = 20;

  int _totalContestSeconds() => questions.fold<int>(0, (s, q) => s + q.timeLimitSeconds);

  int _remainingContestSeconds() {
    int sum = timeRemaining;
    for (int i = currentQuestionIndex + 1; i < questions.length; i++) {
      sum += questions[i].timeLimitSeconds;
    }
    return sum;
  }

  String _fmt(int secs) {
    if (secs < 0) secs = 0;
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(vsync: this);
    _loadCompetitionQuestions();
  }

  Future<void> _loadCompetitionQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
      questions = [];
      currentQuestionIndex = 0;
      teamAnswers.clear();
      showTeamFeedback.clear();
      questionCompleted = false;
    });

    try {
      final fetched = await _db.getRandomQuestionsList(count: _teamQuizCount);

      if (!mounted) return;
      setState(() {
        questions = fetched;
        _isLoading = false;
      });

      if (questions.isNotEmpty) {
        _initializeSession();
        _startQuestionTimer();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _initializeSession() {
    session = CompetitionSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      teams: widget.teams,
      questions: questions,
      startTime: DateTime.now(),
      teamResults: {for (var team in widget.teams) team.name: []},
    );
  }

  void _startQuestionTimer() {
    if (questions.isEmpty) return;

    _questionTimer?.cancel();

    timeRemaining = questions[currentQuestionIndex].timeLimitSeconds;
    _timerController
      ..stop()
      ..reset()
      ..duration = Duration(seconds: timeRemaining)
      ..forward();

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() => timeRemaining--);

      if (timeRemaining <= 0) {
        _completeQuestion();
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    _questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('مسابقة الفرق'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('لا توجد أسئلة متاحة حالياً'),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadCompetitionQuestions, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('مسابقة الفرق'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${currentQuestionIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimerSection(currentQuestion),
            const SizedBox(height: 20),
            _buildLiveStandings(),
            const SizedBox(height: 20),
            _buildQuestionCard(currentQuestion),
            const SizedBox(height: 20),
            Expanded(child: _buildTeamAnswerSection(currentQuestion)),
            if (questionCompleted) _buildNavigationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSection(Question question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الوقت الكلي: ${_fmt(_totalContestSeconds())}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('المتبقي تقريبًا: ${_fmt(_remainingContestSeconds())}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الوقت المتبقي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '$timeRemaining ثانية',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: timeRemaining < 10 ? Colors.red : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: question.timeLimitSeconds == 0 ? 0 : (timeRemaining / question.timeLimitSeconds),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(timeRemaining < 10 ? Colors.red : Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStandings() {
    final sortedTeams = List<Team>.from(widget.teams)..sort((a, b) => b.score.compareTo(a.score));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الترتيب المباشر:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: sortedTeams.take(3).map((team) {
              final rank = sortedTeams.indexOf(team) + 1;
              return Column(
                children: [
                  Text('$rank',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                  Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${team.score} نقطة'),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _getDifficultyColor(question.difficulty), borderRadius: BorderRadius.circular(8)),
            child: Text(_getDifficultyText(question.difficulty),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamAnswerSection(Question question) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.05,
      ),
      itemCount: widget.teams.length,
      itemBuilder: (context, index) {
        final team = widget.teams[index];
        final hasAnswered = teamAnswers.containsKey(team.name);
        final isCorrect = showTeamFeedback[team.name];

        return _buildTeamAnswerCard(
          team: team,
          question: question,
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
        );
      },
    );
  }

  Widget _buildTeamAnswerCard({
    required Team team,
    required Question question,
    required bool hasAnswered,
    bool? isCorrect,
  }) {
    Color cardColor = Colors.white;
    if (hasAnswered) {
      cardColor = isCorrect == true ? Colors.green[50]! : Colors.red[50]!;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAnswered ? (isCorrect == true ? Colors.green : Colors.red) : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(team.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),

            if (!hasAnswered) ...[
              Text('اختر الإجابة:', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),

              // ✅ 4 خيارات (مش 2) — حتى ما تتشوّه المسابقة
              for (int i = 0; i < question.options.length; i++)
                _buildMiniOptionButton(
                  option: question.options[i],
                  isSelected: teamAnswers[team.name] == i,
                  onTap: () => _selectTeamAnswer(team.name, i),
                ),
            ] else ...[
              Icon(isCorrect == true ? Icons.check_circle : Icons.cancel,
                  color: isCorrect == true ? Colors.green : Colors.red, size: 32),
              const SizedBox(height: 4),
              Text(
                isCorrect == true ? 'صحيح!' : 'خطأ',
                style: TextStyle(
                  color: isCorrect == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${team.score} نقطة',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniOptionButton({
    required String option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!),
        ),
        child: Text(
          option,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue[800] : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                currentQuestionIndex < questions.length - 1 ? 'السؤال التالي' : 'إنهاء المسابقة',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectTeamAnswer(String teamName, int optionIndex) {
    setState(() {
      teamAnswers[teamName] = optionIndex;
      if (teamAnswers.length == widget.teams.length) {
        _completeQuestion();
      }
    });
  }

  void _completeQuestion() {
    if (questionCompleted) return;

    _questionTimer?.cancel();

    final currentQuestion = questions[currentQuestionIndex];
    final answeredTime = DateTime.now();

    for (final entry in teamAnswers.entries) {
      final teamName = entry.key;
      final selectedOption = entry.value;
      if (selectedOption == null) continue;

      final isCorrect = currentQuestion.isCorrectAnswer(selectedOption);
      final timeTaken = currentQuestion.timeLimitSeconds - timeRemaining;

      final team = widget.teams.firstWhere((t) => t.name == teamName);

      int points = 0;
      if (isCorrect) {
        points = currentQuestion.getPoints();
        team.incrementCorrect();
      } else {
        team.incrementIncorrect();
        points = -2;
      }

      team.addPoints(points);
      team.addTime(timeTaken);

      final result = QuestionResult(
        question: currentQuestion,
        selectedAnswerIndex: selectedOption,
        answeredAt: answeredTime,
        timeTakenSeconds: timeTaken,
        isCorrect: isCorrect,
        pointsAwarded: points,
      );

      session.teamResults[teamName]?.add(result);
      showTeamFeedback[teamName] = isCorrect;
    }

    setState(() => questionCompleted = true);
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        teamAnswers.clear();
        showTeamFeedback.clear();
        questionCompleted = false;
      });
      _startQuestionTimer();
    } else {
      _finishCompetition();
    }
  }

  void _finishCompetition() {
    session.finishSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CompetitionResultsScreen(session: session)),
    );
  }

  Color _getDifficultyColor(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return Colors.green;
      case QuestionDifficulty.medium:
        return Colors.orange;
      case QuestionDifficulty.hard:
        return Colors.red;
    }
  }

  String _getDifficultyText(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return 'سهل (5 نقاط)';
      case QuestionDifficulty.medium:
        return 'متوسط (10 نقاط)';
      case QuestionDifficulty.hard:
        return 'صعب (15 نقاط)';
    }
  }
}

// ================================
// CompetitionResultsScreen (كما هو عندك)
// ================================
class CompetitionResultsScreen extends StatelessWidget {
  final CompetitionSession session;

  const CompetitionResultsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    List<TeamPerformance> performances = session.getTeamPerformances();

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتائج المسابقة'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSessionInfo(),
            const SizedBox(height: 20),
            _buildWinnerPodium(performances),
            const SizedBox(height: 20),
            Expanded(child: _buildDetailedResults(performances)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('معلومات المسابقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('المدة: ${session.duration.inMinutes} دقيقة'),
          Text('عدد الأسئلة: ${session.questions.length}'),
          Text('عدد الفرق: ${session.teams.length}'),
        ],
      ),
    );
  }

  Widget _buildWinnerPodium(List<TeamPerformance> performances) {
    if (performances.isEmpty) return const SizedBox.shrink();

    final topThree = performances.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('ال podium', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (topThree.length > 1) _buildPodiumPlace(topThree[1], 2),
              if (topThree.isNotEmpty) _buildPodiumPlace(topThree[0], 1),
              if (topThree.length > 2) _buildPodiumPlace(topThree[2], 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(TeamPerformance performance, int place) {
    IconData icon;
    Color color;

    switch (place) {
      case 1:
        icon = Icons.emoji_events;
        color = Colors.yellow;
        break;
      case 2:
        icon = Icons.workspace_premium;
        color = Colors.grey;
        break;
      default:
        icon = Icons.emoji_events_outlined;
        color = Colors.brown;
    }

    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        Text(performance.teamName, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        Text('${performance.totalScore} نقطة', style: const TextStyle(fontSize: 16, color: Colors.blue)),
      ],
    );
  }

  Widget _buildDetailedResults(List<TeamPerformance> performances) {
    return ListView.builder(
      itemCount: performances.length,
      itemBuilder: (context, index) {
        final perf = performances[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${index + 1}. ${perf.teamName}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(8)),
                      child: Text('${perf.totalScore} نقطة',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip('الصحيحة', '${perf.correctAnswers}', Colors.green),
                    _buildStatChip('الخاطئة', '${perf.incorrectAnswers}', Colors.red),
                    _buildStatChip('الدقة', '${perf.accuracy.toStringAsFixed(1)}%', Colors.orange),
                    _buildStatChip('المتوسط', '${perf.averageTimePerQuestion}ث', Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
