import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_app/user/list_page.dart';
import 'package:flutter_nfc_app/user/user_qr_page.dart';
import 'package:flutter_nfc_app/utils/utils.dart';
import 'package:openapi/api.dart';
import 'package:tuple/tuple.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home";

  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamController<Tuple2<User, List<Machine>>> _streamController;

  @override
  void initState() {
    _streamController = StreamController();
    load();
    super.initState();
  }

  void load() async {
    var user = await Utils.loadPrefsUserFromAPIorDefault();
    var machines = await _loadReservedMachines(user);
    _streamController.add(Tuple2(user, machines));
  }

  Future<List<Machine>> _loadReservedMachines(User user) async {
    if (user == null) return List();
    try {
      var apiInstance = UserApi();
      var result = await apiInstance.reservedMachines(user.id);
      return result;
    } catch (e) {
      print("Exception when calling UserApi->reservedMachines: $e\n");
      return List();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
        DrawerHeader(
          child: Text('Options'),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
        ),
        ListTile(
          title: Text('QR-Code'),
          onTap: () {
            // Update the state of the app
            // ...
            // Then close the drawer
            Navigator.pushNamed(context, UserQrPage.routeName);
          },
        ),
        ListTile(
          title: Text('Logout'),
          onTap: () {
            DynamicTheme.of(context)
                .setThemeData(new ThemeData(primarySwatch: Colors.lightBlue));
            Navigator.pushReplacementNamed(context, "/");
          },
        ),
      ])),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.local_laundry_service),
            onPressed: _listAvailableMachines,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: load,
      ),
      body: StreamBuilder(
          stream: _streamController.stream,
          builder: (BuildContext context,
              AsyncSnapshot<Tuple2<User, List<Machine>>> snapshot) {
            if (snapshot.hasData)
              return _buildContent(snapshot.data);
            else
              return Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget _buildContent(Tuple2<User, List<Machine>> data) {
    var user = data.item1;
    var machines = data.item2;
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                  width:double.infinity,
                  padding: EdgeInsets.all(16),
                  child: Text("SSV opening hours:\n Tue., Thurs. 20:00-21:00", textAlign: TextAlign.center)),
              Center(
                child: Text("${user.balance} €",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 68)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
              //  shrinkWrap: true,
              itemCount: machines.length + 1,
              itemBuilder: (BuildContext context, int position) {
                if (position == 0) return Divider(thickness: 4);
                return getRow(machines[position - 1]);
              }),
        ),
      ],
    );
  }

  Widget getRow(Machine machine) {
    var until = machine.lastHoldingStartTime.add(Duration(minutes: 10));
    return new ListTile(
      title: Text(
          "House ${machine.houseNumber}, Machine ${machine.name} reserved until ${until.hour}:${until.minute}"),
      leading: Icon(Icons.local_laundry_service, size: 32),
    );
  }

  void _listAvailableMachines() =>
      Navigator.pushNamed(context, ListPage.routeName);
}
