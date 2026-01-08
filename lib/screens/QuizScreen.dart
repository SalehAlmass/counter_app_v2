import 'dart:async';
import 'package:counter_app/models/question_model.dart';
import 'package:flutter/material.dart';

// Original 100-question quiz screen
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

// Enhanced team competition screen
class EnhancedQuizScreen extends StatefulWidget {
  final List<Team> teams;
  
  const EnhancedQuizScreen({super.key, required this.teams});

  @override
  State<EnhancedQuizScreen> createState() => _EnhancedQuizScreenState();
}

class _EnhancedQuizScreenState extends State<EnhancedQuizScreen> 
    with TickerProviderStateMixin {
  late List<Question> questions;
  int currentQuestionIndex = 0;
  Map<String, int?> teamAnswers = {};
  Map<String, bool> showTeamFeedback = {};
  bool questionCompleted = false;
  late CompetitionSession session;
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  Timer? _questionTimer;
  int timeRemaining = 0;

  @override
  void initState() {
    super.initState();
    questions = QuizData.generateCompetitionQuestions(20);
    _initializeSession();
    _startQuestionTimer();
    _setupAnimations();
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

  void _setupAnimations() {
    _timerController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_timerController);
  }

  void _startQuestionTimer() {
    timeRemaining = questions[currentQuestionIndex].timeLimitSeconds;
    _timerController.reset();
    _timerController.duration = Duration(seconds: timeRemaining);
    _timerController.forward();
    
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeRemaining--;
      });
      
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
    Question currentQuestion = questions[currentQuestionIndex];
    
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
              const Text(
                'الوقت المتبقي:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
            value: timeRemaining / question.timeLimitSeconds,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              timeRemaining < 10 ? Colors.red : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStandings() {
    List<Team> sortedTeams = List.from(widget.teams)
      ..sort((a, b) => b.score.compareTo(a.score));
    
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
          const Text(
            'الترتيب المباشر:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: sortedTeams.take(3).map((team) {
              int rank = sortedTeams.indexOf(team) + 1;
              return Column(
                children: [
                  Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    team.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
            decoration: BoxDecoration(
              color: _getDifficultyColor(question.difficulty),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getDifficultyText(question.difficulty),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
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
        childAspectRatio: 1.2,
      ),
      itemCount: widget.teams.length,
      itemBuilder: (context, index) {
        Team team = widget.teams[index];
        bool hasAnswered = teamAnswers.containsKey(team.name);
        bool? isCorrect = showTeamFeedback[team.name];
        
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
          color: hasAnswered 
            ? (isCorrect == true ? Colors.green : Colors.red)
            : Colors.grey[300]!,
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
            Text(
              team.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (!hasAnswered) ...[
              Text(
                'اختر الإجابة:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              ...List.generate(2, (i) => i).map((optionIndex) {
                int actualOption = optionIndex * 2;
                return _buildMiniOptionButton(
                  option: question.options[actualOption],
                  isSelected: teamAnswers[team.name] == actualOption,
                  onTap: () => _selectTeamAnswer(team.name, actualOption),
                );
              }),
            ] else ...[
              Icon(
                isCorrect == true ? Icons.check_circle : Icons.cancel,
                color: isCorrect == true ? Colors.green : Colors.red,
                size: 32,
              ),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
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
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          option,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                currentQuestionIndex < questions.length - 1 
                  ? 'السؤال التالي' 
                  : 'إنهاء المسابقة',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
    _questionTimer?.cancel();
    
    Question currentQuestion = questions[currentQuestionIndex];
    DateTime answeredTime = DateTime.now();
    
    for (var entry in teamAnswers.entries) {
      String teamName = entry.key;
      int? selectedOptionNullable = entry.value;
      if (selectedOptionNullable == null) continue;
      
      int selectedOption = selectedOptionNullable;
      bool isCorrect = currentQuestion.isCorrectAnswer(selectedOption);
      int timeTaken = currentQuestion.timeLimitSeconds - timeRemaining;
      
      Team? team = widget.teams.firstWhere((t) => t.name == teamName);
      if (team != null) {
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
        
        QuestionResult result = QuestionResult(
          question: currentQuestion,
          selectedOptionIndex: selectedOption,
          answeredAt: answeredTime,
          timeTakenSeconds: timeTaken,
          isCorrect: isCorrect,
          pointsEarned: points,
        );
        
        session.teamResults[teamName]?.add(result);
        showTeamFeedback[teamName] = isCorrect;
      }
    }
    
    setState(() {
      questionCompleted = true;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        teamAnswers.clear();
        showTeamFeedback.clear();
        questionCompleted = false;
        timeRemaining = questions[currentQuestionIndex].timeLimitSeconds;
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
      MaterialPageRoute(
        builder: (context) => CompetitionResultsScreen(session: session),
      ),
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
          const Text(
            'معلومات المسابقة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
    
    List<TeamPerformance> topThree = performances.take(3).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'ال podium',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
        Text(
          performance.teamName,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          '${performance.totalScore} نقطة',
          style: const TextStyle(fontSize: 16, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildDetailedResults(List<TeamPerformance> performances) {
    return ListView.builder(
      itemCount: performances.length,
      itemBuilder: (context, index) {
        TeamPerformance perf = performances[index];
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
                    Text(
                      '${index + 1}. ${perf.teamName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${perf.totalScore} نقطة',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
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
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> questions;
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  bool showFeedback = false;
  bool isAnswerCorrect = false;
  int score = 0;
  bool quizCompleted = false;

  @override
  void initState() {
    super.initState();
    questions = QuizData.getQuestions();
    _extendToHundredQuestions();
  }

  void _extendToHundredQuestions() {
    List<Question> originalQuestions = List.from(questions);
    int originalLength = originalQuestions.length;
    
    while (questions.length < 100) {
      for (var question in originalQuestions) {
        if (questions.length >= 100) break;
        
        List<String> shuffledOptions = List.from(question.options);
        shuffledOptions.shuffle();
        
        int newCorrectIndex = shuffledOptions.indexOf(question.options[question.correctAnswerIndex]);
        
        questions.add(Question(
          id: questions.length + 1,
          question: "${question.question} (النسخة ${questions.length ~/ originalLength + 1})",
          options: shuffledOptions,
          correctAnswerIndex: newCorrectIndex,
          explanation: question.explanation,
        ));
      }
    }
    
    questions.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    if (quizCompleted) {
      return _buildCompletionScreen();
    }

    Question currentQuestion = questions[currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار المائة سؤال'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${currentQuestionIndex + 1}/100',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
              value: (currentQuestionIndex + 1) / 100,
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
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
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
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
                  border: Border.all(
                    color: isAnswerCorrect ? Colors.green : Colors.red,
                  ),
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
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    currentQuestionIndex < 99 ? 'السؤال التالي' : 'إنهاء الاختبار',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                child: isSelected
                    ? Icon(Icons.circle, color: borderColor, size: 16)
                    : null,
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
                  color: showFeedback && (isCorrect || (isSelected && !isCorrect))
                      ? borderColor
                      : Colors.black87,
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
      
      Question currentQuestion = questions[currentQuestionIndex];
      isAnswerCorrect = currentQuestion.isCorrectAnswer(optionIndex);
      
      if (isAnswerCorrect) {
        score += 10;
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < 99) {
      setState(() {
        currentQuestionIndex++;
        selectedOptionIndex = null;
        showFeedback = false;
        isAnswerCorrect = false;
      });
    } else {
      setState(() {
        quizCompleted = true;
      });
    }
  }

  Widget _buildCompletionScreen() {
    double percentage = (score / 1000) * 100;
    String grade = _getGrade(percentage);
    Color gradeColor = _getGradeColor(grade);
    
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
            Icon(
              Icons.emoji_events,
              size: 100,
              color: gradeColor,
            ),
            
            const SizedBox(height: 30),
            
            Text(
              grade,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: gradeColor,
              ),
            ),
            
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
                  Text(
                    'النتيجة النهائية',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$score / 1000',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('الأسئلة', '100'),
                      _buildStatCard('الصحيحة', '${(score ~/ 10)}'),
                      _buildStatCard('الخاطئة', '${100 - (score ~/ 10)}'),
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
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex = 0;
                        selectedOptionIndex = null;
                        showFeedback = false;
                        isAnswerCorrect = false;
                        score = 0;
                        quizCompleted = false;
                        questions.shuffle();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'إعادة الاختبار',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    child: const Text(
                      'العودة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
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