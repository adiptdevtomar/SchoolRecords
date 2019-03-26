import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:school_management/models/Record.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String recordTable = 'record_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async{
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'Records.db';

    var RecordDatabase = await openDatabase(path, version: 1,onCreate: _createDb);
    return RecordDatabase;
  }

  void _createDb(Database db, int newVersion) async {

    await db.execute(
        'CREATE TABLE $recordTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle text,$colDescription TEXT,$colPriority INTEGER,$colDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getRecordMapList() async{
    Database db = await this.database;

    var result = await db.rawQuery('SELECT * FROM $recordTable order by $colPriority ASC');
    return result;
  }

  Future<int> insertRecord(Record record) async {
    Database db = await this.database;
    var result = await db.insert(recordTable,record.toMap());
    return result;
  }

  Future<int> updateRecord(Record record) async {
    var db = await this.database;
    int result = await db.update(recordTable, record.toMap(),where: '$colId = ?',whereArgs: [record.id]);
    return result;
  }

  Future<int> deleteRecord(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $recordTable WHERE $colId = $id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String,dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $recordTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Record>> getRecordList() async{
    var recordMapList = await getRecordMapList();
    int count = recordMapList.length;

    List<Record> recordlist = List<Record>();

    for(int i=0; i<count ; i++)
      {
        recordlist.add(Record.fromMapObject(recordMapList[i]));
      }

    return recordlist;
  }
}
