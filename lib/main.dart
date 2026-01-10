import 'package:counter_app/cubit/counter_cubit.dart';
import 'package:counter_app/database/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:counter_app/screens/SplashScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set API usage to true since we're using MySQL
  DatabaseHelper.useApi = true;
  
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