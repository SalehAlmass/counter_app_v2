import 'package:counter_app/cubit/counter_cubit.dart';
import 'package:counter_app/utils/app_constants.dart';
import 'package:flutter/material.dart';

class ResultsTableWidget extends StatefulWidget {
  final CounterCubit counterCubit;
  final List<String> teamNames;
  final VoidCallback onResetTable;
  final int Function(int teamIndex) getTotalScore;
  final VoidCallback onShowWinner;

  const ResultsTableWidget({
    super.key,
    required this.counterCubit,
    required this.teamNames,
    required this.onResetTable,
    required this.getTotalScore,
    required this.onShowWinner,
  });

  @override
  State<ResultsTableWidget> createState() => _ResultsTableWidgetState();
}

class _ResultsTableWidgetState extends State<ResultsTableWidget> {
  bool showTotal = true;

  @override
  Widget build(BuildContext context) {
    final cubit = widget.counterCubit;
    final teams = widget.teamNames;

    final bool isEmpty = cubit.scoreTable.isEmpty;
    final int rowCount = isEmpty ? 1 : cubit.scoreTable.length;

    return SizedBox.expand(
      child: Container(
        decoration: _cardDecoration(),
        child: Column(
          children: [
            _buildHeader(),
            _buildControls(context),
            Expanded(
              child: Column(
                children: [
                  _tableHeader(teams),
                  Expanded(
                    child: ListView.builder(
                      itemCount: rowCount,
                      itemBuilder: (context, index) {
                        return _row(
                          cubit: cubit,
                          teams: teams,
                          index: index,
                          isPreview: isEmpty,
                        );
                      },
                    ),
                  ),
                  if (showTotal) _totalRow(cubit, teams, isEmpty),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI PARTS =================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.08),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.DEFAULT_PADDING),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.scoreboard, color: Colors.white),
          SizedBox(width: 12),
          Text(
            "النتائج",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: AppConstants.HEADING_TEXT_SIZE,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= CONTROLS =================
  Widget _buildControls(BuildContext context) {
    final cubit = widget.counterCubit;
    final teams = widget.teamNames;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.DEFAULT_PADDING),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _btn(
            showTotal ? "إخفاء المجموع" : "إظهار المجموع",
            Colors.grey,
            () => setState(() => showTotal = !showTotal),
          ),
          _btn("حذف عمود", Colors.orange, () {
            if (teams.length <= 2) {
              _showAlert(context, "لا يمكن أن يقل عدد الأعمدة عن 2");
              return;
            }
            // حذف آخر عمود
            cubit.removeColumn(teams.length - 1);
          }),

          _btn("إضافة عمود", Colors.blue, () {
            if (teams.length >= 8) {
              _showAlert(context, "لا يمكن إضافة أكثر من 8 أعمدة");
              return;
            }
            cubit.addColumn();
          }),
          _btn("عرض الفائز", Colors.deepOrange, () {
            if (cubit.getWinner().isEmpty) {
              _showAlert(context, "لا يوجد فائز حتى الآن");
              return;
            }
            widget.onShowWinner();
          }),
          _btn("إعادة تعيين", Colors.red, widget.onResetTable),
        ],
      ),
    );
  }

  Widget _btn(String text, Color color, VoidCallback onTap) {
  return StatefulBuilder(
    builder: (context, setState) {
      bool _isPressed = false;
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: Text(text),
          ),
        ),
      );
    },
  );
}


  /// ================= TABLE =================

  Widget _tableHeader(List<String> teams) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _cell("السؤال", flex: 1, bold: true),
          for (final team in teams) _cell(team, flex: 2, bold: true),
          _cell("إجراءات", flex: 1, bold: true),
        ],
      ),
    );
  }

  Widget _row({
    required CounterCubit cubit,
    required List<String> teams,
    required int index,
    required bool isPreview,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _cell("${index + 1}", flex: 1),
          for (int i = 0; i < teams.length; i++)
            _scoreCell(cubit, index, i, isPreview),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  tooltip: "إضافة صف",
                  onPressed: () => cubit.addRow(),
                ),
                if (!isPreview)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: "حذف الصف",
                    onPressed: () => cubit.removeRow(index),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreCell(CounterCubit cubit, int row, int col, bool isPreview) {
    return Expanded(
      flex: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: isPreview
                ? null
                : () {
                    if (cubit.scoreTable[row][col] > 0) {
                      cubit.updateScore(
                        row,
                        col,
                        cubit.scoreTable[row][col] - 1,
                      );
                    }
                  },
          ),
          Text(
            isPreview ? "0" : "${cubit.scoreTable[row][col]}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: isPreview
                ? null
                : () {
                    cubit.updateScore(row, col, cubit.scoreTable[row][col] + 1);
                  },
          ),
        ],
      ),
    );
  }

  Widget _totalRow(CounterCubit cubit, List<String> teams, bool isEmpty) {
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _cell("المجموع", flex: 1, bold: true),
          for (int i = 0; i < teams.length; i++)
            _cell(
              isEmpty ? "0" : "${widget.getTotalScore(i)}",
              flex: 2,
              bold: true,
            ),
          const Expanded(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _cell(String text, {required int flex, bool bold = false}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================

  void _showAlert(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }
}
