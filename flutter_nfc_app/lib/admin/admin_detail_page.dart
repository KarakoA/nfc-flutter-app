import 'package:flutter/material.dart';
import 'package:openapi/api.dart';

class AdminDetailPage extends StatefulWidget {
  static const routeName = "admin/details";

  AdminDetailPage({Key key, this.title, this.userId}) : super(key: key);
  final String title;
  final String userId;

  @override
  State<StatefulWidget> createState() => _AdminDetailPageState();
}

class _AdminDetailPageState extends State<AdminDetailPage> {
  double _newBalance = 0;

  @override
  void initState() {
    super.initState();
    _userFuture = Future(load);
  }

  Future<User> _userFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _userFuture,
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.hasData) {
            var user = snapshot.data;
            return _buildContent(user);
          } else
            return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<User> load() async {
     try {
      var apiInstance = UserApi();
      //TODO swagger is crazy on this one
//      User user = await apiInstance.getUserById(widget.userId);
       User user = await apiInstance.getUserById("1234");
       _newBalance = user.balance;
      return user;
    } catch (e) {
      print("Exception when calling UserApi->getUserById: $e\n");
      return User();
    }
  }

  void onDone(User user) async {
    try {
      var apiInstance = UserApi();
      apiInstance.userRecharge(user.id, _newBalance - user.balance);
    } catch (e) {
      print("Exception when calling UserApi->userRecharge: $e\n");
    }

    Navigator.pop(context);
  }

  Widget showLoadingIndicator() => Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildContent(User user) {
    return Stack(children: [
      Container(
        padding: EdgeInsets.all(32),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            "User ID: ${widget.userId}",
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "${_newBalance} €",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 68),
            ),
          ),
          SizedBox(height: 32),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              Ink(
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
                  color: Colors.red,
                ),
                child: IconButton(
                  color: Colors.white,
                  iconSize: 64,
                  icon: new Icon(Icons.remove),
                  onPressed: _newBalance > user.balance
                      ? () => setState(() => _newBalance -= 1)
                      : null,
                ),
              ),
              SizedBox(
                width: 32,
              ),
              Ink(
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
                  color: Colors.green,
                ),
                child: IconButton(
                  color: Colors.white,
                  iconSize: 64,
                  icon: new Icon(Icons.add),
                  onPressed: () => setState(() => _newBalance += 1),
                ),
              ),
            ],
          ),
          SizedBox(height: 46),
        ],
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.fromLTRB(32, 32, 32, 64),
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.green,
              child: Text(
                "Done",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              onPressed:
                  _newBalance != user.balance ? () => onDone(user) : null,
            ),
          ),
        ),
      ),
    ]);
  }
}