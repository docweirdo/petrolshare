import 'package:flutter/material.dart';
import 'package:petrolshare/widgets/PoolList.dart';

Future<String?> poolSelection(
      BuildContext context, Map<String, String> pools) {
    if (pools.isEmpty) return Future(() => null);

    if (pools.length == 1) return Future.value(pools.keys.first);

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choose a pool'),
            content: PoolList(pools),
          );
        });
}