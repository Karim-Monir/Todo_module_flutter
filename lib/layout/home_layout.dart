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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDataBase(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (BuildContext context, AppStates state) {
            if(state is AppInsertToDatabaseState){
              Navigator.pop(context);
            }
          },
          builder: (BuildContext context, AppStates state) {
            AppCubit cubit = AppCubit.get(context);
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(cubit.titles[cubit.currentIndex]),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (cubit.isButtomSheetShown) {
                    if (_formKey.currentState!.validate()) {
                      cubit.insertToDatabase(
                          title: titleController.text,
                          date: dateController.text,
                          time: timeController.text);

                      /*insertToDatabase(
                              title: titleController.text,
                              date: dateController.text,
                              time: timeController.text)
                          .then((value) {
                        getDataFromDatabase(db).then((value) {
                          Navigator.pop(context);
                          */ /*setState(() {
                        isButtomSheetShown = false;
                        fabIcon = Icons.edit;
                        tasks = value;
                      });*/ /*
                        });
                      });*/
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
                      cubit.changeBottomSheetState(
                        isShow: false,
                        icon: Icons.edit,
                      );
                      // Navigator.pop(context);
                    });

                    cubit.changeBottomSheetState(
                      isShow: true,
                      icon: Icons.add,
                    );
                    /*setState(() {
                  fabIcon = Icons.add;
                });*/
                  }
                },
                child: Icon(cubit.fabIcon),
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
                condition: state is! AppGetDatabaseLoadingState,
                builder: (context) => cubit.screens[cubit.currentIndex],
                fallback: (context) =>
                    Center(child: CircularProgressIndicator()),
              ),
            );
          }),
    );
  }
}
