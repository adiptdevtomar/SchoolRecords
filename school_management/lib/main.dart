import "package:flutter/material.dart";
import 'package:school_management/screens/node_detail.dart';
import 'package:school_management/screens/node_list.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.deepPurple
      ),
      home: NoteList(),
    );
  }
}