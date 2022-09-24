class DateOption{

   String name;
   String sdfIn;
   String sdfOut;
   String sql;

   DateOption({this.name,this.sdfIn,this.sdfOut,this.sql});

  static DateOption MINUTE()=> new DateOption(name:'MINUTE',sdfIn:'yyyy-MM-dd HH:mm',sdfOut: "dd/MM/yyyy HH:mm", sql:'%Y-%m-%d %H:%M');
  static DateOption DAY()=> new DateOption(name:'DAY',sdfIn:'yyyy-MM-dd',sdfOut: 'dd/MM/yyyy', sql:'%Y-%m-%d');
  static DateOption HOUR()=> new DateOption(name:'HOUR',sdfIn:'yyyy-MM-dd HH',sdfOut: "dd/MM/yyyy HH'h'", sql:'%Y-%m-%d %H');
  static DateOption MONTH()=> new DateOption(name:'MONTH',sdfIn:'yyyy-MM',sdfOut: 'MMMM yyyy', sql:'%Y-%m');
  static DateOption YEAR()=> new DateOption(name:'YEAR',sdfIn:'yyyy',sdfOut: 'yyyy', sql:'%Y');

  static getByName(String name){
    switch(name){
      case 'MINUTE':return MINUTE();
      case 'DAY':return DAY();
      case 'HOUR':return HOUR();
      case 'MONTH':return MONTH();
      case 'YEAR':return YEAR();
    }
  }
}