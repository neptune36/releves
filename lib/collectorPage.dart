import 'package:flutter/material.dart';
import 'package:my_monitorings/data/AggregateFunction.dart';
import 'package:my_monitorings/data/dataCollector.dart';
import 'package:my_monitorings/data/dataGrouped.dart';
import 'package:my_monitorings/data/database_helpers.dart';
import 'package:my_monitorings/data/dateOption.dart';
import 'package:my_monitorings/editDataCollector.dart';
import 'addCollection.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'LocalizedTimeFactory.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class CollectorPage extends StatefulWidget {
  final int collectorId;

  CollectorPage({this.collectorId});

  @override
  CollectorPageState createState() =>
      CollectorPageState(collectorId: collectorId);
}

class CollectorPageState extends State<CollectorPage> {
  final int collectorId;
  double test;
  DataCollector collector;
  var series;
  TextEditingController titleController;

  List<DataGrouped> groups;
  List<bool> dateOptionSelections;
  List<bool> functionOptionSelections;
  List<DateOption> options;
  List<AggregateFunction> functions;

  int dateOptionIndex = 0;
  int functionOptionIndex = 0;

  CollectorPageState({this.collectorId}) {

    options = <DateOption>[];
    options.add(DateOption.MINUTE());
    options.add(DateOption.HOUR());
    options.add(DateOption.DAY());
    options.add(DateOption.MONTH());
    options.add(DateOption.YEAR());

    dateOptionSelections = <bool>[];
    options.forEach((element) {dateOptionSelections.add(false); });

    functions = <AggregateFunction>[];
    functions.add(AggregateFunction.SUM());
    functions.add(AggregateFunction.AVG());
    functions.add(AggregateFunction.COUNT());

    functionOptionSelections = <bool>[];
    functions.forEach((element) {functionOptionSelections.add(false); });

  }

  Future<DataCollector> loadData() async {
    DatabaseHelper helper = DatabaseHelper.instance;

    collector = await helper.findCollectorById(collectorId);

    if(collector.dateOption!=null) {
      for (int buttonIndex = 0;
      buttonIndex < dateOptionSelections.length;
      buttonIndex++) {
        if (options[buttonIndex].name == collector.dateOption) {
          dateOptionIndex = buttonIndex;
          break;
        }
      }
    }
      dateOptionSelections[dateOptionIndex]=true;

    if(collector.functionOption!=null){
      for (int buttonIndex = 0;
      buttonIndex < functionOptionSelections.length;
      buttonIndex++) {
        if(functions[buttonIndex].name==collector.functionOption){
          functionOptionIndex = buttonIndex;
          break;
        }
      }
    }
    functionOptionSelections[functionOptionIndex]=true;


    groups = await helper.testDate(collectorId, options[dateOptionIndex],functions[functionOptionIndex]);
    titleController = TextEditingController(text: collector.label);

    series = [
      new charts.Series<DataGrouped, DateTime>(
        id: 'Clicks',
        domainFn: (DataGrouped dc, _) => dc.moment,
        measureFn: (DataGrouped dc, _) => dc.quantity,
        colorFn: (DataGrouped dc, _) =>
            charts.MaterialPalette.blue.shadeDefault,
        data: groups,
      ),
    ];

    return collector;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataCollector>(
        future: loadData(),
        builder: (context, AsyncSnapshot<DataCollector> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(
                  title: Text('${collector.label}'),
                  actions: [
                    Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: PopupMenuButton<int>(
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Text("Modifier")
                                  ],
                                )),
                            PopupMenuItem<int>(
                                value: 0,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Text("Suppimer")
                                  ],
                                )),
                          ],
                          onSelected: (item) => SelectedItem(context, item),
                        )
                    ),

                  ],
                ),
                body: Container(
                  padding: EdgeInsets.all(12.0),
                  //alignment: Alignment.center,
                  child: ListView(
                    children: <Widget>[
                      Text(AppLocalizations.of(context).collectorGroupDataBy),
                      LayoutBuilder(builder: (context, constraints) {
                        return ToggleButtons(
                          constraints: BoxConstraints.expand(
                              width: constraints.maxWidth / 5 - 6, height: 40),
                          borderRadius: BorderRadius.circular(5),
                          children: <Widget>[
                            Text(AppLocalizations.of(context).collectorMinute),
                            Text(AppLocalizations.of(context).collectorHour),
                            Text(AppLocalizations.of(context).collectorDay),
                            Text(AppLocalizations.of(context).collectorMonth),
                            Text(AppLocalizations.of(context).collectorYear),
                          ],
                          onPressed: (int index) {
                            changeDateOption(index);
                          },
                          isSelected: dateOptionSelections,
                        );
                      }),
                      SizedBox(
                        height: 200.0,
                        child: graph(),
                      ),
                      LayoutBuilder(builder: (context, constraints) {
                        return ToggleButtons(
                          constraints: BoxConstraints.expand(
                              width: constraints.maxWidth / 3 - 4, height: 40),
                          borderRadius: BorderRadius.circular(5),
                          children: <Widget>[
                            Text("\u2211 ${AppLocalizations.of(context).collectorSum}"),
                            Text("x̄ ${AppLocalizations.of(context).collectorAverage}"),
                            Text('x̄(\u2211)'),
                          ],
                          onPressed: (int index) {

                            changeFunctionOption(index);
                          },
                          isSelected: functionOptionSelections,
                        );
                      }),
                      table(),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddCollection(
                                  dataCollector: snapshot.data,
                                ))).then((value) => setState(() {}));
                  },
                  tooltip: AppLocalizations.of(context).collectorAddDataTooltip,
                  child: Icon(Icons.add),
                ));
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  void changeDateOption(int optionIndex){
    setState(() {
      dateOptionIndex = optionIndex;

      updateCollectorDateOption();

      for (int buttonIndex = 0;
      buttonIndex < dateOptionSelections.length;
      buttonIndex++) {
        if (buttonIndex == optionIndex) {
          dateOptionSelections[buttonIndex] = true;
        } else {
          dateOptionSelections[buttonIndex] = false;
        }
      }
    });
  }

  void changeFunctionOption(int optionIndex){
    setState(() {
      functionOptionIndex = optionIndex;

      updateCollectorDateOption();

      for (int buttonIndex = 0;
      buttonIndex < functionOptionSelections.length;
      buttonIndex++) {
        if (buttonIndex == optionIndex) {
          functionOptionSelections[buttonIndex] = true;
        } else {
          functionOptionSelections[buttonIndex] = false;
        }
      }
    });
  }

  void updateCollectorDateOption() async{
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.updateCollectorOptions(collectorId, options[dateOptionIndex], functions[functionOptionIndex]);
  }

  void askForDelete() {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
          title: new Text(AppLocalizations.of(context).collectorDeleteMessageTitle),
          content: new Text(AppLocalizations.of(context).collectorDeleteMessageBody),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).commonsNo),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                DatabaseHelper helper = DatabaseHelper.instance;
                helper.deleteCollector(collector.id);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text(AppLocalizations.of(context).commonsYes),
            ),
          ]),
    );
  }

  Widget graph() {
    return new charts.TimeSeriesChart(series, animate: true, dateTimeFactory: new LocalizedTimeFactory(Localizations.localeOf(context)));
  }

  Widget table() {
    DateFormat df = DateFormat(options[dateOptionIndex].sdfOut,Localizations.localeOf(context).languageCode);

    DataTable table = DataTable(
      showCheckboxColumn: false,
      //defaultColumnWidth: FixedColumnWidth(120.0),
      columns: [
        DataColumn(label: Text(AppLocalizations.of(context).commonsDate)),
        DataColumn(label: Text(AppLocalizations.of(context).commonsQuantity)),
      ],
      rows: [],
    );

    groups.reversed.forEach((element) {
      table.rows.add(
        DataRow(cells: [
          DataCell(
            Text('${df.format(element.moment)}'),
          ),
          DataCell(Text('${element.quantity} ${collector.unit}')),
        ],
            //onSelectChanged:(v){askFor(true);}
        ),
      );
    });
    return table;
  }

  void askFor(bool t) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
          title: new Text(AppLocalizations.of(context).collectorDeleteMessageTitle),
          content: new Text(AppLocalizations.of(context).collectorDeleteMessageBody),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).commonsNo),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                DatabaseHelper helper = DatabaseHelper.instance;
                helper.deleteCollector(collector.id);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text(AppLocalizations.of(context).commonsYes),
            ),
          ]),
    );
  }

  void SelectedItem(BuildContext context, item) {
    switch (item) {
      case 0:
        askForDelete();
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditDataCollector(
                  dataCollector: collector,
                ))).then((value) => setState(() {}));
        break;

    }
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Renommer le suivi'),
            content: TextField(
              onChanged: (value) {

              },
              controller: titleController,
              //decoration: InputDecoration(hintText: "Renommer le suivi"),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                 // editCollectorLabel();
                  Navigator.of(context).pop();
                },
                child: Text("Ok"),
              ),


            ],
          );
        });
  }
}
