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
  final Function()? onTimerTap; // Add timer tap callback

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
    this.onTimerTap, // Add timer tap parameter
  });

  @override
  State<QuestionSection> createState() => _QuestionSectionState();
}

class _QuestionSectionState extends State<QuestionSection> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    // Use provided question or fallback to sample data
    String questionText =
        widget.currentQuestion?.question ??
        'هذا هو نص السؤال الذي سيتم عرضه هنا. يمكن أن يكون السؤال طويلاً ويحتوي على عدة أسطر.';

    List<String> options =
        widget.currentQuestion?.options ??
        ['الخيار الأول', 'الخيار الثاني', 'الخيار الثالث', 'الخيار الرابع'];

    int correctAnswerIndex = widget.currentQuestion?.correctAnswerIndex ?? 0;

    return Container(
      //padding: const EdgeInsets.all(16.0),
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
        // mainAxisSize: MainAxisSize.min,
        children: [
          // Question header with timer
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
               colors: [
              Color(0xFF2196F3), // أزرق متوسط
              Color(0xFF1565C0), // أزرق غامق
            ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                Text(
                  '${widget.currentQuestionIndex + 1}/${widget.totalQuestions}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                
               
                SizedBox(width: 12),
                Text(
                  'الأسئلة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
            
                 
                if (!widget.isTimeExpired && widget.timeRemaining > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.timeRemaining < 10
                          ? Colors.red.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: widget.onTimerTap,
                      child: Text(
                        '${widget.timeRemaining} ثانية',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else if (widget.isTimeExpired) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'انتهى الوقت',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Question text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Options with correct answer highlighting
          Column(
            children: options.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              return _buildOption(
                option: option,
                optionIndex: index,
                isCorrect: index == correctAnswerIndex,
                isSelected: selectedOption == option,
                showCorrectOnly: widget.showCorrectAnswerOnly,
                isDisabled:
                    widget.isTimeExpired || widget.showCorrectAnswerOnly,
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: widget.currentQuestionIndex > 0
                    ? widget.onPreviousQuestion
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('السابق'),
              ),
              if (!widget.isTimeExpired)
                ElevatedButton(
                  onPressed: selectedOption != null
                      ? widget.onNextQuestion
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('التالي'),
                )
              else
                ElevatedButton(
                  onPressed: widget.onNextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('متابعة'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String option,
    required int optionIndex,
    required bool isCorrect,
    required bool isSelected,
    required bool showCorrectOnly,
    required bool isDisabled,
  }) {
    bool showAsCorrect = showCorrectOnly && isCorrect;
    bool showAsSelected = isSelected && !showCorrectOnly;
    bool showNormal = !showAsCorrect && !showAsSelected;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    if (showAsCorrect) {
      backgroundColor = Colors.green[100]!;
      borderColor = Colors.green;
      textColor = Colors.green[800]!;
      icon = Icons.check_circle;
    } else if (showAsSelected) {
      backgroundColor = Colors.blue[100]!;
      borderColor = Colors.blue;
      textColor = Colors.blue[800]!;
      icon = Icons.radio_button_checked;
    } else if (showNormal) {
      backgroundColor = Colors.grey[50]!;
      borderColor = Colors.grey[300]!;
      textColor = Colors.black87;
      icon = Icons.radio_button_unchecked;
    } else {
      // Disabled state
      backgroundColor = Colors.grey[100]!;
      borderColor = Colors.grey[300]!;
      textColor = Colors.grey[500]!;
      icon = isCorrect ? Icons.check : Icons.radio_button_unchecked;
    }

    return AbsorbPointer(
      absorbing: isDisabled,
      child: GestureDetector(
        onTap: () {
          if (!isDisabled) {
            setState(() {
              selectedOption = option;
            });
            widget.onOptionSelected(option);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: showAsCorrect || showAsSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: borderColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: showAsCorrect || showAsSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ),
              if (showAsCorrect)
                const Icon(Icons.emoji_events, color: Colors.green, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
