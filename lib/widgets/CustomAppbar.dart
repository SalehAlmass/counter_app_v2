import 'dart:async';
import 'package:counter_app/screens/CategorySelectionScreen.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  final Duration initialDuration;

  const CustomAppbar({Key? key, required this.initialDuration})
    : super(key: key);

  @override
  State<CustomAppbar> createState() => _CustomAppbarState();

  // ارتفاع الأب بار مرن
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);
}

class _CustomAppbarState extends State<CustomAppbar>
    with SingleTickerProviderStateMixin {
  late Duration remainingTime;
  Timer? _timer;
  late AnimationController _animController;
  bool isRunning = false; // حالة المؤقت

  @override
  void initState() {
    super.initState();
    remainingTime = widget.initialDuration;

    // Animation controller للوقت الأخير
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
          lowerBound: 1.0,
          upperBound: 1.3,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _animController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _animController.forward();
          }
        });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void startTimer() {
    if (isRunning) return;
    isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime -= const Duration(seconds: 1);
        });

        // آخر 10 ثواني يظهر التأثير فقط
        if (remainingTime.inSeconds <= 10) {
          _animController.forward();
        }
      } else {
        timer.cancel();
        _animController.stop();
        isRunning = false;
      }
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      remainingTime = widget.initialDuration;
      isRunning = false;
    });
    _animController.stop();
  }

  String formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
   // bool lastTen = remainingTime.inSeconds <= 10;

    return AppBar(
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CategorySelectionScreen()));
      }),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2196F3), // أزرق متوسط
              Color(0xFF1565C0), // أزرق غامق
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.emoji_events, color: Colors.white, size: 24),
            SizedBox(width: 6),
            Text(
              'مسابقة حلقتي',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
