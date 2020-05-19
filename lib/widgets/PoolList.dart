
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PoolList extends StatelessWidget{

  final Map<String, String> _pools;

  PoolList(this._pools);

  @override
  Widget build(BuildContext context){

    var keys = _pools.keys.toList();

    return Container(
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _pools.length,
        itemBuilder: (BuildContext context, int index) {

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.grey.withOpacity(0.4),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              leading: CircleAvatar(
                backgroundColor: Colors.grey[100],
                radius: 20,
                child: Text(_pools[keys[index]][0].toUpperCase(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,))
              ),
              title: Text(_pools[keys[index]]),
              onTap: () {
                Navigator.pop(context, keys[index]);
              },
            )
          );
        }
      ),
    );
  }

}