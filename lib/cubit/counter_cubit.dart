import 'package:counter_app/cubit/counter_state.dart';
import 'package:counter_app/utils/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterTeamAState());
  
  // Team scores (maintained for backward compatibility)
  int A = 0;
  int B = 0;
  int C = 0;
  int D = 0;
  
  // Team names list instead of individual variables
  List<String> teamNames = AppConstants.DEFAULT_TEAM_NAMES;
  
  // Table data: List of rows, each row contains scores for all teams
  List<List<int>> scoreTable = [];

  /// Adds or subtracts points from a team
  void addcounterA({required String Team, required int number}) {
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

  // MARK: - Table Management Methods
  
  /// Adds a new row to the score table
  void addRow() {
    List<int> newRow = List.filled(teamNames.length, 0);
    scoreTable.add(newRow);
    _updateTotalScores();
    emit(CounterTeamAState());
  }
  
  /// Removes a row from the score table
  void removeRow(int index) {
    if (_isValidRowIndex(index)) {
      scoreTable.removeAt(index);
      _updateTotalScores();
      emit(CounterTeamAState());
    }
  }
  
  /// Updates a specific score in the table
  void updateScore(int rowIndex, int teamIndex, int score) {
    if (_isValidCell(rowIndex, teamIndex)) {
      scoreTable[rowIndex][teamIndex] = score < 0 ? 0 : score;
      _updateTotalScores();
      emit(CounterTeamAState());
    }
  }
  
  /// Resets the entire table and scores
  void resetTable() {
    scoreTable.clear();
    A = 0;
    B = 0;
    C = 0;
    D = 0;
    teamNames = List.from(AppConstants.DEFAULT_TEAM_NAMES);
    emit(CounterTeamAState());
  }

  // MARK: - Team Management Methods
  
  /// Gets the list of team names
  List<String> getTeamNames() => teamNames;
  
  /// Adds a new team column
  void addColumn() {
    String newTeamName = 'Team ${String.fromCharCode(65 + teamNames.length)}';
    teamNames.add(newTeamName);
    
    // Add score of 0 for new team to each existing row
    for (int i = 0; i < scoreTable.length; i++) {
      scoreTable[i].add(0);
    }
    
    _updateTotalScores();
    emit(CounterTeamAState());
  }
  
  /// Removes a team column
  void removeColumn(int index) {
    if (_isValidTeamIndex(index)) {
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
  
  /// Updates a team's name
  void updateTeamName(int teamIndex, String newName) {
    if (_isValidTeamIndex(teamIndex) && newName.trim().isNotEmpty) {
      teamNames[teamIndex] = newName.trim();
      emit(CounterTeamAState());
    }
  }
  
  /// Gets a team's name by team identifier
  String getTeamName(String team) {
    int index = _getTeamIndexById(team);
    return index != -1 && index < teamNames.length 
        ? teamNames[index] 
        : 'Unknown Team';
  }

  // MARK: - Winner Calculation Methods
  
  /// Determines the current winner(s)
  String getWinner() {
    if (teamNames.isEmpty) return "لا يوجد فائز بعد";
    
    List<int> allTeamScores = _calculateAllTeamScores();
    int maxScore = _findMaxScore(allTeamScores);
    
    if (maxScore == 0) return "لا يوجد فائز بعد";
    
    List<String> winners = _findWinners(allTeamScores, maxScore);
    
    return _formatWinnerDisplay(winners);
  }
  
  /// Gets the highest score
  int getWinnerScore() {
    if (teamNames.isEmpty) return 0;
    List<int> allTeamScores = _calculateAllTeamScores();
    return _findMaxScore(allTeamScores);
  }
  
  /// Gets all teams with their scores
  List<Map<String, dynamic>> getAllTeams() {
    List<Map<String, dynamic>> teams = [];
    List<int> allTeamScores = _calculateAllTeamScores();
    
    for (int i = 0; i < teamNames.length; i++) {
      teams.add({
        'name': teamNames[i],
        'score': allTeamScores[i]
      });
    }
    return teams;
  }

  // MARK: - Private Helper Methods
  
  /// Calculates total scores for all teams
  List<int> _calculateAllTeamScores() {
    List<int> allTeamScores = List.filled(teamNames.length, 0);
    for (var row in scoreTable) {
      for (int i = 0; i < teamNames.length && i < row.length; i++) {
        allTeamScores[i] += row[i];
      }
    }
    return allTeamScores;
  }
  
  /// Updates the legacy A, B, C, D score variables
  void _updateTotalScores() {
    A = 0; B = 0; C = 0; D = 0;
    
    for (var row in scoreTable) {
      if (row.length >= teamNames.length) {
        for (int i = 0; i < teamNames.length; i++) {
          switch (i) {
            case 0: A += row[i]; break;
            case 1: B += row[i]; break;
            case 2: C += row[i]; break;
            case 3: D += row[i]; break;
          }
        }
      }
    }
  }
  
  /// Finds the maximum score from a list of scores
  int _findMaxScore(List<int> scores) {
    return scores.reduce((a, b) => a > b ? a : b);
  }
  
  /// Finds all teams with the winning score
  List<String> _findWinners(List<int> scores, int maxScore) {
    List<String> winners = [];
    for (int i = 0; i < teamNames.length; i++) {
      if (scores[i] == maxScore) {
        winners.add(teamNames[i]);
      }
    }
    return winners;
  }
  
  /// Formats the winner display string
  String _formatWinnerDisplay(List<String> winners) {
    if (winners.length == 1) {
      return winners[0];
    } else if (winners.length > 1) {
      return winners.join('، ');
    }
    return "لا يوجد فائز بعد";
  }
  
  /// Gets team index by team ID
  int _getTeamIndexById(String teamId) {
    switch (teamId) {
      case "a": return 0;
      case "b": return 1;
      case "c": return 2;
      case "d": return 3;
      default: return -1;
    }
  }
  
  /// Validates row index
  bool _isValidRowIndex(int index) {
    return index >= 0 && index < scoreTable.length;
  }
  
  /// Validates team index
  bool _isValidTeamIndex(int index) {
    return index >= 0 && index < teamNames.length;
  }
  
  /// Validates table cell coordinates
  bool _isValidCell(int rowIndex, int teamIndex) {
    return _isValidRowIndex(rowIndex) && 
           _isValidTeamIndex(teamIndex) &&
           teamIndex < scoreTable[rowIndex].length;
  }
}