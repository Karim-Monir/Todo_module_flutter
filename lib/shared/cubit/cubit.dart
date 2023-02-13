import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo_module/shared/cubit/states.dart';

import '../../modules/archived_tasks/archived_tasks.dart';
import '../../modules/done_tasks/done_tasks.dart';
import '../../modules/new_tasks/new_tasks.dart';

class AppCubit extends Cubit<AppStates>
{
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => context.read<AppCubit>();

  int currentIndex = 0;

  List<Widget> screens =
  [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen()
  ];

  List<String> titles =
  [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks'
  ];

  void ChangeIndex(int index){
    index = currentIndex;
    emit(AppChangeNavBarState());
  }

}