import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_module/shared/cubit/states.dart';
import '../../modules/archived_tasks/archived_tasks.dart';
import '../../modules/done_tasks/done_tasks.dart';
import '../../modules/new_tasks/new_tasks.dart';

class AppCubit extends Cubit<AppStates>
{
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

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

  void changeIndex(int index){
    index = currentIndex;
    emit(AppChangeNavBarState());
  }

}