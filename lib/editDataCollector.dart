import 'package:flutter/material.dart';
import 'data/dataCollection.dart';
import 'data/dataCollector.dart';
import 'data/database_helpers.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditDataCollector extends StatefulWidget {
  final DataCollector dataCollector;

  EditDataCollector({this.dataCollector});

  @override
  EditCollectorFormState createState() =>
      EditCollectorFormState(dataCollector: this.dataCollector);
}

class EditCollectorFormState extends State<EditDataCollector> {
  final DataCollector dataCollector;
  final _formKey = GlobalKey<FormState>();

  final labelController = TextEditingController();
  final unitController = TextEditingController();

  EditCollectorFormState({this.dataCollector});

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    labelController.dispose();
    unitController.dispose();
    super.dispose();
  }

  Widget buildForm() {

    if(dataCollector!=null){
      labelController.text=dataCollector.label;
      unitController.text=dataCollector.unit;
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).addDataMonitoringFormLabel,
                filled: true,
                isDense: true,
              ),
              controller: labelController,
              keyboardType: TextInputType.text,
              autocorrect: false,
              validator: (val) => validateRequired(val, AppLocalizations.of(context).addDataMonitoringFormLabel),
            ),
            SizedBox(
              height: 12,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).addDataMonitoringFormUnit,
                filled: true,
                isDense: true,
              ),
              controller: unitController,
              validator: (val) => validateRequired(val, AppLocalizations.of(context).addDataMonitoringFormUnit),
            ),
            const SizedBox(
              height: 16,
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dataCollector==null ? AppLocalizations.of(context).addDataMonitoringTitle : 'Modifier le suivi'),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  validateFormAndLogin();
                },
                child: Icon(
                  Icons.check,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: buildForm(),
      ),
    );
  }

  String validateRequired(String val, fieldName) {
    if (val == null || val == '') {
      return "$fieldName ${AppLocalizations.of(context).formRequiredField}";
    }
    return null;
  }

  void validateFormAndLogin() {
    // Get form state from the global key
    var formState = _formKey.currentState;

    // check if form is valid
    if (formState.validate()) {

      DataCollector toSave = dataCollector;

      if(toSave==null){
        toSave = new DataCollector();
      }

      toSave.label = labelController.text;
      toSave.unit = unitController.text;
      DatabaseHelper helper = DatabaseHelper.instance;

      if(toSave.id==null){
        print('new data collector');
        helper.createCollector(toSave);
      }else{
        helper.editCollector(toSave.id, toSave.label, toSave.unit);
      }

      Navigator.pop(context);

    } else {
      // show validation errors
      // setState forces our [State] to rebuild
      setState(() {

      });
    }
  }
}
