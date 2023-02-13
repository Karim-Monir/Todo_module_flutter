import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo_module/layout/home_layout.dart';
import 'package:todo_module/shared/bloc_observer.dart';

void main()
{
  Bloc.observer = MyBlocObserver();
  runApp(TodoModule());
}


class TodoModule extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeLayout(),
    );
  }
}