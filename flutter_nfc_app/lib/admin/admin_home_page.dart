import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_app/admin/admin_detail_page.dart';
import 'package:flutter_nfc_app/admin/admin_register_card_page.dart';
import 'package:flutter_nfc_app/utils/utils.dart';

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
    Utils.platform.setMethodCallHandler(_handleMethod);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Utils.platform.setMethodCallHandler(_handleMethod);
    }
    if (state == AppLifecycleState.paused) {
      Utils.platform.setMethodCallHandler(null);
    }
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
          title: Text('Write new Card ID'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AdminRegisterCardPage.routeName);
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
  }

  Future<String> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "discovered":
        return "read";
      case "operationDone":
        String cardId = call.arguments;
        onTagRead(cardId);
        return "";
    }
    return "";
  }

  void onTagRead(String cardId) async {
    try {
      var apiInstance = UserApi();
      Response response = await apiInstance.getUserByCardIdWithHttpInfo(cardId);

      //card found, go to details
      if (response.statusCode == 200) {
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
      if (response.statusCode == 404) {
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
  }
}
