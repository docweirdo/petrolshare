import 'package:animations/animations.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/routes/managing/AccountSettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petrolshare/routes/managing/MemberSettings.dart';
import 'package:petrolshare/services/auth.dart';
import 'package:petrolshare/states/Pool.dart';
import 'package:petrolshare/widgets/NameAndIcon.dart';
import 'package:petrolshare/widgets/PoolList.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';




class ManageTab extends StatelessWidget{
  ManageTab({Key key}) : super(key: key);

  final AuthSevice _auth = AuthSevice();

  @override
  Widget build(BuildContext context) {

    
    Pool _pool = Provider.of<Pool>(context);
    UserModel _user = _pool.user;

    //assert (_user.hashCode == _pool.user.hashCode);
    //Conclusion: Hot Reloading changes Object References. Presumably 
    //not an issue in release version :D

    final CloudFunctions cf= CloudFunctions(region: 'europe-west1');
    final HttpsCallable callable = cf
      .getHttpsCallable(functionName: 'createPool')
      ..timeout = const Duration(seconds: 30);

    return ListView(
      children: <Widget>[
        NameAndIcon(_user, _handleLogout),
        Divider(),
        OpenContainer(
          closedColor: Theme.of(context).scaffoldBackgroundColor,
          openBuilder: (BuildContext _, VoidCallback openContainer) => AccountSettings(_user, _handleLogout),
          tappable: false,
          closedElevation: 0.0,
          closedBuilder: (BuildContext _, VoidCallback openContainer) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                  leading: Icon(Icons.face),
                  title: Text('Account'),
                  onTap: openContainer,
                ),
                Divider(),
                Container(
                  child: Text(_pool.poolName, style: TextStyle(color: Colors.grey)),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                ),
                OpenContainer(
                  closedColor: Theme.of(context).scaffoldBackgroundColor,
                  openBuilder: (BuildContext _, VoidCallback openContainer) => MemberSettings(_pool),
                  tappable: false,
                  closedElevation: 0.0,
                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                          leading: Icon(Icons.supervisor_account),
                          title: Text('Members'),
                          onTap: openContainer,
                        ),
                        Visibility(
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                            leading: Icon(Icons.edit),
                            title: Text('Set Poolname'),
                          ),
                          visible: _user.role == 'admin' ?? false,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                          leading: Icon(Icons.clear),
                          title: Text('Leave Pool'),
                        ),
                        Divider(),
                        Container(
                          child: Text("Pools", style: TextStyle(color: Colors.grey)),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                          leading: Icon(Icons.loop),
                          title: Text('Switch Pool'),
                          onTap: () {
                            Future<Map<String, String>> pools = _pool.fetchPoolSelection();
                            poolSelection(context, pools).then((value) {
                              if (value != null) _pool.setPool(value);
                            });
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                          leading: Icon(Icons.add_circle_outline),
                          title: Text('Create New Pool'),
                          onTap: () async {
                            print('Button tapped');
                            try {
                              final HttpsCallableResult result = await callable.call(
                                <String, dynamic>{
                                  'poolname': 'Ferrari'
                                },
                              );

                            } on CloudFunctionsException catch (e) {
                                print('caught firebase functions exception');
                                print(e.code);
                                print(e.message);
                                print(e.details);
                              } catch (e) {
                                print('caught generic exception');
                                print(e);
                            }
                          },
                        ),
                        Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                          leading: Icon(Icons.feedback),
                          title: Text('Feedback'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  
                                },
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Text("Data Policy", style: TextStyle(color: Colors.grey)),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {

                                },
                                child: Align(
                                  alignment: Alignment.center,
                                    child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Text("Terms of Service", style: TextStyle(color: Colors.grey)),
                                  ),
                                ),
                              ),
                            ),
                          ]
                        )
                      ]
                    );
                  }
                )
              ],
            );
          }
        ),
      ],
    );
    
  }
  
  void _handleLogout(){
    _auth.signOut();
  }

  Future<String> poolSelection(BuildContext context, Future<Map<String, String>> poolsFuture) async {
    
    Map<String, String> pools = await poolsFuture;

    if (pools.isEmpty) return null;

    if (pools.length == 1) return pools.keys.toList()[0];

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Choose a pool'),
          content: PoolList(pools),
        );
      }
    );
  }
  
}

