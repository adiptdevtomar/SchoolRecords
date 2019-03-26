import 'package:flutter/material.dart';
import 'package:school_management/screens/node_detail.dart';
import 'package:school_management/models/Record.dart';
import 'package:school_management/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {

    return NoteListState();
  }
}

class NoteListState extends State<NoteList>{

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Record> recordList;
  int count = 0;
  @override
  Widget build(BuildContext context) {

    if(recordList == null){
      recordList = List<Record>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('School Records'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            NavigateToDetail(Record('','',2),'Add Record');
          },
          tooltip: 'Add Record',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView(){
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context,int position){
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              onTap: (){
                NavigateToDetail(this.recordList[position],'Edit Record');
              },
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.recordList[position].priority),
                child: Text(getPriorityIcon(this.recordList[position].priority),textScaleFactor: 1.5,)
              ),
              title: Text(this.recordList[position].title,style: titleStyle,),
              subtitle: Text(this.recordList[position].date),
              trailing: GestureDetector(
                child:Icon(Icons.delete, color: Colors.grey),
                onTap: (){
                  _delete(context, recordList[position]);
                },
              )
            ),
          );
        }
        );
  }

  Color getPriorityColor(int priority){
    switch (priority){
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  String getPriorityIcon(int priority){
    switch(priority){
      case 1:
        return 'T';
        break;
      case 2:
        return 'S';
        break;
      default:
        return 'S';
    }
  }

  void _delete(BuildContext context,Record record) async{
    int result = await databaseHelper.deleteRecord(record.id);
    if(result != 0)
      {
        _showSnackBar(context,'Note Deleted Successfully');
        updateListView();
      }
  }

  void _showSnackBar(BuildContext context,String message) {
    final snackBar = SnackBar(content: Text(message),duration: Duration(seconds: 2),);
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void NavigateToDetail(Record record,String title) async{
      bool result = await Navigator.push(context, MaterialPageRoute(builder: (context){
        return NoteDetail(record, title);
      }));

      if(true == result) {
        updateListView();
      }
  }

  void updateListView(){

    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database){
      Future<List<Record>> recordListFuture = databaseHelper.getRecordList();
      recordListFuture.then((recordList){
        setState(() {
          this.recordList = recordList;
          this.count = recordList.length;
        });
      });
    });
  }
}