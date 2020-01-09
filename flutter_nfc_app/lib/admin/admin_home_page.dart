import 'package:flutter/material.dart';
import 'package:flutter_nfc_app/admin/admin_detail_page.dart';
import 'package:flutter_nfc_app/admin/admin_link_card_page.dart';
//import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:http/http.dart';
import 'package:openapi/api.dart';

import 'package:qrscan/qrscan.dart' as scanner;

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
//            Navigator.pushNamed(context, ListPage.routeName);
          },
        ),
        ListTile(
          title: Text('Logout'),
          onTap: () {},
        ),
      ])),
      appBar: AppBar(
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
    // setup machines
    //
  }

//TODO overlapping possible if its like this
  //TODO here tests
  void readTag() {
   // FlutterNfcReader.read().then(onTagRead);
  }

  //TODO
  /*
  String extractCardId(NfcData data) {
    return data.id;
  }*/
/*
  void onTagRead(NfcData data) async {
    var cardId = extractCardId(data);
    try {
      var apiInstance = UserApi();
      Response response = await apiInstance.getUserByCardIdWithHttpInfo(cardId);

      //TODO Swap codes back
      //card found, go to details
      if (response.statusCode == 404) {
        var userId = response.body;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AdminDetailPage(title: "Details", userId: userId),
          ),
        );
      }
      //could not find the card, go into "link" mode
      if (response.statusCode == 200) {
        await _onLinkCard(cardId);
      }
    } catch (e) {
      //fail silently
      e.print("Exception when calling UserApi->getUserByCardId: $e\n");
    }
  }

  Future<void> _onLinkCard(String cardId) async {
    try {
      var userId = await scanner.scan();
      var apiInstance = UserApi();
      apiInstance.userLinkCard(userId, cardId);
      await Scaffold.of(context)
          .showSnackBar(
            new SnackBar(
              content: Text(
                "Success",
                textAlign: TextAlign.center,
              ),
              duration: Duration(seconds: 3),
            ),
          )
          .closed;
      Navigator.pop(context);
    } catch (e) {
      print("Exception when calling UserApi->userLinkCard: $e\n");
    }
  }*/
}
