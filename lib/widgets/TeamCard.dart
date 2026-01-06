import 'package:counter_app/cubit/counter_cubit.dart';
import 'package:counter_app/widgets/CustomButton.dart';
import 'package:flutter/material.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.teamName,
    required this.teamColor,
    required this.score,
    required this.onAddOne,
    required this.onAddTwo,
    required this.onAddThree,
    required this.counterCubit,
    required this.teamId, // Add teamId parameter
  });

  final String teamName;
  final Color teamColor;
  final int score;
  final VoidCallback onAddOne;
  final VoidCallback onAddTwo;
  final VoidCallback onAddThree;
  final CounterCubit counterCubit;
  final String teamId; // Team identifier ('a', 'b', 'c', or 'd')

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Team name with color indicator and edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: teamColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: teamColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        
                        Expanded(
                          child: Text(
                            teamName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: teamColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: teamColor, size: 20),
                  onPressed: () {
                    _showNameChangeDialog(context);
                  },
                ),
              ],
            ),
            // Score display with large number
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: teamColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: teamColor,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Action buttons
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      counterCubit: counterCubit,
                      onPressed: onAddOne,
                      text: '+1',
                      buttonColor: teamColor,
                    ),
                    SizedBox(width: 10),
                    CustomButton(
                      counterCubit: counterCubit,
                      onPressed: onAddTwo,
                      text: '+2',
                      buttonColor: teamColor,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                CustomButton(
                  counterCubit: counterCubit,
                  onPressed: onAddThree,
                  text: '-1',
                  buttonColor: teamColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNameChangeDialog(BuildContext context) {
    TextEditingController controller = TextEditingController(text: teamName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Team Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter new team name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  String newTeamName = controller.text.trim();
                  int teamIndex = _getTeamIndex(teamId);
                  if (teamIndex != -1) {
                    counterCubit.updateTeamName(teamIndex, newTeamName);
                  }
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: teamColor),
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  
  int _getTeamIndex(String teamId) {
    switch (teamId) {
      case "a": return 0;
      case "b": return 1;
      case "c": return 2;
      case "d": return 3;
      default: return -1;
    }
  }
}
