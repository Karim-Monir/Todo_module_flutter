import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:todo_module/modules/archived_tasks/archived_tasks.dart';
import 'package:todo_module/modules/done_tasks/done_tasks.dart';
import 'package:todo_module/shared/components/components.dart';
import 'package:todo_module/modules/new_tasks/new_tasks.dart';
import '../shared/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';



class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {


  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  bool isButtomSheetShown = false;
  IconData fabIcon = Icons.edit;
  int currentIndex = 0;
  late Database db;


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



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(titles[currentIndex]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isButtomSheetShown) {
            if (_formKey.currentState!.validate()) {
              insertToDatabase(
                      title: titleController.text,
                      date: dateController.text,
                      time: timeController.text
              )
                  .then((value) {
                getDataFromDatabase(db).then((value){
                  Navigator.pop(context);
                  setState(() {
                    isButtomSheetShown = false;
                    fabIcon = Icons.edit;
                    tasks = value;
                  });
                });
              });
            }
          } else {
            _scaffoldKey.currentState
                ?.showBottomSheet(
                  (context) => Container(
                    padding: EdgeInsets.all(20.0),
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
                          SizedBox(
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
                          SizedBox(
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
              setState(() {
                fabIcon = Icons.edit;
              });
            });

            isButtomSheetShown = true;
            setState(() {
              fabIcon = Icons.add;
            });
          }
        },
        child: Icon(fabIcon),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //backgroundColor: Colors.blue,
        //elevation: 25.0,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
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
        condition: tasks.isNotEmpty,
        builder: (context) => screens[currentIndex],
        fallback: (context) => Center(child: CircularProgressIndicator()),
      ),
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
      getDataFromDatabase(db).then((value){
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
