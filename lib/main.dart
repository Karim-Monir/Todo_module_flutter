import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_module/layout/home_layout.dart';
import 'package:todo_module/shared/bloc_observer.dart';
import 'package:todo_module/shared/cubit/cubit.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(TodoModule());
}

class TodoModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => AppCubit(),
        child: HomeLayout(),
      ),
    );
  }
}
