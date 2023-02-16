import 'package:flutter/material.dart';

import '../cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpperCase = true,
  double radius = 0.0,
  required void Function()? function,
  required String text,
}) =>
    Container(
      width: width,
      height: 40.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: background,
      ),
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );

Widget defaultTextFormField({
  required TextEditingController controller,
  required TextInputType type,
  required String? Function(String?) validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  bool isPassword = false,
  void Function(String)? onSubmit,
  void Function(String)? onChange,
  void Function()? suffixPressed,
  void Function()? onTap,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type, //phone in case of numbers field
      obscureText: isPassword,
      onFieldSubmitted: onSubmit, //to catch the value after pressing the correct mark on keyboard
      onChanged: onChange, //catches the value with every single input
      validator: validate,
      onTap: onTap ,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: suffix != null
            ? IconButton(onPressed: suffixPressed, icon: Icon(suffix))
            : null,
        border: OutlineInputBorder(),
      ),
    );


Widget buildTaskItem(Map model, context) => Padding(
  padding: const EdgeInsets.all(20.0),
  child: Row(
    children: [
      CircleAvatar(
        radius: 40.0,
        child: Text(
          '${model['time']}',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 18.0,
          ),
        ),

      ),
      SizedBox(
        width: 20.0,
      ),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
        '${model['title']}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text
              (
                '${model['date']}',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: 20.0,
      ),
      IconButton(
          onPressed: ()
          {
            AppCubit.get(context).updateDatabase(status: 'done', id: model['id']);
          },
          icon: Icon(
            Icons.check_box,
            color: Colors.green,
          )
      ),
      IconButton(
          onPressed: ()
          {
            AppCubit.get(context).updateDatabase(status: 'archived', id: model['id']);
          },
          icon: Icon(
            Icons.archive,
            color: Colors.black45,
          )
      ),
    ],
  ),
);