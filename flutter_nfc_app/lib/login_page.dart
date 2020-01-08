import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_app/admin/admin_home_page.dart';
import 'package:flutter_nfc_app/user/home_page.dart';
import 'package:flutter_nfc_app/user/user_qr_page.dart';
import 'package:flutter_nfc_app/utils/utils.dart';
import 'package:http/http.dart';
import 'package:openapi/api.dart';

class LoginPage extends StatefulWidget {
  static const routeName = "/login";
  static const usernameSharedPrefsKey = "usernameKey";

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    final icon = Icon(Icons.local_laundry_service,
        color: Theme.of(context).primaryColor, size: 250);
    final userField = TextField(
      controller: _userController,
      obscureText: false,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "User",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextField(
      obscureText: true,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButton = SizedBox(
      //match parent
      width: double.infinity,
      height: 50,
      child: RaisedButton(
        color: Theme.of(context).primaryColor,
        onPressed: _onLogin,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Text(
          "Login",
          textAlign: TextAlign.center,
        ),
      ),
    );
    final registerButton = SizedBox(
        //match parent
        width: double.infinity,
        height: 50,
        child: RaisedButton(
          color: Theme.of(context).primaryColorLight,
          onPressed: _onRegister,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Text(
            "Register",
            textAlign: TextAlign.center,
          ),
        ));
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Aristeig Washing",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24, color: Theme.of(context).primaryColorDark),
                ),
                icon,
                SizedBox(height: 16.0),
                userField,
                SizedBox(height: 16.0),
                passwordField,
                SizedBox(height: 32.0),
                loginButton,
                SizedBox(height: 16.0),
                registerButton,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onLogin() async {
    if (_userController.text.toLowerCase() == "admin") {
      DynamicTheme.of(context)
          .setThemeData(new ThemeData(primarySwatch: Colors.red));
      Navigator.pushReplacementNamed(context, AdminHomePage.routeName);
    } else {
      //TODO check for user, store ID and sharedPrefs
      var userId = "38400000-8cf0-11bd-b23e-10b96e4ef00d";
      Utils.saveUserIdToPreferences(userId);

      Navigator.pushReplacementNamed(context, HomePage.routeName);
    }
  }

  void _onRegister() async {
    var email = _userController.text;
    var apiInstance = UserApi();
    var user = User()..email = email;

    //and hardcode pin?
    //_asyncInputDialog
    try {
      Response result = await apiInstance.addUsers(user);
      var userId = result.headers["Location"];
      Utils.saveUserIdToPreferences(userId);
    } catch (e) {
      print("Exception when calling UserApi->addUsers: $e\n");
    }

    Navigator.pushNamed(context, UserQrPage.routeName);
  }

  Future<String> _asyncInputDialog() async {
    /*
    String pin = '';
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set pin'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Pin', hintText: 'eg. 125'),
                onChanged: (value) {
                  pin = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(pin);
              },
            ),
          ],
        );
      },
    );*/
  }
}
