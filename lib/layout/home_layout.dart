import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_module/modules/archived_tasks/archived_tasks.dart';
import 'package:todo_module/modules/done_tasks/done_tasks.dart';
import 'package:todo_module/modules/new_tasks/new_tasks.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int currentIndex = 0;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen()
  ];

  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  late Database db;

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
          _scaffoldKey.currentState?.showBottomSheet((context) => Container());
        },
        child: Icon(Icons.add),
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
      body: screens[currentIndex],
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
      print('database opened');
    });
  }

// could be just void (?) -- Amr
  void insertToDatabase() async {
    await db.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("first task", "02222", "xdfsd", "done")')
          .then((value) {
        print('$value INSERTED SUCCESSFULLY');
      }).catchError((error) {
        print('ERROR WHILE INSERTING NEW RECORD ${error.toString()}');
      });
      // return null;
    });
  }
}
