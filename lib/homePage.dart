import 'package:flutter/material.dart';
import 'data/dataCollector.dart';
import 'data/database_helpers.dart';
import 'editDataCollector.dart';
import 'collectorPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<DataCollector>>(
      future: loadData(),
      builder: (context,AsyncSnapshot<List<DataCollector>> snapshot){
        if(snapshot.hasData){


          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).homePageTitle),
            ),
            body:

                new Scaffold(
                  body: snapshot.data.isEmpty ? Text(AppLocalizations.of(context).homePageNoCollectors):

            buildCollectorsList(snapshot.data)) ,
            floatingActionButton: FloatingActionButton(
              onPressed: navigateToAddCollector,
              tooltip: AppLocalizations.of(context).homePageAddCollectorTooltip,
              child: Icon(Icons.add),
            ),
          );
        }else{
          return CircularProgressIndicator();
        }
    }
    );

  }

  Future<List<DataCollector>> loadData() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    List<DataCollector> data = await helper.findAllCollectors();
    return data;
  }

  Widget buildCollectorsList(List<DataCollector> dataCollectors) {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: dataCollectors.length,
        itemBuilder: (context, i) {
          return _buildRow(dataCollectors[i]);
        });
  }

  Widget _buildRow(DataCollector dataCollector) {
    return ListTile(
      title: Text(
        '${dataCollector.label} (${dataCollector.unit})',
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CollectorPage(
              collectorId: dataCollector.id,
                )),
      ).then((value) => setState(() {})),
    );
  }

  void navigateToAddCollector() {
    Navigator.push(context,
        MaterialPageRoute(
        builder: (context) => EditDataCollector(
      dataCollector: null,
    )))
        .then((value) => setState(() {}));
  }
}
