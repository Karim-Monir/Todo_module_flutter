import 'package:flutter/material.dart';
import 'package:todo_module/layout/home_layout.dart';

void main()
{
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