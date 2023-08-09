import 'package:flutter/material.dart';
import 'dart:async';

class CountDownButton extends StatefulWidget {
  final VoidCallback callback;
  final String title;

  CountDownButton({Key? key, required this.callback, required this.title})
      : super(key: key);

  @override
  CountDownState createState() => CountDownState();
}

class CountDownState extends State<CountDownButton> {
  late Timer _timer;
  int _start = 10;


  @override
  void initState(){
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {

    if (_start > 0) {
      return TextButton(
        child: Text("$_start", style: TextStyle(fontSize: 15, )),
        onPressed: null,
      );
    } else {
      return TextButton(
        child: Text(widget.title, style: TextStyle(fontSize: 15)),
        onPressed: widget.callback,
      );
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) { 
        setState(() {
          if (_start == 0) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        });
      }
    );
  }


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
