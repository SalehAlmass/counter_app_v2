import 'package:flutter/material.dart';
import 'package:counter_app/cubit/counter_cubit.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.counterCubit,
    required this.onPressed,
    required this.text,
    this.buttonColor = const Color(0xFF1976D2), // أزرق افتراضي متناغم مع الاب بار
  });

  final CounterCubit? counterCubit;
  final VoidCallback onPressed;
  final String text;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // شكل مستدير ليناسب الاب بار
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        minimumSize: const Size(100, 40),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white, // نص أبيض ليناسب الخلفية الزرقاء
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
