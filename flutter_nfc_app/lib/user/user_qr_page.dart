import 'package:flutter/material.dart';
import 'package:flutter_nfc_app/utils/utils.dart';
import 'package:openapi/api.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserQrPage extends StatefulWidget {
  static const routeName = "/qr";

  UserQrPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _UserQrPageState createState() => _UserQrPageState();
}

class _UserQrPageState extends State<UserQrPage> {
  Future<String> _userIdFuture = Future(Utils.loadUserIdFromPreferneces);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _userIdFuture,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData)
            return _buildContent(snapshot.data);
          else
            return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(String userID) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImage(
            data: userID,
            version: QrVersions.auto,
            size: 300.0,
          ),
          Text("User ID"),
        ],
      ),
    );
  }
}