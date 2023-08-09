import 'package:flutter/widgets.dart';

class StatsTab extends StatefulWidget {
  StatsTab({Key? key}) : super(key: key);

  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25.0),
      child: Text('Uwe'),
    );
  }
}
