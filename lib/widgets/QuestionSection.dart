import 'package:counter_app/models/question_model.dart';
import 'package:counter_app/utils/app_constants.dart';
import 'package:flutter/material.dart';

class QuestionSection extends StatefulWidget {
  final Function(String selectedOption) onOptionSelected;
  final VoidCallback onNextQuestion;
  final VoidCallback onPreviousQuestion;
  final int currentQuestionIndex;
  final int totalQuestions;
  final Question? currentQuestion;

  final int timeRemaining;
  final bool showCorrectAnswerOnly;
  final bool isTimeExpired;
  final VoidCallback? onTimerTap;

  final bool isTimerRunning;
  final VoidCallback? onStartPause;
  final VoidCallback? onResetTimer;

  final int? totalTimeTotalSeconds;
  final int? totalTimeRemainingSeconds;

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
    this.isTimerRunning = false,
    this.onStartPause,
    this.onResetTimer,
    this.totalTimeTotalSeconds,
    this.totalTimeRemainingSeconds,
  });

  @override
  State<QuestionSection> createState() => _QuestionSectionState();
}

class _QuestionSectionState extends State<QuestionSection> {
  String? selectedOption;

  String _formatSeconds(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    String two(int n) => n.toString().padLeft(2, '0');
    if (hours > 0) return '${two(hours)}:${two(minutes)}:${two(seconds)}';
    return '${two(minutes)}:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.currentQuestion;
    if (question == null) {
      return const Center(child: Text('لا يوجد سؤال لعرضه', style: TextStyle(fontSize: 18)));
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
          // ===== Header =====
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1565C0)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // سطر علوي مرن بدون overflow
                Row(
                  children: [
                    Text(
                      '${widget.currentQuestionIndex + 1}/${widget.totalQuestions}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        question.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ✅ Wrap بدل Row: يمنع overflow
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    IconButton(
                      tooltip: widget.isTimerRunning ? 'إيقاف مؤقت' : 'ابدأ',
                      onPressed: widget.onStartPause,
                      icon: Icon(
                        widget.isTimerRunning ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      tooltip: 'إعادة التوقيت',
                      onPressed: widget.onResetTimer,
                      icon: const Icon(Icons.replay_circle_filled, color: Colors.white),
                    ),
                    InkWell(
                      onTap: widget.onTimerTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.isTimeExpired
                              ? Colors.red
                              : widget.timeRemaining < 10
                                  ? Colors.red.withValues(alpha: 0.7)
                                  : Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.isTimeExpired ? 'انتهى الوقت' : '${widget.timeRemaining} ث',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),

                if (widget.totalTimeTotalSeconds != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        'الوقت الكلي: ${_formatSeconds(widget.totalTimeTotalSeconds!)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      if (widget.totalTimeRemainingSeconds != null)
                        Text(
                          'المتبقي تقريبًا: ${_formatSeconds(widget.totalTimeRemainingSeconds!)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ===== Content =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      return _buildOption(
                        option: option,
                        isCorrect: index == question.correctAnswerIndex,
                        isSelected: selectedOption == option,
                        showCorrectOnly: widget.showCorrectAnswerOnly,
                        isDisabled: widget.isTimeExpired || widget.showCorrectAnswerOnly,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // ===== Navigation =====
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.currentQuestionIndex > 0 ? widget.onPreviousQuestion : null,
                  child: const Text('السابق'),
                ),
                ElevatedButton(
                  onPressed: widget.isTimeExpired || selectedOption != null ? widget.onNextQuestion : null,
                  child: Text(widget.isTimeExpired ? 'متابعة' : 'التالي'),
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
