import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/routes/managing/AccountSettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petrolshare/routes/managing/MemberSettings.dart';
import 'package:petrolshare/services/auth.dart';
import 'package:petrolshare/states/PoolState.dart';
import 'package:petrolshare/widgets/CountDownButton.dart';
import 'package:petrolshare/widgets/NameAndIcon.dart';
import 'package:petrolshare/widgets/PoolList.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailto/mailto.dart';

class ManageTab extends StatelessWidget {
  ManageTab({Key key}) : super(key: key);

  final AuthSevice _auth = AuthSevice();

  @override
  Widget build(BuildContext context) {
    Pool _pool = Provider.of<Pool>(context);
    UserModel _user = _pool.user;

    //assert (_user.hashCode == _pool.user.hashCode);
    //Conclusion: Hot Reloading changes Object References. Presumably
    //not an issue in release version :D

    return ListView(children: <Widget>[
      InkWell(
        child: NameAndIcon(_user, _handleLogout),
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
        child: Text(_pool.poolName, style: TextStyle(color: Colors.grey)),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      ),
      OpenContainer(
          closedColor: Theme.of(context).scaffoldBackgroundColor,
          openBuilder: (BuildContext _, VoidCallback openContainer) =>
              MemberSettings(),
          tappable: false,
          closedElevation: 0.0,
          closedBuilder: (BuildContext _, VoidCallback openContainer) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                    leading: Icon(Icons.supervisor_account),
                    title: Text('Members'),
                    onTap: openContainer,
                  ),
                  Visibility(
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                      leading: Icon(Icons.edit),
                      title: Text('Set Poolname'),
                      onTap: () => _handlePoolRenaming(context, _pool),
                    ),
                    visible: _user.role == 'admin' ?? false,
                  ),
                  ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                    leading: Icon(Icons.clear),
                    title: Text('Leave Pool'),
                    onTap: () => _handleLeavePool(context, _user.uid, _pool),
                  ),
                  ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                    leading: Icon(Icons.delete),
                    title: Text('Delete Pool'),
                    onTap: () => _handlePoolDeletion(context, _pool),
                  ),
                  Divider(),
                  Container(
                    child: Text("Pools", style: TextStyle(color: Colors.grey)),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                  ),
                  Visibility(
                    visible: _pool.pools.length > 1,
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                      leading: Icon(Icons.loop),
                      title: Text('Switch Pool'),
                      onTap: () {
                        PoolState currentState = _pool.poolState;
                        Future<Map<String, String>> pools =
                            _pool.fetchPoolSelection();
                        pools
                            .then((value) => poolSelection(context, value))
                            .then((value) {
                          if (value != null && value != _pool.pool) {
                            _pool.setPool(value).then((value) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content:
                                      Text('Switched to ${_pool.poolName}'),
                                  duration: Duration(seconds: 2)));
                            });
                          } else {
                            _pool.poolState = currentState;
                          }
                        });
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                    leading: Icon(Icons.add_circle_outline),
                    title: Text('Create New Pool'),
                    onTap: () => _handlePoolCreation(context, _pool),
                  ),
                  Divider(),
                  ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                    leading: Icon(Icons.feedback),
                    title: Text('Feedback'),
                    onTap: () => _sendFeedback(),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () => _launchURL("http://www.docweirdo.de"),
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Text("Data Policy",
                                    style: TextStyle(color: Colors.grey)),
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
          })
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

  Future<void> _handlePoolRenaming(BuildContext context, Pool pool) async {
    final _formKey = GlobalKey<FormState>();
    String poolname;

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
                title: Text('Rename Pool'),
                content: Form(
                  key: _formKey,
                  autovalidate: true,
                  child: TextFormField(
                    enableInteractiveSelection: false,
                    autofocus: true,
                    autocorrect: false,
                    maxLength: 15,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Poolname',
                      counterText: "",
                    ),
                    initialValue: pool.poolName,
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
                    child: Text("Rename"),
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

    if (poolname == pool.poolName) return;

    pool.data
        .renamePool(poolname, pool)
        .then((value) => Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Renamed pool to $poolname'))))
        .catchError((error) => Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString()))));
  }

  Future<void> _handlePoolCreation(BuildContext context, Pool pool) async {
    final _formKey = GlobalKey<FormState>();
    String poolname;

    if (pool.user.isAnonymous) {
      Fluttertoast.showToast(
          msg: "Please register an account to create a pool",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (pool.pools.length > 4) {
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
                  autovalidate: true,
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

    String poolID;

    pool.data
        .createPool(poolname)
        .then((value) {
          poolID = value;
          return pool.fetchPoolSelection();
        })
        .then((poolList) => pool.setPool(poolID))
        .then((value) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Created pool "$poolname"')));
          return;
        })
        .catchError((e) => Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString()))));
  }

  Future<void> _handlePoolDeletion(BuildContext context, Pool pool) async {
    int memberCount = 0;

    pool.logList.members.forEach((key, value) {
      if (['member', 'admin'].contains(value.role)) memberCount++;
    });

    if (memberCount > 1) {
      Fluttertoast.showToast(
          msg: "There are still users in this pool",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.all(20),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          actionsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          title: Text("Delete Pool"),
          content: Text(
              "Are you sure you want to delete pool \"${pool.poolName}\"? All data will be lost."),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel", style: TextStyle(fontSize: 15)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            Container(
              width: 130.0,
              alignment: Alignment.center,
              child: CountDownButton(
                title: "Delete Pool",
                callback: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await pool.data.deletePool(pool);

        if (pool.pools.length > 0) {
          //TODO: warum nicht == 1? Genauso in _handleLeavePool
          pool.setPool(pool.pools.keys.first).then((value) {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Switched to ${pool.poolName}'),
                duration: Duration(seconds: 2)));
          });
        } else {
          String selection = await poolSelection(context, pool.pools);

          if (selection != null && selection != pool.pool) {
            pool.setPool(selection).then((value) {
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Switched to ${pool.poolName}'),
                  duration: Duration(seconds: 2)));
            });
          } else {
            pool.notify();
          }
        }
      } catch (e) {
        print(e);
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Something went wrong.')));
      }
    }
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

  void _handleLeavePool(BuildContext context, String uid, Pool pool) async {
    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.all(20),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          actionsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          title: Text("Leave Pool"),
          content:
              Text("Are you sure you want to leave pool \"${pool.poolName}\"?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel", style: TextStyle(fontSize: 15)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            Container(
              width: 130.0,
              alignment: Alignment.center,
              child: CountDownButton(
                title: "Leave Pool",
                callback: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await pool.data.removeUserFromPool(uid, pool);

        pool.pools.remove(pool.pool);

        pool.pool = null;

        pool.poolState = PoolState.retrieved;

        if (pool.pools.length > 0) {
          pool.setPool(pool.pools.keys.first).then((value) {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Switched to ${pool.poolName}'),
                duration: Duration(seconds: 2)));
          });
        } else {
          String selection = await poolSelection(context, pool.pools);

          if (selection != null && selection != pool.pool) {
            pool.setPool(selection).then((value) {
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Switched to ${pool.poolName}'),
                  duration: Duration(seconds: 2)));
            });
          } else {
            pool.notify();
          }
        }
      } catch (e) {
        print(e);
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Something went wrong.')));
      }
    }
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
