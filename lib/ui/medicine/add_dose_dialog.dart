import 'package:flutter/material.dart';
import 'package:lek_bierz/main.dart';
import 'package:lek_bierz/ui/common/time.dart';

class AddDoseDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final String initialSideEffects;

  const AddDoseDialog({Key key, this.initialDateTime, this.initialSideEffects})
      : super(key: key);

  @override
  State createState() => _AddDoseDialogState();

  bool _initialsPresent() =>
      initialDateTime != null || initialSideEffects != null;
}

class _AddDoseDialogState extends State<AddDoseDialog> {
  TimeOfDay time;
  DateTime date;
  TextEditingController sideEffectsController;

  @override
  void initState() {
    super.initState();
    time = widget.initialDateTime != null
        ? TimeOfDay(
            hour: widget.initialDateTime.hour,
            minute: widget.initialDateTime.minute)
        : TimeOfDay.now();
    date = widget.initialDateTime != null
        ? DateTime(widget.initialDateTime.year, widget.initialDateTime.month,
            widget.initialDateTime.day)
        : dateFromDateTime(DateTime.now());
    sideEffectsController = TextEditingController()
      ..text = widget.initialSideEffects;
  }

  @override
  void dispose() {
    sideEffectsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget._initialsPresent() ? 'Edytuj dawkę' : 'Dodaj dawkę'),
      contentPadding: const EdgeInsets.only(top: 8.0),
      content: SingleChildScrollView(
          child: ListBody(children: [
        _buildDatePicker(context),
        _buildTimePicker(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: TextField(
            controller: sideEffectsController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
                hintText: 'Skutki uboczne (o ile jakieś)'),
          ),
        )
      ])),
      actions: [
        FlatButton(
          child: Text(
            'ANULUJ',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text(widget._initialsPresent() ? 'ZAPISZ' : 'DODAJ',
              style: TextStyle(color: Theme.of(context).primaryColor)),
          onPressed: () => this._popResult(context),
        )
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Data'),
        subtitle: Text(displayDate(date.millisecondsSinceEpoch)),
        onTap: () => this._handleGettingDate(context));
  }

  Widget _buildTimePicker(BuildContext context) {
    return ListTile(
        leading: const Icon(Icons.access_time),
        title: const Text('Czas'),
        subtitle: Text(displayTime(DateTime(0)
            .add(Duration(hours: time.hour, minutes: time.minute))
            .millisecondsSinceEpoch)),
        onTap: () => this._handleGettingTime(context));
  }

  void _handleGettingDate(BuildContext context) async {
    DateTime newDate = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2010),
        lastDate: DateTime(2100));

    if (newDate != null) {
      setState(() {
        date = newDate;
      });
    }
  }

  void _handleGettingTime(BuildContext context) async {
    TimeOfDay newTime =
        await showTimePicker(context: context, initialTime: time);

    if (newTime != null) {
      setState(() {
        time = newTime;
      });
    }
  }

  void _popResult(BuildContext context) {
    final result = AddDoseDialogResult(
        date.add(Duration(hours: time.hour, minutes: time.minute)),
        sideEffectsController.text);

    Navigator.of(context).pop(result);
  }
}

class AddDoseDialogResult {
  final DateTime dateTime;
  final String sideEffects;

  const AddDoseDialogResult(this.dateTime, this.sideEffects);
}
