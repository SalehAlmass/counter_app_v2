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
  final String category;

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
    this.categoryId,
    this.category = 'General',
  });

  bool isCorrectAnswer(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  int getPoints() {
    int basePoints = _getBasePoints();
    if (answeredAt != null) {
      int timeTaken = DateTime.now().difference(answeredAt!).inSeconds;
      if (timeTaken <= (timeLimitSeconds ~/ 2)) {
        basePoints += 2;
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
    int? categoryId,
    String? category,
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
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'difficulty': difficulty.index,
      'time_limit_seconds': timeLimitSeconds,
      'category_id': categoryId,
      'category': category,
    };
  }
}

enum QuestionDifficulty { easy, medium, hard }
enum QuestionType { multipleChoice, trueFalse, imageBased }

class TeamPerformance {
  final String teamName;
  final int score;
  final int correctAnswers;
  final int incorrectAnswers;
  final int totalTimeSeconds;
  final double accuracy;
  final double averageTimePerQuestion;

  TeamPerformance({
    required this.teamName,
    required this.score,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalTimeSeconds,
  }) : 
    accuracy = (correctAnswers + incorrectAnswers) > 0
        ? (correctAnswers / (correctAnswers + incorrectAnswers)) * 100
        : 0.0,
    averageTimePerQuestion = correctAnswers + incorrectAnswers > 0
        ? totalTimeSeconds / (correctAnswers + incorrectAnswers)
        : 0.0;

  int get totalScore => score;
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

class CompetitionSession {
  final String sessionId;
  final List<Team> teams;
  final List<Question> questions;
  final DateTime startTime;
  final Map<String, List<QuestionResult>> teamResults;

  CompetitionSession({
    required this.sessionId,
    required this.teams,
    required this.questions,
    required this.startTime,
    required this.teamResults,
  });

  void finishSession() {
    // Method to finalize the session
  }

  List<TeamPerformance> getTeamPerformances() {
    List<TeamPerformance> performances = [];
    for (Team team in teams) {
      int correctAnswers = 0;
      int incorrectAnswers = 0;
      int totalTimeSeconds = 0;
      int score = 0;

      // Calculate team performance based on results
      if (teamResults.containsKey(team.name)) {
        List<QuestionResult> results = teamResults[team.name]!;
        for (QuestionResult result in results) {
          if (result.isCorrect) {
            correctAnswers++;
          } else {
            incorrectAnswers++;
          }
          totalTimeSeconds += result.timeTakenSeconds;
          score += result.pointsAwarded;
        }
      }

      performances.add(TeamPerformance(
        teamName: team.name,
        score: score,
        correctAnswers: correctAnswers,
        incorrectAnswers: incorrectAnswers,
        totalTimeSeconds: totalTimeSeconds,
      ));
    }
    return performances;
  }

  Duration get duration {
    return DateTime.now().difference(startTime);
  }
}

class QuestionResult {
  final Question question;
  final int? selectedAnswerIndex;
  final bool isCorrect;
  final int pointsAwarded;
  final int timeTakenSeconds;
  final DateTime answeredAt;

  QuestionResult({
    required this.question,
    this.selectedAnswerIndex,
    required this.isCorrect,
    required this.pointsAwarded,
    required this.timeTakenSeconds,
    required this.answeredAt,
  });
}
/*
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
        category: 'General',
      ),
      Question(
        id: 2,
        question: "ما هي عاصمة السعودية؟",
        options: ["جدة", "الرياض", "مكة", "المدينة"],
        correctAnswerIndex: 1,
        explanation: "الرياض هي العاصمة الرسمية للمملكة العربية السعودية",
        timeLimitSeconds: 45,
        difficulty: QuestionDifficulty.medium,
        category: 'General',
      ),
      Question(
        id: 3,
        question: "كم عدد سور القرآن الكريم؟",
        options: ["110", "112", "114", "116"],
        correctAnswerIndex: 2,
        explanation: "يحتوي القرآن الكريم على 114 سورة",
        timeLimitSeconds: 60,
        difficulty: QuestionDifficulty.hard,
        category: 'General',
      ),
      Question(
        id: 4,
        question: "ما هو أكبر محيط في العالم؟",
        options: ["الأطلسي", "الهندي", "القطبي", "الهادئ"],
        correctAnswerIndex: 3,
        explanation: "المحيط الهادئ هو أكبر المحيطات في العالم",
        timeLimitSeconds: 40,
        difficulty: QuestionDifficulty.medium,
        category: 'General',
      ),
      Question(
        id: 5,
        question: "كم يساوي 15 ÷ 3؟",
        options: ["3", "4", "5", "6"],
        correctAnswerIndex: 2,
        explanation: "15 ÷ 3 = 5",
        timeLimitSeconds: 25,
        difficulty: QuestionDifficulty.easy,
        category: 'General',
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
        category: 'Mathematics',
      ),
      Question(
        id: 2,
        question: "ما مساحة دائرة نصف قطرها 5 سم؟ (π = 3.14)",
        options: ["78.5 سم²", "157 سم²", "314 سم²", "628 سم²"],
        correctAnswerIndex: 0,
        explanation: "المساحة = π × نق² = 3.14 × 25 = 78.5 سم²",
        timeLimitSeconds: 60,
        difficulty: QuestionDifficulty.medium,
        category: 'Mathematics',
      ),
      Question(
        id: 3,
        question: "ما هو الجذر التربيعي للعدد 144؟",
        options: ["10", "11", "12", "13"],
        correctAnswerIndex: 2,
        explanation: "الجذر التربيعي لـ 144 هو 12",
        timeLimitSeconds: 25,
        difficulty: QuestionDifficulty.easy,
        category: 'Mathematics',
      ),
      Question(
        id: 4,
        question: "إذا كان س = 5، فما قيمة 2س + 3؟",
        options: ["10", "13", "15", "18"],
        correctAnswerIndex: 1,
        explanation: "2(5) + 3 = 10 + 3 = 13",
        timeLimitSeconds: 35,
        difficulty: QuestionDifficulty.medium,
        category: 'Mathematics',
      ),
      Question(
        id: 5,
        question: "كم عدد الأضلاع في المضلع الخماسي؟",
        options: ["4", "5", "6", "7"],
        correctAnswerIndex: 1,
        explanation: "المضلع الخماسي له 5 أضلاع",
        timeLimitSeconds: 20,
        difficulty: QuestionDifficulty.easy,
        category: 'Mathematics',
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
        category: 'General Knowledge',
      ),
      Question(
        id: 2,
        question: "من هو مؤسس شركة آبل؟",
        options: ["بيل جيتس", "مارك زوكربيرج", "ستيف جوبز", "إيلون ماسك"],
        correctAnswerIndex: 2,
        explanation: "ستيف جوبز هو المؤسس المشارك لشركة آبل",
        timeLimitSeconds: 35,
        difficulty: QuestionDifficulty.medium,
        category: 'General Knowledge',
      ),
      Question(
        id: 3,
        question: "ما هو أعلى جبل في العالم؟",
        options: ["كليمنجارو", "الهيمالايا", "ايفست", "دنالي"],
        correctAnswerIndex: 2,
        explanation: "جبل ايفست هو أعلى جبل في العالم",
        timeLimitSeconds: 45,
        difficulty: QuestionDifficulty.medium,
        category: 'General Knowledge',
      ),
    ];
  }

  // Religious Questions
  static List<Question> getReligiousQuestions() {
    return [
      Question(
        id: 1,
        question: "ما هي أول فريضة فرضها الله على المسلمين؟",
        options: ["الصلاة", "الزكاة", "الصيام", "الحج"],
        correctAnswerIndex: 0,
        explanation: "الصلاة كانت أول فريضة فرضها الله على المسلمين",
        timeLimitSeconds: 50,
        difficulty: QuestionDifficulty.hard,
        category: 'Religion',
      ),
      Question(
        id: 2,
        question: "من هو أول رسول بعثه الله تعالى؟",
        options: ["نوح", "إبراهيم", "موسى", "آدم"],
        correctAnswerIndex: 3,
        explanation: "النبي آدم عليه السلام هو أول رسول بعثه الله تعالى",
        timeLimitSeconds: 45,
        difficulty: QuestionDifficulty.medium,
        category: 'Religion',
      ),
      Question(
        id: 3,
        question: "كم عدد أركان الإسلام؟",
        options: ["4", "5", "6", "7"],
        correctAnswerIndex: 1,
        explanation: "أركان الإسلام الخمسة هي: الشهادة، الصلاة، الزكاة، الصيام، الحج",
        timeLimitSeconds: 25,
        difficulty: QuestionDifficulty.easy,
        category: 'Religion',
      ),
      Question(
        id: 4,
        question: "من هو أول نبي بعثه الله؟",
        options: ["نوح", "إبراهيم", "موسى", "آدم"],
        correctAnswerIndex: 3,
        explanation: "النبي آدم عليه السلام هو أول الأنبياء المرسلين",
        timeLimitSeconds: 35,
        difficulty: QuestionDifficulty.medium,
        category: 'Religion',
      ),
      Question(
        id: 5,
        question: "ما هي أطول سورة في القرآن الكريم؟",
        options: ["البقرة", "آل عمران", "النساء", "المائدة"],
        correctAnswerIndex: 0,
        explanation: "سورة البقرة هي أطول سور القرآن الكريم",
        timeLimitSeconds: 50,
        difficulty: QuestionDifficulty.hard,
        category: 'Religion',
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
        category: 'Riddles',
      ),
      Question(
        id: 2,
        question: "له أسنان ولا يعض، له رأس ولا يعقل، فمن هو؟",
        options: ["المطر", "القلم", "المنشار", "الثعبان"],
        correctAnswerIndex: 2,
        explanation: "المنشار له أسنان حادة ولا يعض، وله رأس ولا يعقل",
        timeLimitSeconds: 50,
        difficulty: QuestionDifficulty.medium,
        category: 'Riddles',
      ),
      Question(
        id: 3,
        question: "أمشي بلا قدمين وأتكلم بلا لسان، فمن أنا؟",
        options: ["الكتاب", "الهاتف", "الرسالة", "البريد"],
        correctAnswerIndex: 0,
        explanation: "الكتاب يمشي بالأفكار بلا قدمين ويتكلم بالمعرفة بلا لسان",
        timeLimitSeconds: 45,
        difficulty: QuestionDifficulty.medium,
        category: 'Riddles',
      ),
      Question(
        id: 4,
        question: "كلما أخذت منه زاد، فمن هو؟",
        options: ["الحفر", "العمر", "المال", "العلم"],
        correctAnswerIndex: 0,
        explanation: "كلما حفرت في الأرض زاد الحفر أكثر فأكثر",
        timeLimitSeconds: 40,
        difficulty: QuestionDifficulty.medium,
        category: 'Riddles',
      ),
      Question(
        id: 5,
        question: "له أوراق وليس شجرة، ولحم وليس حيوان، فمن هو؟",
        options: ["الكتاب", "الورق", "الحقيبة", "الصندوق"],
        correctAnswerIndex: 0,
        explanation: "الكتاب له أوراق (صفحات) وليس شجرة، وله لحم (محتوى) وليس حيواناً",
        timeLimitSeconds: 55,
        difficulty: QuestionDifficulty.hard,
        category: 'Riddles',
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
}*/