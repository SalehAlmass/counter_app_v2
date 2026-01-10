class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final QuestionDifficulty difficulty;
  final int timeLimitSeconds;
  final QuestionType type;
  final DateTime? answeredAt;
  final bool? isCorrect;
  final int? categoryId;
 
  
  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.difficulty = QuestionDifficulty.medium,
    this.timeLimitSeconds = 30,
    this.type = QuestionType.multipleChoice,
    this.answeredAt,
    this.isCorrect,
    this.categoryId = 0,

  });

  bool isCorrectAnswer(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  int getPoints() {
    int basePoints = _getBasePoints();
    // Bonus points for quick answers (within 50% of time limit)
    if (answeredAt != null) {
      int timeTaken = DateTime.now().difference(answeredAt!).inSeconds;
      if (timeTaken <= (timeLimitSeconds ~/ 2)) {
        basePoints += 2; // Speed bonus
      }
    }
    return basePoints;
  }

  int _getBasePoints() {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return 5;
      case QuestionDifficulty.medium:
        return 10;
      case QuestionDifficulty.hard:
        return 15;
    }
  }

  Question copyWith({
    int? id,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    QuestionDifficulty? difficulty,
    int? timeLimitSeconds,
    QuestionType? type,
    DateTime? answeredAt,
    bool? isCorrect,
  }) {
    return Question(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      type: type ?? this.type,
      answeredAt: answeredAt ?? this.answeredAt,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  // Convert Question object to Map for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'option1': options[0],
      'option2': options[1],
      'option3': options[2],
      'option4': options[3],
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'difficulty': difficulty.index,
      'time_limit_seconds': timeLimitSeconds,
    };
  }
}

enum QuestionDifficulty { easy, medium, hard }
enum QuestionType { multipleChoice, trueFalse, imageBased }

class TeamPerformance {
  final String teamName;
  final int totalScore;
  final int correctAnswers;
  final int incorrectAnswers;
  final int totalTimeSeconds;
  final Map<QuestionDifficulty, int> scoreByDifficulty;
  final List<QuestionResult> questionResults;

  TeamPerformance({
    required this.teamName,
    required this.totalScore,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalTimeSeconds,
    required this.scoreByDifficulty,
    required this.questionResults,
  });

  double get accuracy => 
      (correctAnswers + incorrectAnswers) > 0 
      ? (correctAnswers / (correctAnswers + incorrectAnswers)) * 100
      : 0.0;

  int get averageTimePerQuestion => 
      questionResults.isNotEmpty
      ? totalTimeSeconds ~/ questionResults.length 
      : 0;
}

class QuestionResult {
  final Question question;
  final int selectedOptionIndex;
  final DateTime answeredAt;
  final int timeTakenSeconds;
  final bool isCorrect;
  final int pointsEarned;

  QuestionResult({
    required this.question,
    required this.selectedOptionIndex,
    required this.answeredAt,
    required this.timeTakenSeconds,
    required this.isCorrect,
    required this.pointsEarned,
  });
}

class CompetitionSession {
  final String sessionId;
  final List<Team> teams;
  final List<Question> questions;
  final DateTime startTime;
  late DateTime endTime;
  final Map<String, List<QuestionResult>> teamResults;
  bool isActive = true;

  CompetitionSession({
    required this.sessionId,
    required this.teams,
    required this.questions,
    required this.startTime,
    required this.teamResults,
  });

  void finishSession() {
    endTime = DateTime.now();
    isActive = false;
  }

  Duration get duration => endTime.difference(startTime);

  List<TeamPerformance> getTeamPerformances() {
    List<TeamPerformance> performances = [];
    
    for (var team in teams) {
      List<QuestionResult> results = teamResults[team.name] ?? [];
      
      int totalScore = results.fold(0, (sum, result) => sum + result.pointsEarned);
      int correctAnswers = results.where((result) => result.isCorrect).length;
      int incorrectAnswers = results.where((result) => !result.isCorrect).length;
      int totalTime = results.fold(0, (sum, result) => sum + result.timeTakenSeconds);
      
      Map<QuestionDifficulty, int> scoreByDifficulty = {
        QuestionDifficulty.easy: 0,
        QuestionDifficulty.medium: 0,
        QuestionDifficulty.hard: 0,
      };
      
      for (var result in results) {
        if (result.isCorrect) {
          scoreByDifficulty[result.question.difficulty] = 
              scoreByDifficulty[result.question.difficulty]! + result.pointsEarned;
        }
      }
      
      performances.add(TeamPerformance(
        teamName: team.name,
        totalScore: totalScore,
        correctAnswers: correctAnswers,
        incorrectAnswers: incorrectAnswers,
        totalTimeSeconds: totalTime,
        scoreByDifficulty: scoreByDifficulty,
        questionResults: results,
      ));
    }
    
    // Sort by score descending
    performances.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return performances;
  }
}

class Team {
  final String name;
  final List<TeamMember> members;
  int score = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  int totalTimeSeconds = 0;

  Team({
    required this.name,
    required this.members,
  });

  void addPoints(int points) {
    score += points;
  }

  void incrementCorrect() {
    correctAnswers++;
  }

  void incrementIncorrect() {
    incorrectAnswers++;
  }

  void addTime(int seconds) {
    totalTimeSeconds += seconds;
  }

  double get accuracy => 
      (correctAnswers + incorrectAnswers) > 0 
      ? (correctAnswers / (correctAnswers + incorrectAnswers)) * 100
      : 0.0;

  Team copyWith({
    String? name,
    List<TeamMember>? members,
    int? score,
    int? correctAnswers,
    int? incorrectAnswers,
    int? totalTimeSeconds,
  }) {
    return Team(
      name: name ?? this.name,
      members: members ?? this.members,
    )..score = score ?? this.score
      ..correctAnswers = correctAnswers ?? this.correctAnswers
      ..incorrectAnswers = incorrectAnswers ?? this.incorrectAnswers
      ..totalTimeSeconds = totalTimeSeconds ?? this.totalTimeSeconds;
  }
}

class TeamMember {
  final String name;
  int personalScore = 0;
  int answeredQuestions = 0;
  int correctAnswers = 0;

  TeamMember({required this.name});

  void addPoints(int points) {
    personalScore += points;
    answeredQuestions++;
  }

  void incrementCorrect() {
    correctAnswers++;
  }

  double get accuracy => 
      answeredQuestions > 0 
      ? (correctAnswers / answeredQuestions) * 100
      : 0.0;
}

class QuizData {
  static List<Question> getQuestions() {
    return [
      Question(
        id: 1,
        question: "كم يساوي 2+2؟",
        options: ["3", "4", "5", "6"],
        correctAnswerIndex: 1,
        explanation: "2+2=4",
        timeLimitSeconds: 30,
        difficulty: QuestionDifficulty.easy,
      ),
      Question(
        id: 2,
        question: "ما هي عاصمة السعودية؟",
        options: ["جدة", "الرياض", "مكة", "المدينة"],
        correctAnswerIndex: 1,
        explanation: "الرياض هي العاصمة الرسمية للمملكة العربية السعودية",
        timeLimitSeconds: 45,
        difficulty: QuestionDifficulty.medium,
      ),
      Question(
        id: 3,
        question: "كم عدد سور القرآن الكريم؟",
        options: ["110", "112", "114", "116"],
        correctAnswerIndex: 2,
        explanation: "يحتوي القرآن الكريم على 114 سورة",
        timeLimitSeconds: 60,
        difficulty: QuestionDifficulty.hard,
      ),
      Question(
        id: 4,
        question: "ما هو أكبر محيط في العالم؟",
        options: ["الأطلسي", "الهندي", "القطبي", "الهادئ"],
        correctAnswerIndex: 3,
        explanation: "المحيط الهادئ هو أكبر المحيطات في العالم",
        timeLimitSeconds: 40,
        difficulty: QuestionDifficulty.medium,
      ),
      Question(
        id: 5,
        question: "كم يساوي 15 ÷ 3؟",
        options: ["3", "4", "5", "6"],
        correctAnswerIndex: 2,
        explanation: "15 ÷ 3 = 5",
        timeLimitSeconds: 25,
        difficulty: QuestionDifficulty.easy,
      ),
    ];
  }

  // Mathematics Questions
  static List<Question> getMathQuestions() {
    return [
      Question(
        id: 1,
        question: "كم يساوي 7 × 8؟",
        options: ["54", "56", "58", "60"],
        correctAnswerIndex: 1,
        explanation: "7 × 8 = 56",
        timeLimitSeconds: 30,
        difficulty: QuestionDifficulty.easy,
      ),
      Question(
        id: 2,
        question: "ما مساحة دائرة نصف قطرها 5 سم؟ (π = 3.14)",
        options: ["78.5 سم²", "157 سم²", "314 سم²", "628 سم²"],
        correctAnswerIndex: 0,
        explanation: "المساحة = π × نق² = 3.14 × 25 = 78.5 سم²",
        timeLimitSeconds: 60,
        difficulty: QuestionDifficulty.medium,
      ),
      Question(
        id: 3,
        question: "ما هو الجذر التربيعي للعدد 144؟",
        options: ["10", "11", "12", "13"],
        correctAnswerIndex: 2,
        explanation: "الجذر التربيعي لـ 144 هو 12",
        timeLimitSeconds: 25,
        difficulty: QuestionDifficulty.easy,
      ),
      Question(
        id: 4,
        question: "إذا كان س = 5، فما قيمة 2س + 3؟",
        options: ["10", "13", "15", "18"],
        correctAnswerIndex: 1,
        explanation: "2(5) + 3 = 10 + 3 = 13",
        timeLimitSeconds: 35,
        difficulty: QuestionDifficulty.medium,
      ),
      Question(
        id: 5,
        question: "كم عدد الأضلاع في المضلع الخماسي؟",
        options: ["4", "5", "6", "7"],
        correctAnswerIndex: 1,
        explanation: "المضلع الخماسي له 5 أضلاع",
        timeLimitSeconds: 20,
        difficulty: QuestionDifficulty.easy,
      ),
    ];
  }

  // General Knowledge Questions
  static List<Question> getGeneralKnowledgeQuestions() {
    return [
      Question(
        id: 1,
        question: "ما هي أكبر قارة من حيث المساحة؟",
        options: ["أفريقيا", "أمريكا الشمالية", "آسيا", "أوروبا"],
        correctAnswerIndex: 2,
        explanation: "آسيا هي أكبر قارة في العالم من حيث المساحة",
        timeLimitSeconds: 40,
        difficulty: QuestionDifficulty.medium,
      ),
      Question(
        id: 2,
        question: "من هو مؤسس شركة آبل؟",
        options: ["بيل جيتس", "مارك زوكربيرج", "ستيف جوبز", "إيلون ماسك"],
        correctAnswerIndex: 2,
        explanation: "ستيف جوبز هو المؤسس المشارك لشركة آبل",
        timeLimitSeconds: 35,
        difficulty: QuestionDifficulty.medium,
      ),
      Question(
        id: 3,
        question: "ما هي العملة الرسمية للسعودية؟",
        options: ["درهم", "ريال", "دينار", "جنيه"],
        correctAnswerIndex: 1,
        explanation: "الريال السعودي هو العملة الرسمية للمملكة العربية السعودية",
        timeLimitSeconds: 25,
        difficulty: QuestionDifficulty.easy,
      ),
      Question(
        id: 4,
        question: "كم عدد الكواكب في النظام الشمسي؟",
        options: ["7", "8", "9", "10"],
        correctAnswerIndex: 1,
        explanation: "هناك 8 كواكب في النظام الشمسي",
        timeLimitSeconds: 30,
        difficulty: QuestionDifficulty.easy,
      ),
      Question(
        id: 5,
        question: "ما هي أعلى جبل في العالم؟",
        options: ["كليمنجارو", "إيفرست", "ك2", "ماتر هورن"],
        correctAnswerIndex: 1,
        explanation: "جبل إيفرست هو أعلى جبل في العالم بارتفاع 8848 متر",
        timeLimitSeconds: 45,
        difficulty: QuestionDifficulty.hard,
      ),
    ];
  }

  // Religious Questions
  static List<Question> getReligiousQuestions() {
    return [
      Question(
        id: 1,
        question: "كم عدد الآيات في سورة الفاتحة؟",
        options: ["5", "6", "7", "8"],
        correctAnswerIndex: 2,
        explanation: "سورة الفاتحة تحتوي على 7 آيات",
        timeLimitSeconds: 30,
        difficulty: QuestionDifficulty.easy,
      ),
      Question(
        id: 2,
        question: "ما هي أول obligation واجب في الإسلام؟",
        options: ["الشهادة", "الصلاة", "الزكاة", "الحج"],
        correctAnswerIndex: 0,
        explanation: "الشهادة أن لا إله إلا الله وأن محمداً رسول الله هي أول أركان الإسلام",
        timeLimitSeconds: 45,
        difficulty: QuestionDifficulty.medium,
      ),
      Question(
        id: 3,
        question: "كم عدد أركان الإسلام؟",
        options: ["4", "5", "6", "7"],
        correctAnswerIndex: 1,
        explanation: "أركان الإسلام الخمسة هي: الشهادة، الصلاة، الزكاة، الصيام، الحج",
        timeLimitSeconds: 25,
        difficulty: QuestionDifficulty.easy,
      ),
      Question(
        id: 4,
        question: "من هو أول نبي بعثه الله؟",
        options: ["نوح", "إبراهيم", "موسى", "آدم"],
        correctAnswerIndex: 3,
        explanation: "النبي آدم عليه السلام هو أول الأنبياء المرسلين",
        timeLimitSeconds: 35,
        difficulty: QuestionDifficulty.medium,
      ),
      Question(
        id: 5,
        question: "ما هي أطول سورة في القرآن الكريم؟",
        options: ["البقرة", "آل عمران", "النساء", "المائدة"],
        correctAnswerIndex: 0,
        explanation: "سورة البقرة هي أطول سور القرآن الكريم",
        timeLimitSeconds: 50,
        difficulty: QuestionDifficulty.hard,
      ),
    ];
  }

  // Riddles Questions
  static List<Question> getRiddlesQuestions() {
    return [
      Question(
        id: 1,
        question: "أشير إليك ولا تراني، وإذا سمعتني فلا تراني، فمن أنا؟",
        options: ["الصدى", "الظل", "الصوت", "الضوء"],
        correctAnswerIndex: 0,
        explanation: "الصدى يشير إليك ولا تراه، وترى الصدى عندما تسمعه",
        timeLimitSeconds: 60,
        difficulty: QuestionDifficulty.hard,
      ),
      Question(
        id: 2,
        question: "له أسنان ولا يعض، له رأس ولا يعقل، فمن هو؟",
        options: ["المطر", "القلم", "المنشار", "الثعبان"],
        correctAnswerIndex: 2,
        explanation: "المنشار له أسنان حادة ولا يعض، وله رأس ولا يعقل",
        timeLimitSeconds: 50,
        difficulty: QuestionDifficulty.medium,
      ),
      Question(
        id: 3,
        question: "أمشي بلا قدمين وأتكلم بلا لسان، فمن أنا؟",
        options: ["الكتاب", "الهاتف", "الرسالة", "البريد"],
        correctAnswerIndex: 0,
        explanation: "الكتاب يمشي بالأفكار بلا قدمين ويتكلم بالمعرفة بلا لسان",
        timeLimitSeconds: 45,
        difficulty: QuestionDifficulty.medium,
      ),
      Question(
        id: 4,
        question: "كلما أخذت منه زاد، فمن هو؟",
        options: ["الحفر", "العمر", "المال", "العلم"],
        correctAnswerIndex: 0,
        explanation: "كلما حفرت في الأرض زاد الحفر أكثر فأكثر",
        timeLimitSeconds: 40,
        difficulty: QuestionDifficulty.medium,
      ),
      Question(
        id: 5,
        question: "له أوراق وليس شجرة، ولحم وليس حيوان، ومن هو؟",
        options: ["الكتاب", "الورق", "الحقيبة", "الصندوق"],
        correctAnswerIndex: 0,
        explanation: "الكتاب له أوراق (صفحات) وليس شجرة، وله لحم (محتوى) وليس حيواناً",
        timeLimitSeconds: 55,
        difficulty: QuestionDifficulty.hard,
      ),
    ];
  }

  // Generate competition questions
  static List<Question> generateCompetitionQuestions(int count) {
    List<Question> allQuestions = [];
    allQuestions.addAll(getQuestions());
    allQuestions.addAll(getMathQuestions());
    allQuestions.addAll(getGeneralKnowledgeQuestions());
    allQuestions.addAll(getReligiousQuestions());
    allQuestions.addAll(getRiddlesQuestions());
    
    // Shuffle and return requested count
    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }
  
  // Get questions by category name
  static List<Question> getQuestionsByCategory(String categoryName) {
    switch (categoryName) {
      case 'الرياضيات':
        return getMathQuestions();
      case 'الثقافة العامة':
        return getGeneralKnowledgeQuestions();
      case 'الدين الإسلامي':
        return getReligiousQuestions();
      case 'الألغاز':
        return getRiddlesQuestions();
      default:
        return getQuestions();
    }
  }
}
