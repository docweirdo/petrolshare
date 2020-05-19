import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class NewEntryRoute extends StatefulWidget{

  @override
  _NewEntryRouteState createState() => _NewEntryRouteState();
}

class _NewEntryRouteState extends State<NewEntryRoute> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController _textController;

  DateTime pickedDate = DateTime.now();
  double amount;
  double price;
  double roadmeter;
  String additionalNote;

  @override
  void initState(){
    _textController = new TextEditingController(text: _formatDate(DateTime.now()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        title: Text('New Entry'),
        backgroundColor: Theme.of(context).accentColor,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            Navigator.pop(context, {
              'roadmeter': roadmeter,
              'price': price,
              'amount': amount,
              'date': pickedDate,
              'notes': additionalNote
            });
          }
        },
        heroTag: null,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 3,
                  )
                ]
              ),
              padding: EdgeInsets.fromLTRB(32, 5, 10, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.number,
                    enableInteractiveSelection: false,
                    autofocus: true,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.slow_motion_video),
                      labelText: 'Roadmeter',
                      counterText: "",
                    ),
                    validator: (value) {
                      if (value.isEmpty) return 'Required';
                      else if (!isNumeric(value)) return 'Not a number';
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (v){
                      FocusScope.of(context).nextFocus();
                    },
                    onChanged: (value) {
                      setState(() {
                        roadmeter = double.parse(value.replaceAll(',', '.'));
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    enableInteractiveSelection: false,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.local_gas_station),
                      labelText: 'Liter / KWh',
                      counterText: "",
                    ),
                    validator: (value) {
                      if (value.isEmpty) return 'Required';
                      else if (!isNumeric(value)) return 'Not a number';
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (v){
                      FocusScope.of(context).nextFocus();
                    },
                    onChanged: (value) {
                      setState(() {
                        amount = double.parse(value.replaceAll(',', '.'));
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    enableInteractiveSelection: false,
                    maxLength: 10,
                    decoration: InputDecoration(
                      icon: Icon(Icons.euro_symbol),
                      labelText: 'Price',
                      counterText: "",
                    ),
                    validator: (value) {
                      if (value.isEmpty) return 'Required';
                      else if (!isNumeric(value)) return 'Not a number';
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (v){
                      FocusScope.of(context).nextFocus();
                    },
                    onChanged: (value) {
                      setState(() {
                        price = double.parse(value.replaceAll(',', '.'));
                      });
                    },
                  ),
                ],
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                accentColor: Theme.of(context).primaryColor,
                primaryColor: Theme.of(context).accentColor,
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(32, 20, 10, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      maxLength: 50,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.description),
                        labelText: 'Additional Notes',
                      ),
                      onChanged: (value) {
                        setState(() => additionalNote = value.length > 0 ? value : null);
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      enableInteractiveSelection: false,
                      controller: _textController,
                      readOnly: true,
                      focusNode: AlwaysDisabledFocusNode(),
                      onTap: () async {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        DateTime input = await showDatePicker(
                          context: context, 
                          initialDate: DateTime.now(), 
                          firstDate: DateTime.now().subtract(Duration(days: 7)),
                          lastDate: DateTime.now());
                        if (input == null){
                          return null;
                        }
                        TimeOfDay selectedTime = await showTimePicker(
                          initialTime: TimeOfDay.now(),
                          context: context,
                          builder: (BuildContext context, Widget child){
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child,
                            );
                          }
                        );
                        if (selectedTime != null){
                          input = input.add(Duration(hours: selectedTime.hour, minutes: selectedTime.minute));
                        }
                        setState(() {
                          _textController.text = _formatDate(input);
                          pickedDate = input;
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.date_range),
                        labelText: 'Date',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        )  
      ),
    );
  }

  String _formatDate(DateTime date){
    var formatter = new DateFormat('dd.MM.yyyy - HH:mm');
    var formatterHours = new DateFormat('dd.MM.yyyy');
    if (date.hour == 0 && date.minute == 0){
      return formatterHours.format(date);
    }
    return formatter.format(date);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();  
  }

  bool isNumeric(String s) {
    
    String snew = s.replaceAll(',', '.');
    return double.tryParse(snew) != null;
  }


}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}