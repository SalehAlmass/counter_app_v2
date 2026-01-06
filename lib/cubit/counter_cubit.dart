import 'package:counter_app/cubit/counter_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterTeamAState());
  
  // Team scores
  int A = 0;
  int B = 0;
  int C = 0;
  int D = 0;
  
  // Team names list instead of individual variables
  List<String> teamNames = ['الفريق الأول', 'الفريق الثاني', 'الفريق الثالث', 'الفريق الرابع'];
  
  // Table data: List of rows, each row contains scores for all teams
  List<List<int>> scoreTable = [];

  addcounterA({required String Team,required int number}) {
    switch (Team) {
      case "a":
        A = (A + number < 0) ? 0 : A + number;
        emit(CounterTeamAState());
        break;
      case "b":
        B = (B + number < 0) ? 0 : B + number;
        emit(CounterTeamBState());
        break;
      case "c":
        C = (C + number < 0) ? 0 : C + number;
        emit(CounterTeamCState());
        break;
      case "d":
        D = (D + number < 0) ? 0 : D + number;
        emit(CounterTeamDState());
        break;
    }
  }

  // Methods for table functionality
  void addRow() {
    List<int> newRow = List.filled(teamNames.length, 0);
    scoreTable.add(newRow); // Add a new row with 0 scores for all teams
    _updateTotalScores();
    emit(CounterTeamAState());
  }
  
  void removeRow(int index) {
    if (index >= 0 && index < scoreTable.length) {
      scoreTable.removeAt(index);
      _updateTotalScores();
      emit(CounterTeamAState());
    }
  }
  
  void updateScore(int rowIndex, int teamIndex, int score) {
    if (rowIndex >= 0 && rowIndex < scoreTable.length && 
        teamIndex >= 0 && teamIndex < teamNames.length) {
      scoreTable[rowIndex][teamIndex] = score;
      _updateTotalScores();
      emit(CounterTeamAState());
    }
  }
  
  void _updateTotalScores() {
    A = 0;
    B = 0;
    C = 0;
    D = 0;
    
    for (var row in scoreTable) {
      if (row.length >= teamNames.length) {
        for (int i = 0; i < teamNames.length; i++) {
          if (i == 0) A += row[i];
          if (i == 1) B += row[i];
          if (i == 2) C += row[i];
          if (i == 3) D += row[i];
          // For teams beyond D, they are still tracked in the teamNames list
          // but not in the A, B, C, D variables for compatibility
        }
      }
    }
  }
  
  void resetTable() {
    scoreTable.clear();
    A = 0;
    B = 0;
    C = 0;
    D = 0;
    
    // Reset team names to default values
    teamNames = ['الفريق الأول', 'الفريق الثاني', 'الفريق الثالث', 'الفريق الرابع'];
    
    emit(CounterTeamAState());
  }

  List<String> getTeamNames() {
    return teamNames;
  }
  
  void addColumn() {
    // Add a new team name
    String newTeamName = 'Team ${String.fromCharCode(65 + teamNames.length)}'; // A, B, C, D, E, etc.
    teamNames.add(newTeamName);
    
    // Add a score of 0 for this team to each existing row
    for (int i = 0; i < scoreTable.length; i++) {
      scoreTable[i].add(0);
    }
    
    // Update A, B, C, D values to include the new column if it fits in those variables
    _updateTotalScores();
    emit(CounterTeamAState());
  }
  
  void removeColumn(int index) {
    if (index >= 0 && index < teamNames.length) {
      teamNames.removeAt(index);
      
      // Remove the score for this team from each row
      for (int i = 0; i < scoreTable.length; i++) {
        if (scoreTable[i].length > index) {
          scoreTable[i].removeAt(index);
        }
      }
      
      _updateTotalScores();
      emit(CounterTeamAState());
    }
  }
  
  void resetScores() {
    resetTable();
  }
  
  String getWinner() {
    if (teamNames.isEmpty) return "لا يوجد فائز بعد";
    
    // Calculate total scores for all teams
    List<int> allTeamScores = List.filled(teamNames.length, 0);
    for (var row in scoreTable) {
      for (int i = 0; i < teamNames.length && i < row.length; i++) {
        allTeamScores[i] += row[i];
      }
    }
    
    // Find the maximum score
    int maxScore = allTeamScores.reduce((a, b) => a > b ? a : b);
    if (maxScore == 0) return "لا يوجد فائز بعد";
    
    List<String> winners = [];
    for (int i = 0; i < teamNames.length; i++) {
      if (allTeamScores[i] == maxScore) {
        winners.add(teamNames[i]);
      }
    }
    
    if (winners.length == 1) {
      return winners[0];
    } else if (winners.length > 1) {
      return winners.join('، ');
    }
    
    return "لا يوجد فائز بعد";
  }
  
  int getWinnerScore() {
    if (teamNames.isEmpty) return 0;
    
    // Calculate total scores for all teams
    List<int> allTeamScores = List.filled(teamNames.length, 0);
    for (var row in scoreTable) {
      for (int i = 0; i < teamNames.length && i < row.length; i++) {
        allTeamScores[i] += row[i];
      }
    }
    
    // Find the maximum score
    return allTeamScores.reduce((a, b) => a > b ? a : b);
  }
  
  List<Map<String, dynamic>> getAllTeams() {
    List<Map<String, dynamic>> teams = [];
    
    // Calculate total scores for all teams
    List<int> allTeamScores = List.filled(teamNames.length, 0);
    for (var row in scoreTable) {
      for (int i = 0; i < teamNames.length && i < row.length; i++) {
        allTeamScores[i] += row[i];
      }
    }
    
    for (int i = 0; i < teamNames.length; i++) {
      teams.add({
        'name': teamNames[i],
        'score': allTeamScores[i]
      });
    }
    return teams;
  }
  
  void updateTeamName(int teamIndex, String newName) {
    if (teamIndex >= 0 && teamIndex < teamNames.length) {
      teamNames[teamIndex] = newName;
      emit(CounterTeamAState());
    }
  }
  
  String getTeamName(String team) {
    int index = 0;
    switch (team) {
      case "a": index = 0; break;
      case "b": index = 1; break;
      case "c": index = 2; break;
      case "d": index = 3; break;
      default: return 'Unknown Team';
    }
    if (index < teamNames.length) {
      return teamNames[index];
    }
    return 'Unknown Team';
  }
}