import 'package:counter_app/cubit/counter_cubit.dart';
import 'package:counter_app/database/database_helper.dart';
import 'package:counter_app/screens/SplashScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Only initialize database on mobile platforms (not web)
  if (!kIsWeb) {
    try {
      await DatabaseHelper().database; // Initialize the database
    } catch (e) {
      // Handle database initialization error gracefully
      print('Database initialization failed: $e');
    }
  }
  
  runApp(const PointsCounterApp());
}

class PointsCounterApp extends StatelessWidget {
  const PointsCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        theme: ThemeData(
          fontFamily: 'Arial',
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}