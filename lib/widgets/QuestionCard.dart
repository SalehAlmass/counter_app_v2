import 'package:counter_app/cubit/counter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuestionCard extends StatelessWidget {
  final int index;
  final List<int> scores;
  final List<String> teamNames;

  const QuestionCard({
    required this.index,
    required this.scores,
    required this.teamNames,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CounterCubit>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// Question Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => cubit.removeRow(index),
                ),
              ],
            ),
            const Divider(),
            /// Teams Scores
            for (int i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      teamNames[i],
                      style: const TextStyle(fontSize: 15),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: scores[i] > 0
                              ? () => cubit.updateScore(
                                    index,
                                    i,
                                    scores[i] - 1,
                                  )
                              : null,
                        ),
                        Text(
                          '${scores[i]}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => cubit.updateScore(
                            index,
                            i,
                            scores[i] + 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
