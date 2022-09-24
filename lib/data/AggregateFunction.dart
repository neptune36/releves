class AggregateFunction{
  String name;
  String sql;

  AggregateFunction({this.name,this.sql});

  static AggregateFunction SUM()=>AggregateFunction(name:'SUM', sql: 'sum');
  static AggregateFunction AVG()=>AggregateFunction(name:'AVG',sql: 'avg');
  static AggregateFunction COUNT()=>AggregateFunction(name:'COUNT',sql: 'count');

  static getByName(String name){
    switch(name){
      case 'SUM':return SUM();
      case 'AVG':return AVG();
      case 'COUNT':return COUNT();
    }
  }
}