import 'package:counter_app/cubit/counter_cubit.dart';
import 'package:counter_app/cubit/counter_state.dart';
import 'package:counter_app/widgets/CustomAppbar.dart';
import 'package:counter_app/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PointsCounterScreen extends StatefulWidget {
  PointsCounterScreen({super.key});

  @override
  State<PointsCounterScreen> createState() => _PointsCounterScreenState();
}

class _PointsCounterScreenState extends State<PointsCounterScreen> {
  bool showWinner = false; // لتحديد ظهور الفائز

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CounterCubit, CounterState>(
      builder: (context, state) {
        final counterCubit = context.read<CounterCubit>();
        String winner = counterCubit.getWinner();
        int winnerScore = counterCubit.getWinnerScore();
        List<String> teamNames = counterCubit.getTeamNames();

        return Scaffold(
          appBar: CustomAppbar(
            initialDuration: const Duration(minutes: 2),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // الجدول يشغل كل المساحة المتاحة
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width),
                          child: Column(
                            children: [
                              // رأس الجدول
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'السؤال',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    for (int i = 0; i < teamNames.length; i++)
                                      Container(
                                        width: 120,
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                teamNames[i],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 16,
                                                color: Colors.black54,
                                              ),
                                              onPressed: () {
                                                _showTeamNameChangeDialog(
                                                    context, counterCubit, i, teamNames[i]);
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints.tightFor(
                                                width: 24,
                                                height: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Container(
                                      width: 80,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'إجراءات',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // الصفوف
                              Expanded(
                                child: counterCubit.scoreTable.isEmpty
                                    ? Center(
                                        child: Text(
                                          'لم تتم إضافة أسئلة بعد. انقر على "إضافة صف" للبدء.',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Column(
                                          children: [
                                            for (int index = 0; index < counterCubit.scoreTable.length; index++)
                                              SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 80,
                                                      alignment: Alignment.center,
                                                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                                                      child: Text('${index + 1}',
                                                          style: const TextStyle(fontSize: 16),
                                                          textAlign: TextAlign.center),
                                                    ),
                                                    for (int i = 0; i < teamNames.length; i++)
                                                      Container(
                                                        width: 120,
                                                        alignment: Alignment.center,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(Icons.remove, size: 16),
                                                              onPressed: () {
                                                                List<int> row = counterCubit.scoreTable[index];
                                                                if (row.length > i && row[i] > 0) {
                                                                  counterCubit.updateScore(index, i, row[i] - 1);
                                                                }
                                                              },
                                                              padding: EdgeInsets.zero,
                                                              constraints: const BoxConstraints.tightFor(
                                                                width: 30,
                                                                height: 30,
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 30,
                                                              alignment: Alignment.center,
                                                              child: Text(
                                                                '${counterCubit.scoreTable[index].length > i ? counterCubit.scoreTable[index][i] : 0}',
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(Icons.add, size: 16),
                                                              onPressed: () {
                                                                List<int> row = counterCubit.scoreTable[index];
                                                                if (row.length > i) {
                                                                  counterCubit.updateScore(index, i, row[i] + 1);
                                                                }
                                                              },
                                                              padding: EdgeInsets.zero,
                                                              constraints: const BoxConstraints.tightFor(
                                                                width: 30,
                                                                height: 30,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    Container(
                                                      width: 80,
                                                      alignment: Alignment.center,
                                                      child: IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                                                        onPressed: () {
                                                          counterCubit.removeRow(index);
                                                        },
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints.tightFor(
                                                          width: 30,
                                                          height: 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            // صف المجموع
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 80,
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                                    child: const Text(
                                                      'المجموع',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  for (int i = 0; i < teamNames.length; i++)
                                                    Container(
                                                      width: 120,
                                                      alignment: Alignment.center,
                                                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                                                      child: Text(
                                                        '${_getTeamTotalScore(i)}',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  Container(
                                                    width: 80,
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                                    child: const Text(''),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // أزرار التحكم
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: [
                        CustomButton(
                          counterCubit: counterCubit,
                          onPressed: () => counterCubit.addRow(),
                          text: 'إضافة صف',
                          buttonColor: Colors.green,
                        ),
                        CustomButton(
                          counterCubit: counterCubit,
                          onPressed: () => counterCubit.addColumn(),
                          text: 'إضافة عمود',
                          buttonColor: Colors.blue,
                        ),
                        CustomButton(
                          counterCubit: counterCubit,
                          onPressed: () => counterCubit.resetTable(),
                          text: 'إعادة تعيين الكل',
                          buttonColor: Colors.red,
                        ),
                        CustomButton(
                          onPressed: () {
                            setState(() {
                              showWinner = true;
                            });
                          },
                          text: 'عرض النتائج',
                          buttonColor: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Overlay الفائز
              if (showWinner)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => showWinner = false),
                    child: Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrangeAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              winner.isEmpty ? "لا توجد فرق" : "الفائز: $winner",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$winnerScore نقطة',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => setState(() => showWinner = false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text("إغلاق"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      listener: (context, state) {},
    );
  }

  void _showTeamNameChangeDialog(BuildContext context, CounterCubit counterCubit, int index, String currentName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _controller = TextEditingController(text: currentName);

        return AlertDialog(
          title: const Text('تغيير اسم الفريق'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'اسم الفريق'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حفظ'),
              onPressed: () {
                counterCubit.updateTeamName(index, _controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  int _getTeamTotalScore(int teamIndex) {
    final counterCubit = context.read<CounterCubit>();
    int totalScore = 0;

    for (List<int> row in counterCubit.scoreTable) {
      if (row.length > teamIndex) {
        totalScore += row[teamIndex];
      }
    }

    return totalScore;
  }
}
