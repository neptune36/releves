import 'dataCollection.dart';

class DataCollector{

  static String tableName = "collectors";
  static String columnId = 'id';
  static String columnLabel = 'label';
  static String columnUnit = 'unit';
  static String columnDateOption = 'dateOption';
  static String columnFunctionOption = 'functionOption';

  int id;
  String label;
  String unit;
  String dateOption;
  String functionOption;

  List<DataCollection> collections;

  DataCollector();

  DataCollector.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    label = map[columnLabel];
    unit = map[columnUnit];
    dateOption = map[columnDateOption];
    functionOption = map[columnFunctionOption];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnLabel: label,
      columnUnit: unit,
      columnDateOption: dateOption,
      columnFunctionOption: functionOption
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}