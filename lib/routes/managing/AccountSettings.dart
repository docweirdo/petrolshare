import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/routes/authenticate/SignIn.dart';
import 'package:petrolshare/services/auth.dart';
import 'package:petrolshare/states/Pool.dart';
import 'package:petrolshare/widgets/ListEditTile.dart';
import 'package:petrolshare/widgets/TextFieldModalSheet.dart';
import 'package:provider/provider.dart';

class AccountSettings extends StatefulWidget {
  final Function logoutCallback;
  final AuthSevice _auth = AuthSevice();
  final Pool _pool;
  final UserModel _user;


  AccountSettings(this.logoutCallback, this._pool, this._user);

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  bool buttonVisible = true;

  @override
  void initState() {
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 75),
      vsync: this,
    )..addStatusListener((AnimationStatus status) {
        setState(() {
          // setState needs to be called to trigger a rebuild because
          // the 'HIDE FAB'/'SHOW FAB' button needs to be updated based
          // the latest value of [_controller.status].
        });
      });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
        Duration(milliseconds: 400), () => _controller.forward()));

    return WillPopScope(
      onWillPop: () {
        _controller.reverse().then((value) {
          setState(() {
            buttonVisible = false;
          });
          Navigator.pop(context);
        });
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Account'),
        ),
        body: ListView(children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 260,
              height: 260,
              child: Stack(fit: StackFit.expand, children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  margin: EdgeInsets.all(30),
                  padding: EdgeInsets.all(30),
                  child: Hero(
                      child: _provideAvatar(context, widget._user),
                      tag: "profilepic"),
                ),
                Positioned(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (BuildContext context, Widget child) {
                      return FadeScaleTransition(
                        animation: _controller,
                        child: child,
                      );
                    },
                    child: Visibility(
                      visible: _controller.status != AnimationStatus.dismissed && buttonVisible,
                      child: RawMaterialButton(
                        onPressed: _handlePicchange,
                        elevation: 2.0,
                        fillColor: Theme.of(context).accentColor,
                        child: Icon(
                          Icons.edit,
                          size: 25.0,
                        ),
                        padding: EdgeInsets.all(12.0),
                        shape: CircleBorder(),
                      ),
                    ),
                  ),
                  bottom: 50,
                  right: 50,
                ),
              ]),
            ),
          ),
          ListEditTile(
              leadingIcon: Icon(Icons.face),
              editCallback: _handleNamechange,
              title: widget._user.name,
              info: "Name",
              args: [widget._user.name]),
          Visibility(
            child: ListEditTile(
                leadingIcon: Icon(Icons.info_outline),
                editCallback: _handleInfochange,
                title: widget._user.identifier,
                info: "Email/Phone"),
            visible: !widget._user.isAnonymous,
          ),
          Visibility(
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              leading: Icon(Icons.account_circle),
              title: Text('Create Account', style: TextStyle(fontSize: 18)),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => SignIn())),
            ),
            visible: widget._user.isAnonymous,
          ),
        ]),
      ),
    );
  }

  Widget _provideAvatar(BuildContext context, UserModel _user) {
    if (_user.photo == null) {
      return CircleAvatar(
          backgroundColor: Colors.grey[100],
          //foregroundColor: Theme.of(context).accentColor,
          radius: 70,
          child: Text(_user.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )));
    }
    return CircleAvatar(
      backgroundImage: MemoryImage(_user.photo),
      radius: 70,
    );
  }

  void _handleNamechange(BuildContext context, List<dynamic> args) async {

    String entry = await showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TextFieldModalSheet(
          title: "Enter your new username.",
          confirmLabel: "Rename",
          maxLength: 30,
          initialText: args[0],
          callback: (value){
            if (value.isEmpty) return 'Required';
            return null;
          },
        );
      }
    );

    if (entry == null) return;

    entry = entry.trim();

    if (entry == args[0]) return;

    widget._auth.changeUsername(entry).then( (v) => Scaffold.of(context).showSnackBar(SnackBar(content: Text('Username changed.'))))
    .catchError((e) => Scaffold.of(context).showSnackBar(SnackBar(content: Text('Something went wrong.'))));

  }

  void _handleInfochange(BuildContext context) {
    print("handling stuff");
  }

  void _handlePicchange() {
    print("handling stuff");
  }
}
