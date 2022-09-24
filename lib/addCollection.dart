import 'package:flutter/material.dart';
import 'data/dataCollection.dart';
import 'data/dataCollector.dart';
import 'data/database_helpers.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddCollection extends StatefulWidget {
  final DataCollector dataCollector;

  AddCollection({this.dataCollector});

  @override
  NewCollectionFormState createState() =>
      NewCollectionFormState(dataCollector: this.dataCollector);
}

class NewCollectionFormState extends State<AddCollection> {
  final DataCollector dataCollector;
  final _formKey = GlobalKey<FormState>();

  final quantityController = TextEditingController();
  final dateController = TextEditingController();

  NewCollectionFormState({this.dataCollector});

  @override
  Widget build(BuildContext context) {

    dateController.text = '${DataCollection.sdfOut.format(DateTime.now())}';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addDataCollectionTitle),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  validateForm();
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

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            datetimePicker(),
            TextFormField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).addDataCollectionFormQuantity,
                filled: true,
                isDense: true,
              ),
              controller: quantityController,
              keyboardType: TextInputType.number,
              autocorrect: false,
              validator: (val) => validateRequired(val, AppLocalizations.of(context).addDataCollectionFormQuantity),
            ),
            SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }

  String validateRequired(String val, fieldName) {
    if (val == null || val == '') {
      return "$fieldName ${AppLocalizations.of(context).formRequiredField}";
    }
    return null;
  }

  String validateDateRequired(DateTime val, fieldName) {
    if (val == null) {
      return "$fieldName ${AppLocalizations.of(context).formRequiredField}";
    }
    return null;
  }

  void validateForm() {
    // Get form state from the global key
    var formState = _formKey.currentState;

    // check if form is valid
    if (formState.validate()) {

      DataCollection dataCollection = DataCollection();
      dataCollection.quantity = double.parse(quantityController.text);
      dataCollection.moment = DataCollection.sdfOut.parse(dateController.text);
      dataCollection.collectorId = this.dataCollector.id;

      DatabaseHelper helper = DatabaseHelper.instance;
      helper.createCollection(dataCollection);
      Navigator.pop(context);
    } else {
      // show validation errors
      // setState forces our [State] to rebuild
      setState(() {});
    }
  }

  Widget datetimePicker() {
    return DateTimeField(
      controller: dateController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addDataCollectionFormDate,
        filled: true,
        isDense: true,
      ),
      validator: (value) => validateDateRequired(value, AppLocalizations.of(context).addDataCollectionFormDate),
      format: DataCollection.sdfOut,
      initialValue: DateTime.now(),
      onShowPicker: (context, currentValue) async {
        final date = await showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(2100));
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          return DateTimeField.combine(date, time);
        } else {
          return currentValue;
        }
      },
    );
  }
}
