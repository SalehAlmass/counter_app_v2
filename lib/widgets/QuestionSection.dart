import 'package:counter_app/models/question_model.dart';
import 'package:counter_app/utils/app_constants.dart';
import 'package:flutter/material.dart';

class QuestionSection extends StatefulWidget {
  final Function(String selectedOption) onOptionSelected;
  final Function() onNextQuestion;
  final Function() onPreviousQuestion;
  final int currentQuestionIndex;
  final int totalQuestions;
  final Question? currentQuestion;
  final int timeRemaining;
  final bool showCorrectAnswerOnly;
  final bool isTimeExpired;
  final Function()? onTimerTap;
  final String? categoryName;


  const QuestionSection({
    super.key,
    required this.onOptionSelected,
    required this.onNextQuestion,
    required this.onPreviousQuestion,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    this.currentQuestion,
    this.timeRemaining = 30,
    this.showCorrectAnswerOnly = false,
    this.isTimeExpired = false,
    this.onTimerTap,
    this.categoryName
  });

  @override
  State<QuestionSection> createState() => _QuestionSectionState();
}

class _QuestionSectionState extends State<QuestionSection> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    final question = widget.currentQuestion;

    if (question == null) {
      return const Center(
        child: Text(
          'لا يوجد سؤال لعرضه',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          /// ===== Header =====
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2196F3),
                  Color(0xFF1565C0),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.currentQuestionIndex + 1}/${widget.totalQuestions}',
                  style: const TextStyle(color: Colors.white70),
                ),

                /// اسم القسم
                Text(
                  "${widget.categoryName}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                /// Timer
                InkWell(
                  onTap: widget.onTimerTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.isTimeExpired
                          ? Colors.red
                          : widget.timeRemaining < 10
                              ? Colors.red.withValues(alpha: 0.7)
                              : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.isTimeExpired
                          ? 'انتهى الوقت'
                          : '${widget.timeRemaining} ث',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ===== Content (Scrollable) =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  /// السؤال
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      question.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// الخيارات
                  Column(
                    children: question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;

                      return _buildOption(
                        option: option,
                        isCorrect: index == question.correctAnswerIndex,
                        isSelected: selectedOption == option,
                        showCorrectOnly: widget.showCorrectAnswerOnly,
                        isDisabled: widget.isTimeExpired ||
                            widget.showCorrectAnswerOnly,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          /// ===== Navigation =====
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.currentQuestionIndex > 0
                      ? widget.onPreviousQuestion
                      : null,
                  child: const Text('السابق'),
                ),
                ElevatedButton(
                  onPressed: widget.isTimeExpired || selectedOption != null
                      ? widget.onNextQuestion
                      : null,
                  child:
                      Text(widget.isTimeExpired ? 'متابعة' : 'التالي'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String option,
    required bool isCorrect,
    required bool isSelected,
    required bool showCorrectOnly,
    required bool isDisabled,
  }) {
    Color color = Colors.grey[50]!;
    Color border = Colors.grey[300]!;
    IconData icon = Icons.radio_button_unchecked;

    if (showCorrectOnly && isCorrect) {
      color = Colors.green[100]!;
      border = Colors.green;
      icon = Icons.check_circle;
    } else if (isSelected) {
      color = Colors.blue[100]!;
      border = Colors.blue;
      icon = Icons.radio_button_checked;
    }

    return AbsorbPointer(
      absorbing: isDisabled,
      child: GestureDetector(
        onTap: () {
          setState(() => selectedOption = option);
          widget.onOptionSelected(option);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(icon, color: border),
              const SizedBox(width: 12),
              Expanded(child: Text(option)),
            ],
          ),
        ),
      ),
    );
  }
}
