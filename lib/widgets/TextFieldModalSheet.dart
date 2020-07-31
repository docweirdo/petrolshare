import 'package:flutter/material.dart';

class TextFieldModalSheet extends StatelessWidget {
  final String title;
  final String confirmLabel;
  final Function callback;
  final int maxLength;
  final String initialText;
  final _formFieldKey;

  TextFieldModalSheet(
      {@required this.title,
      @required this.confirmLabel,
      @required this.callback,
      this.maxLength = 0,
      this.initialText = ''}) : _formFieldKey = GlobalKey<FormFieldState>();

  @override
  build(BuildContext context) {

    print("built ModalSheet");

    String result;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: Text(title, style: TextStyle(fontSize: 18)),
                padding: EdgeInsets.only(bottom: 10),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  accentColor: Theme.of(context).primaryColor,
                  primaryColor: Theme.of(context).accentColor,
                ),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      autovalidate: false,
                      key: _formFieldKey,
                      enableInteractiveSelection: false,
                      enableSuggestions: false,
                      //autofocus: true,
                      autocorrect: false,
                      maxLength: maxLength,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        contentPadding: EdgeInsets.only(bottom: -20),
                      ),
                      initialValue: initialText,
                      validator: (value) => callback(value),
                      textInputAction: TextInputAction.done,
                      onSaved: (value) {
                        result = value;
                      },
                      onEditingComplete: () {
                        if (_formFieldKey.currentState.validate()) {
                          _formFieldKey.currentState.save();
                          Navigator.pop(context, result);
                        }
                      },
                    ),
                    ButtonBar(
                      buttonPadding: EdgeInsets.only(right: 0),
                      children: <Widget>[
                        FlatButton(
                          child: Text("Cancel", style: TextStyle(fontSize: 15)),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.only(right: 10),
                        ),
                        FlatButton(
                          child: Text(confirmLabel,
                              style: TextStyle(fontSize: 15)),
                          onPressed: () {
                            if (_formFieldKey.currentState.validate()) {
                              _formFieldKey.currentState.save();
                              Navigator.pop(context, result);
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
                /*child: Form(
                  key: _formKey,
                  autovalidate: true,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        enableInteractiveSelection: false,
                        //autofocus: false,
                        autocorrect: false,
                        enableSuggestions: false,
                        maxLength: maxLength,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          contentPadding: EdgeInsets.only(bottom: -20),
                        ),
                        initialValue: initialText,
                        validator: (value) => callback(value),
                        textInputAction: TextInputAction.done,
                        onSaved: (value) {result = value;},
                      ),
                      ButtonBar(
                        buttonPadding: EdgeInsets.only(right: 0),
                        children: <Widget>[
                          FlatButton(
                            child: Text("Cancel", style: TextStyle(fontSize: 15)),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.only(right: 10),
                          ),
                          FlatButton(
                            child: Text(confirmLabel, style: TextStyle(fontSize: 15)),
                            onPressed: (){
                              if (_formKey.currentState.validate()){
                                _formKey.currentState.save();
                              }
                              Navigator.pop(context, result);
                            },
                          )
                        ],
                      ),
                    ],
                  )
                ),*/
              ),
            ],
          ),
        ),
      ),
    );
  }
}
