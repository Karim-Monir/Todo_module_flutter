import 'package:flutter/material.dart';
import 'package:todo_module/shared/components/components.dart';
import '../../shared/components/constants.dart';

class NewTasksScreen extends StatelessWidget {
  const NewTasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated
      (
        itemBuilder: (context, index) => buildTaskItem(tasks[index]),
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 20.0,
          ) ,
          child: Container(
            height: 1.0,
            color: Colors.grey[300],
            width: double.infinity,
          ),
        ),
        itemCount: tasks.length,
    );
  }
}
