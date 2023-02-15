import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:todo_module/shared/components/components.dart';
import 'package:todo_module/shared/cubit/cubit.dart';
import '../shared/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:todo_module/shared/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../modules/archived_tasks/archived_tasks.dart';
import '../../modules/done_tasks/done_tasks.dart';
import '../../modules/new_tasks/new_tasks.dart';

class HomeLayout extends StatelessWidget {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  bool isButtomSheetShown = false;
  IconData fabIcon = Icons.edit;
  late Database db;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (BuildContext context, AppStates state) {},
          builder: (BuildContext context, AppStates state) {
            AppCubit cubit = AppCubit.get(context);
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(cubit.titles[cubit.currentIndex]),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (isButtomSheetShown) {
                    if (_formKey.currentState!.validate()) {
                      insertToDatabase(
                              title: titleController.text,
                              date: dateController.text,
                              time: timeController.text)
                          .then((value) {
                        getDataFromDatabase(db).then((value) {
                          Navigator.pop(context);
                          /*setState(() {
                        isButtomSheetShown = false;
                        fabIcon = Icons.edit;
                        tasks = value;
                      });*/
                        });
                      });
                    }
                  } else {
                    _scaffoldKey.currentState
                        ?.showBottomSheet(
                          (context) => Container(
                            padding: const EdgeInsets.all(20.0),
                            color: Colors.white,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultTextFormField(
                                    controller: titleController,
                                    type: TextInputType.text,
                                    validate: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Title cannot be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task name',
                                    prefix: Icons.title,
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultTextFormField(
                                      controller: timeController,
                                      type: TextInputType.datetime,
                                      validate: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Time cannot be empty';
                                        }
                                        return null;
                                      },
                                      label: 'Task time',
                                      prefix: Icons.watch_later_outlined,
                                      onTap: () {
                                        showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        ).then((value) {
                                          timeController.text =
                                              value!.format(context).toString();
                                        });
                                      }),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultTextFormField(
                                    controller: dateController,
                                    type: TextInputType.datetime,
                                    validate: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Date cannot be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Date',
                                    prefix: Icons.calendar_today,
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse('2024-12-31'),
                                      ).then((value) {
                                        // print(DateFormat.yMMMd().format(value!));
                                        dateController.text =
                                            DateFormat.yMMMd().format(value!);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          elevation: 20.0,
                        )
                        .closed
                        .then((value) {
                      // Navigator.pop(context);
                      isButtomSheetShown = false;
                      /* setState(() {
                    fabIcon = Icons.edit;
                  });*/
                    });

                    isButtomSheetShown = true;
                    /*setState(() {
                  fabIcon = Icons.add;
                });*/
                  }
                },
                child: Icon(fabIcon),
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                //backgroundColor: Colors.blue,
                //elevation: 25.0,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
                  print(index);
                  /*setState(() {
                currentIndex = index;
              });*/
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.menu_outlined,
                    ),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    label: 'Done',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive_outlined,
                    ),
                    label: 'Archived',
                  ),
                ],
              ),
              body: ConditionalBuilder(
                condition: true,
                builder: (context) => cubit.screens[cubit.currentIndex],
                fallback: (context) =>
                    Center(child: CircularProgressIndicator()),
              ),
            );
          }),
    );
  }

  void createDataBase() async {
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
      getDataFromDatabase(db).then((value) {
        tasks = value;
        print(tasks);
      });
      print('database opened');
    });
  }

// could be just void (?) -- Amr
  Future insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await db.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        print('$value INSERTED SUCCESSFULLY');
      });
      //throw 'ERROR WHILE INSERTING NEW RECORD';
      //return 0;
    });
  }

  Future<List<Map>> getDataFromDatabase(db) async {
    return await db.rawQuery('SELECT * FROM tasks');
  }
}
