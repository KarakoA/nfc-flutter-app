import 'package:flutter/material.dart';
import 'package:flutter_nfc_app/admin/admin_detail_page.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

import '../user/list_page.dart';

class AdminHomePage extends StatefulWidget {
  static const routeName = "admin/home";

  AdminHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    readTag();
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
          title: Text('Link Card'),
          onTap: () {
            // Update the state of the app
            // ...
            // Then close the drawer
            Navigator.pushNamed(context, ListPage.routeName);
          },
        ),
        ListTile(
          title: Text('Logout'),
          onTap: () {},
        ),
      ])),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.ac_unit),
          onPressed: () => Navigator.pushNamed(
              context, AdminDetailPage.routeName,
              arguments: "55"),
        ),
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                strokeWidth: 8,
              ),
            ),
          ),
          Center(child: Text("Approach Card ..."))
        ],
      ),
    );

    // link card with user
    // add funds
    // deduce funds
    // setup machines
    //
  }

//TODO overlapping possible if its like this
  //TODO here tests
  void readTag() {
    FlutterNfcReader.read().then(onTagRead);
  }

  void onTagRead(NfcData data) {
    //TODO find userId by tagId
    //if not found
    // empty card, show scan page

    // if found
//    continue as before
    /*
      Navigator.pushNamed(
        context, AdminDetailPage.routeName,
        arguments: response.id
        }
        */
  }
}