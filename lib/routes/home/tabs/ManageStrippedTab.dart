import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/routes/managing/AccountSettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petrolshare/services/auth.dart';
import 'package:petrolshare/states/AppState.dart';
import 'package:petrolshare/states/PoolState.dart';
import 'package:petrolshare/widgets/NameAndIcon.dart';
import 'package:petrolshare/widgets/PoolList.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailto/mailto.dart';

class ManageStrippedTab extends StatelessWidget {
  ManageStrippedTab({Key key}) : super(key: key);

  final AuthSevice _auth = AuthSevice();

  @override
  Widget build(BuildContext context) {
    AppState appState = Provider.of<AppState>(context);
    PoolState poolState = Provider.of<PoolState>(context);
    UserModel user = appState.user;

    //assert (_user.hashCode == _pool.user.hashCode);
    //Conclusion: Hot Reloading changes Object References. Presumably
    //not an issue in release version :D

    return ListView(children: <Widget>[
      InkWell(
        child: NameAndIcon(user, _handleLogout),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AccountSettings(_handleLogout))),
      ),
      Divider(),
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        leading: Icon(Icons.face),
        title: Text('Account'),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AccountSettings(_handleLogout))),
      ),
      Divider(),
      Container(
        child: Text("Pools", style: TextStyle(color: Colors.grey)),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      ),
      Visibility(
        visible: appState.availablePools.length > 1,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          leading: Icon(Icons.loop),
          title: Text('Switch Pool'),
          onTap: () {
            poolSelection(context, appState.availablePools).then((value) {
              if (value != null && value != appState.selectedPool) {
                appState.setPool(value).then((value) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Switched to ${poolState.name}'),
                      duration: Duration(seconds: 2)));
                });
              }
            });
          },
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        leading: Icon(Icons.add_circle_outline),
        title: Text('Create New Pool'),
        onTap: () => _handlePoolCreation(context, appState),
      ),
      //Spacer(), Todo: Find way to pin Feedback to bottom
      Divider(),
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        leading: Icon(Icons.feedback),
        title: Text('Feedback'),
        onTap: () => _sendFeedback(),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () => _launchURL("http://www.docweirdo.de"),
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child:
                    Text("Data Policy", style: TextStyle(color: Colors.grey)),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () => _launchURL("http://www.docweirdo.de"),
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text("Terms of Service",
                    style: TextStyle(color: Colors.grey)),
              ),
            ),
          ),
        ),
      ])
    ]);
  }

  void _handleLogout(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.all(20),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          actionsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          title: Text("Log out"),
          content: user.isAnonymous
              ? Text(
                  "Are you sure you want to log out? Create a permanent account, otherwise your data will be lost")
              : Text("Are you sure you want to log out?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel", style: TextStyle(fontSize: 15)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Log out", style: TextStyle(fontSize: 15)),
              onPressed: () {
                _auth.signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handlePoolCreation(
      BuildContext context, AppState appState) async {
    final _formKey = GlobalKey<FormState>();
    String poolname;

    if (appState.user.isAnonymous) {
      Fluttertoast.showToast(
          msg: "Please register an account to create a pool",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (appState.availablePools.length > 4) {
      // TODO: Shouldn't it be five max to *own*
      Fluttertoast.showToast(
          msg:
              "Limit of 5 Pools reached. Please leave a pool to create a new one.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Theme(
              data: Theme.of(context).copyWith(
                primaryColor: Theme.of(context).accentColor,
                accentColor: Theme.of(context).primaryColor,
              ),
              child: AlertDialog(
                titlePadding: EdgeInsets.all(20),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                actionsPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                title: Text('Create a new pool'),
                content: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    enableInteractiveSelection: false,
                    autofocus: true,
                    autocorrect: false,
                    maxLength: 15,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Poolname',
                    ),
                    onSaved: (newValue) => poolname = newValue,
                    validator: (value) {
                      if (value.isEmpty) return 'Required';
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FlatButton(
                    child: Text("Create"),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                      }
                      Navigator.pop(context);
                    },
                  )
                ],
              ));
        });

    if (poolname == null) return;

    poolname = poolname.trim();

    if (poolname.length == 0) return;

    //String poolID;

    appState.createPool(poolname);
    /*
        .then((value) {
          poolID = value;
          //return pool.fetchPoolSelection();
          appState.poolStatus = PoolStatus.retrieved;
        })
        .then((poolList) => pool.setPool(poolID))
        .then((value) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Created pool "$poolname"')));
          return;
        })
        .catchError((e) => Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString()))));
        */
  }

  Future<String> poolSelection(
      BuildContext context, Map<String, String> pools) {
    if (pools.isEmpty) return null;

    if (pools.length == 1) return Future.value(pools.keys.toList()[0]);

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

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _sendFeedback() async {
    final mailtoLink = Mailto(
      to: ['tretmine007@gmail.com'],
      subject: 'Feedback: Petrolshare',
    );

    await launch('$mailtoLink');
  }
}
