import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

@deprecated
class UserPage extends StatefulWidget {
  static const routeName = "/user";

  UserPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _isLoading = true;

  User _user;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading ? showLoadingIndicator() : _buildContent(),
    );
  }

  Widget showLoadingIndicator() =>
      Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildContent() {
    return Column(

    );
  }

  void loadData() async {
    var apiInstance = UserApi();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //var userId = prefs.getString(LoginPage.usernameSharedPrefsKey);
    var userId = "38400000-8cf0-11bd-b23e-10b96e4ef00d";
    try {
      var result = await apiInstance.getUserById(userId);
      setState(() {
        _user = result;
        _isLoading = false;
      });
      print(result);
    } catch (e) {
      print("Exception when calling UserApi->getUserById: $e\n");
    }
  }
}