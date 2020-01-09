import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;

@deprecated
class AdminLinkCardPage extends StatefulWidget {
  static const routeName = "admin/link";

  AdminLinkCardPage({Key key, this.cardId}) : super(key: key);
  final String cardId;

  @override
  _AdminLinkCardPageState createState() => _AdminLinkCardPageState();
}

class _AdminLinkCardPageState extends State<AdminLinkCardPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: RaisedButton(onPressed: ()async => await scanner.scan()));
    /*return FutureBuilder(
      future: _scanFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final String a = snapshot.data;
          return Text(a);
        } else
          Text("Loading");
      },
    );*/
  }
}
