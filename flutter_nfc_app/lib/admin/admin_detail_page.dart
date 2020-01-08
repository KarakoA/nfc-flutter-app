import 'package:flutter/material.dart';
import 'package:openapi/api.dart';

class AdminDetailPage extends StatefulWidget {
  static const routeName = "admin/details";

  AdminDetailPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _AdminDetailPageState();
}

class _AdminDetailPageState extends State<AdminDetailPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  User _user = User();
  double _newBalance = 0;

  String _balanceDisplay() => (_newBalance?.toString() ?? "") + " €";

  String _cardIdDisplay() => "User ID: ${_user?.id ?? ""}";

  bool newBalanceIsHigher() =>
      (_newBalance != null && _user?.balance != null) &&
      _newBalance > _user.balance;

  bool newBalanceIsDifferent() =>
      (_newBalance != null && _user?.balance != null) &&
      _newBalance != _user.balance;

  //TODO load indicator

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading ? showLoadingIndicator() : _buildContent(),
    );
  }

  void loadData() async {
    //TODO can't call here
    //final String tagIdAsArg = ModalRoute.of(context).settings.arguments;
    var apiInstance = UserApi();
    var userId = "38400000-8cf0-11bd-b23e-10b96e4ef00d";
    try {
      var result = await apiInstance.getUserById(userId);
      setState(() {
        _user = result;
        _newBalance = _user.balance;
        _isLoading = false;
      });
      print(result);
    } catch (e) {
      print("Exception when calling UserApi->getUserById: $e\n");
    }
  }

  void onDone() async {
    try {
      var apiInstance = UserApi();
      apiInstance.userRecharge(_user.id, _newBalance - _user.balance);
    } catch (e) {
      print("Exception when calling UserApi->userRecharge: $e\n");
    }

    Navigator.pop(context, "asdf");
  }

  Widget showLoadingIndicator() => Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildContent() {
    return Stack(children: [
      Container(
        padding: EdgeInsets.all(32),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            _cardIdDisplay(),
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
              _balanceDisplay(),
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
                  onPressed: newBalanceIsHigher()
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
              onPressed: newBalanceIsDifferent() ? onDone : null,
            ),
          ),
        ),
      ),
    ]);
  }
}