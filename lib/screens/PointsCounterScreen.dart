import 'dart:async';
import 'package:counter_app/cubit/counter_cubit.dart';
import 'package:counter_app/cubit/counter_state.dart';
import 'package:counter_app/models/question_model.dart';
import 'package:counter_app/screens/QuizScreen.dart';
import 'package:counter_app/utils/app_constants.dart';
import 'package:counter_app/widgets/CustomAppbar.dart';
import 'package:counter_app/widgets/QuestionSection.dart';
import 'package:counter_app/widgets/ResultsTableWidget.dart';
import 'package:flutter/material.dart';
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
  int currentQuestionIndex = 0;
  String? selectedOption;
  List<Team> teams = [
    Team(name: "الفريق الأول", members: [TeamMember(name: "عضو 1")]),
    Team(name: "الفريق الثاني", members: [TeamMember(name: "عضو 2")]),
  ];
  
  // Timer related variables
  late List<Question> questions;
  late Timer _questionTimer;
  int timeRemaining = 30;
  bool isTimeExpired = false;
  bool showCorrectAnswerOnly = false;

  @override
  void initState() {
    super.initState();
    // Use provided questions or default to general questions
    questions = widget.initialQuestions ?? QuizData.getQuestions();
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    timeRemaining = questions[currentQuestionIndex].timeLimitSeconds;
    isTimeExpired = false;
    showCorrectAnswerOnly = false;
    
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeRemaining--;
      });
      
      if (timeRemaining <= 0) {
        _handleTimeExpiration();
        timer.cancel();
      }
    });
  }

  void _handleTimeExpiration() {
    setState(() {
      isTimeExpired = true;
      showCorrectAnswerOnly = true;
    });
  }

  @override
  void dispose() {
    _questionTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CounterCubit, CounterState>(
      builder: (context, state) {
        final counterCubit = context.read<CounterCubit>();
        String winner = counterCubit.getWinner();
        int winnerScore = counterCubit.getWinnerScore();
        List<String> teamNames = counterCubit.getTeamNames();
        return Scaffold(
          appBar: CustomAppbar(initialDuration: const Duration(minutes: 2)),
          body: Stack(
            children: [
              _buildMainContent(counterCubit, teamNames),
              if (showWinner) _buildWinnerOverlay(winner, winnerScore),
            ],
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'team_competition_fab', // Add unique hero tag
                onPressed: () => _showTeamSetupDialog(),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.group),
                label: const Text('مسابقة الفرق'),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: 'individual_quiz_fab', // Add unique hero tag
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
      listener: (context, state) {},
    );
  }

  Widget _buildMainContent(CounterCubit counterCubit, List<String> teamNames) {
    return Row(
      children: [   
        _buildResultsSection(counterCubit, teamNames),
        _buildQuestionSection(),
      ],
    );
  }

  Widget _buildQuestionSection() {
    Question currentQuestion = questions[currentQuestionIndex];
    
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: QuestionSection(
          onOptionSelected: (option) => setState(() => selectedOption = option),
          onNextQuestion: _handleNextQuestion,
          onPreviousQuestion: _handlePreviousQuestion,
          currentQuestionIndex: currentQuestionIndex,
          totalQuestions: questions.length,
          currentQuestion: currentQuestion,
          timeRemaining: timeRemaining,
          showCorrectAnswerOnly: showCorrectAnswerOnly,
          isTimeExpired: isTimeExpired,
          onTimerTap: _restartTimer, // Add timer tap callback
        ),
      ),
    );
  }

  Widget _buildResultsSection(CounterCubit counterCubit, List<String> teamNames) {
    return Expanded(
      flex: 3,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: ResultsTableWidget(
          counterCubit: counterCubit,
          teamNames: teamNames,
          onResetTable: () => counterCubit.resetTable(),
          getTotalScore: _getTeamTotalScore,
          onShowWinner: () => setState(() => showWinner = true),
        ),
      ),
    );
  }

  void _showTeamSetupDialog() {
    TextEditingController teamNameController = TextEditingController();
    List<Team> tempTeams = List.from(teams);
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                        String teamName = teamNameController.text.trim();
                        if (teamName.isNotEmpty) {
                          setState(() {
                            tempTeams.add(Team(
                              name: teamName,
                              members: [TeamMember(name: "عضو 1")],
                            ));
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
                                  setState(() {
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

  Widget _buildWinnerOverlay(String winner, int winnerScore) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => showWinner = false),
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
                Text(
                  winner.isEmpty ? "لا توجد فرق" : "الفائز: $winner",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
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
                  onPressed: () => setState(() => showWinner = false),
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

  // MARK: - Event Handlers

  void _handleNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
        showCorrectAnswerOnly = false;
        isTimeExpired = false;
      });
      _startQuestionTimer();
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
      _startQuestionTimer();
    }
  }

  void _restartTimer() {
    setState(() {
      showCorrectAnswerOnly = false;
      isTimeExpired = false;
    });
    _startQuestionTimer();
  }

  // MARK: - Helper Methods

  int _getTeamTotalScore(int teamIndex) {
    final counterCubit = context.read<CounterCubit>();
    int totalScore = 0;

    for (List<int> row in counterCubit.scoreTable) {
      if (row.length > teamIndex) {
        totalScore += row[teamIndex];
      }
    }

    return totalScore;
  }
}