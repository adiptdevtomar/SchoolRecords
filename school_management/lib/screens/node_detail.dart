import 'package:flutter/material.dart';
import 'dart:async';
import 'package:school_management/models/Record.dart';
import 'package:school_management/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Record record;

  NoteDetail(this.record, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.record, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();

  var _formkey = GlobalKey<FormState>();
  String appBarTitle;
  Record record;

  NoteDetailState(this.record, this.appBarTitle);

  static var _priorities = ['Teacher', 'Student'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = record.title;
    descriptionController.text = record.description;

    return WillPopScope(
        onWillPop: () {
          MoveToLastScreen();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    MoveToLastScreen();
                  }),
            ),
            body: Form(
              key: _formkey,
                child: Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: DropdownButton(
                        items: _priorities.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(dropDownStringItem),
                          );
                        }).toList(),
                        style: textStyle,
                        value: getPriorityAsString(record.priority),
                        onChanged: (valueSelectedByUser) {
                          setState(() {
                            updatePriorityAsInt(valueSelectedByUser);
                          });
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextFormField(
                      controller: titleController,
                      style: textStyle,
                      validator: (String value){
                        if(value.isEmpty)
                          {
                            return 'Please Enter Title';
                          }
                        else{
                          updateTitle();
                        }
                      },
                      decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextFormField(
                      controller: descriptionController,
                      style: textStyle,
                      validator: (String value){
                        if(value.isEmpty)
                          {
                            return 'Please enter description';
                          }
                        else{
                        updateDescription();}
                      },
                      decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text('Save', textScaleFactor: 1.5),
                          onPressed: () {
                            setState(() {
                              if(_formkey.currentState.validate()) {
                                _save();
                              }
                            });
                          },
                        )),
                        Container(
                          width: 5.0,
                        ),
                        Expanded(
                            child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text('Delete', textScaleFactor: 1.5),
                          onPressed: () {
                            setState(() {
                              _delete();
                            });
                          },
                        ))
                      ],
                    ),
                  )
                ],
              ),
            ))));
  }

  void MoveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'Teacher':
        record.priority = 1;
        break;
      case 'Student':
        record.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle() {
    record.title = titleController.text;
  }

  void updateDescription() {
    record.description = descriptionController.text;
  }

  void _delete() async {
    int result;
    MoveToLastScreen();
    if (record.id != null) {
      result = await helper.deleteRecord(record.id);
    } else {
      _showAlertDialog('Status', 'No Record was Deleted');
      return;
    }
    if (result != 0) {
      _showAlertDialog('Status', 'Record Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Problem Deleting Record');
    }
  }

  void _save() async {
    int result;
    MoveToLastScreen();
    record.date = DateFormat.yMMMd().format(DateTime.now());
    if (record.id != null) {
      result = await helper.updateRecord(record);
    } else {
      result = await helper.insertRecord(record);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Record Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Problem Saving Record');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
