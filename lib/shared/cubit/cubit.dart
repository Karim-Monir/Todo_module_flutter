import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_module/shared/cubit/states.dart';
import '../../modules/archived_tasks/archived_tasks.dart';
import '../../modules/done_tasks/done_tasks.dart';
import '../../modules/new_tasks/new_tasks.dart';

class AppCubit extends Cubit<AppStates>
{
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  late Database db;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

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
    currentIndex = index;
    emit(AppChangeNavBarState());
  }


  Future<Database?> createDataBase() async {
    db = await openDatabase('todo.db', version: 1, onCreate: (db, version) {
      db
          .execute(
          'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT )')
          .then((value) {
        print('table created');
      }).catchError((error) {
        print('Error while crating the database ${error.toString()}');
      });

      print('database created');
    }, onOpen: (db) {
      getDataFromDatabase(db);
      print('database opened');
    }).then((value){
      db = value;
      emit(AppCreateDatabaseState());
      return db;
    }
    );
  }



// could be just void (?) -- Amr
  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await db.transaction((txn) {
      return txn.rawInsert(
          'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        print('$value INSERTED SUCCESSFULLY');
        emit(AppInsertToDatabaseState());
        getDataFromDatabase(db).then((value) {
          emit(AppGetDatabaseState());
        });
      });
      //throw 'ERROR WHILE INSERTING NEW RECORD';
      //return 0;
    });
  }

  getDataFromDatabase(db) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

     db.rawQuery('SELECT * FROM tasks').then((value) {
      emit(AppGetDatabaseLoadingState());
      value.forEach((element)
      {
        if(element['status'] == 'new'){
          newTasks.add(element);
        } else if (element['status'] == 'done'){
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }


  bool isButtomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState ({
    required bool isShow,
    required IconData icon
})
  {
    isButtomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }


  void updateDatabase
      ({
    required String status,
    required int id,
  })
  {
     db.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?', ['$status', '$id']).then((value){
       getDataFromDatabase(db);
       emit(AppUpdateDatabaseLoadingState());
     });
  }
}