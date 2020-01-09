import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_app/utils/utils.dart';

class AdminRegisterCardPage extends StatefulWidget {
  static const routeName = "admin/registerCard";

  AdminRegisterCardPage({Key key, this.title, this.cardId}) : super(key: key);
  final String cardId;
  final String title;

  @override
  _AdminRegisterCardPageState createState() => _AdminRegisterCardPageState();
}

class _AdminRegisterCardPageState extends State<AdminRegisterCardPage> {
  Future<String> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "discovered":
        return "write";
      case "operationDone":
        bool success = call.arguments;
        if (success) Navigator.pop(context);
        return "";
    }
    return "";
  }

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
  void dispose() {
    super.dispose();
    Utils.platform.setMethodCallHandler(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
          Center(child: Text("Approach Card..."))
        ],
      ),
    );
  }
}
