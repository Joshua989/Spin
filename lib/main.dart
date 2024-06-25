import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spin/bloc/main_cubit/main_cubit.dart';
import 'package:spin/bloc/spin_cubit/spin_cubit.dart';
import 'package:spin/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SpinCubit>(
          create: (context) => SpinCubit(),
        ),
        BlocProvider<MainCubit>(
          create: (context) => MainCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Spin Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          primaryColor: Colors.red,
          useMaterial3: false,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
