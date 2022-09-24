import 'dart:io';
import 'package:my_monitorings/data/AggregateFunction.dart';

import 'dataCollection.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dataCollector.dart';
import 'dataGrouped.dart';
import 'dateOption.dart';
import 'package:intl/intl.dart';

// singleton class to manage the database
class DatabaseHelper {



  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "MyDatabase10.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
    );
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {

    await db.execute('''
              CREATE TABLE ${DataCollector.tableName}  (
                ${DataCollector.columnId} INTEGER PRIMARY KEY,
                ${DataCollector.columnLabel} TEXT NOT NULL,
                ${DataCollector.columnUnit} TEXT NOT NULL,
                ${DataCollector.columnDateOption} TEXT, 
                ${DataCollector.columnFunctionOption} TEXT 
              )
              ''');
    await db.execute('''
              CREATE TABLE ${DataCollection.tableName}  (
                ${DataCollection.columnId} INTEGER PRIMARY KEY,
                ${DataCollection.columnQuantity} REAL NOT NULL,
                ${DataCollection.columnCollectorId} INTEGER NOT NULL,
                 ${DataCollection.columnMoment} TEXT NOT NULL
              )
              ''');

  }

  // Database helper methods:

  Future<int> createCollector(DataCollector dataCollector) async {
    print('Try to create new dataCollector...');
    Database db = await database;
    int id = await db.insert(DataCollector.tableName, dataCollector.toMap());
    print('OK');
    return id;
  }

  Future<DataCollector> findCollectorById(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(DataCollector.tableName,
        columns: [DataCollector.columnId, DataCollector.columnLabel, DataCollector.columnUnit,DataCollector.columnDateOption,DataCollector.columnFunctionOption],
        where: '${DataCollector.columnId} = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return DataCollector.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DataCollector>> findAllCollectors() async {
    Database db = await database;
    List<DataCollector> collectors = <DataCollector>[];
    List<Map> result = await db.query(DataCollector.tableName);
    result.forEach((row)=>collectors.add(DataCollector.fromMap(row)));

    return collectors;
  }

  Future<int> deleteCollector(int id) async {
    Database db = await database;
    print('try to delete dataCollector $id...');
    int r = await db.delete(DataCollector.tableName, where: '${DataCollector.columnId} = ?', whereArgs: [id]);
    await db.delete(DataCollection.tableName,where: '${DataCollection.columnCollectorId} = ?',whereArgs: [id]);
    print(r==0?'KO':'OK');
    return r;
  }

  Future editCollector(int collectorId, String label,String unit) async{
    Database db = await database;
    Map<String,dynamic> values = {DataCollector.columnLabel:label,DataCollector.columnUnit:unit};
    await db.update(DataCollector.tableName,values,where: '${DataCollector.columnId} = ?',whereArgs: [collectorId]);
  }

  Future updateCollectorOptions(int collectorId, DateOption dateOption, AggregateFunction functionOption) async{
    Database db = await database;
    Map<String,dynamic> values = {DataCollector.columnFunctionOption:functionOption.name,DataCollector.columnDateOption:dateOption.name};
    await db.update(DataCollector.tableName,values,where: '${DataCollector.columnId} = ?',whereArgs: [collectorId]);
  }

  Future<int> createCollection(DataCollection dataCollection) async {
    print('Try to create new dataCollection...');
    Database db = await database;
    int id = await db.insert(DataCollection.tableName, dataCollection.toMap());
    print('OK');
    return id;
  }

  Future<List<DataCollection>> findAllCollectionsByCollectorId(int collectorId) async {
    Database db = await database;
    List<DataCollection> collections = <DataCollection>[];
    List<Map> result = await db.query(DataCollection.tableName,where: '${DataCollection.columnCollectorId} = ?',whereArgs: [collectorId]);
    result.forEach((row)=>collections.add(DataCollection.fromMap(row)));

    return collections;
  }

  Future<List<DataGrouped>> testDate(int collectorId,DateOption dateOption, AggregateFunction function) async {
    Database db = await database;
    List<DataGrouped> groups = <DataGrouped>[];
    DateFormat sdfOut =DateFormat(dateOption.sdfIn);

    List<Map> result;
    if(function.name=='COUNT'){
      String query = "select a.moment, avg(a.quantity) as quantity from ("
          "select strftime('${dateOption.sql}',c.moment) as moment, sum(c.quantity) as quantity from collections c where c.collectorId=$collectorId group by strftime('${dateOption.sql}',c.moment)"
          ")a group by a.moment";
      result = await db.rawQuery(query);
    }else{
      result = await db.rawQuery("select strftime('${dateOption.sql}',c.moment) as moment, ${function.sql}(c.quantity) as quantity from collections c where c.collectorId=$collectorId group by strftime('${dateOption.sql}',c.moment)");
    }


//   );

    result.forEach((row)=>
    groups.add(DataGrouped.fromMap(row,sdfOut)));

    return groups;
  }

  Future<double> getAverage(int collectorId) async {

    Database db = await database;
    List<Map<String,dynamic>> a = await db.rawQuery('select avg(d.quantity) as avg from collections d where d.collectorId=$collectorId;');
    if(a.isNotEmpty){
      Map<String,dynamic> d = a[0];

      var e = d['avg'];
      double s = e as double;

      return s;
    }
    return 0;
  }



}