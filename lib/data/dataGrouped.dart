import 'package:intl/intl.dart';

class DataGrouped{

  DateTime moment;
  double quantity;

  DataGrouped.fromMap(Map<String, dynamic> map,DateFormat df) {
    moment = df.parse(map['moment']);
    var tmp = map['quantity'];
    if(tmp is int){
      quantity = tmp.toDouble();
    }else{
      quantity = tmp;
    }

  }

}