import 'package:flutter/material.dart';
import 'package:my_monitorings/data/dataCollector.dart';
import 'package:my_monitorings/data/database_helpers.dart';
import 'homePage.dart';
import 'package:my_monitorings/data/dataCollection.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _random = new Random();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: createSamples(context),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
              theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.blue,
              ),
              home: MyHomePage(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Future<bool> createSamples(BuildContext context) async {
    final String prefSampleKey = "samples_created";

    /*SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(prefSampleKey)) {
      DatabaseHelper helper = DatabaseHelper.instance;
      DataCollector weight = new DataCollector();
      weight.label = AppLocalizations.of(context).sampleWeight;
      weight.unit = "kg";
      weight.dateOption = "DAY";
      weight.functionOption = "AVG";
      int weightId = await helper.createCollector(weight);
      for (int i = 1; i < 30; i++) {
        DataCollection collection = new DataCollection();
        collection.collectorId = weightId;
        collection.quantity = next(70, 80).toDouble();
        collection.moment = DateFormat("dd/MM/yyyy").parse("$i/01/2021");
        await helper.createCollection(collection);
      }
      prefs.setBool(prefSampleKey, true);
    }*/

    return true;
  }

  int next(int min, int max) => min + _random.nextInt(max - min);
}
