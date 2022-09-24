import 'package:intl/intl.dart';

class DataCollection{

  static String tableName = "collections";

  int id;
  double quantity;
  int collectorId;
  DateTime moment;

  static String columnId = 'id';
  static String columnQuantity = 'quantity';
  static String columnCollectorId = 'collectorId';
  static String columnMoment = 'moment';
  static DateFormat sdfOut =DateFormat("dd/MM/yyyy HH:mm");
  static DateFormat sdfIn =DateFormat("yyyy-MM-dd HH:mm:ss");
  
  DataCollection();

  DataCollection.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    quantity = map[columnQuantity];
    collectorId = map[collectorId];
    moment = sdfIn.parse(map[columnMoment]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnQuantity: quantity,
      columnCollectorId: collectorId,
      columnMoment: sdfIn.format(moment)
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}