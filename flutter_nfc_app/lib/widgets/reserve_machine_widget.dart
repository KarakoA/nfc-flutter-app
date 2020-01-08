import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_app/utils/utils.dart';
import 'package:openapi/api.dart';

class ReserveMachineWidget extends StatefulWidget {
  ReserveMachineWidget({Key key, this.machine}) : super(key: key);
  final Machine machine;

  @override
  _ReserveMachineWidgetState createState() => _ReserveMachineWidgetState();
}

class _ReserveMachineWidgetState extends State<ReserveMachineWidget> {
  final StreamController<String> _streamController = StreamController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _streamController.stream,
      initialData: "free",
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.data == "free")
          return IconButton(
            icon: Icon(Icons.lock_open),
            onPressed: _onReserve,
          );
        else if (snapshot.data == "load")
          return Container(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            ),
          );
        else {
          _streamController.close();
          return Container(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.lock),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }

  void _onReserve() async {
    _streamController.add("load");

    // show the loading indicator
    await Future.delayed(Duration(seconds: 1));

    try {
      var apiInstance = MachineApi();
      var machineId = widget.machine.id;
      var userId = await Utils.loadUserIdFromPreferneces();
      var timestamp = DateTime.now();
      apiInstance.machineHold(machineId, userId, timestamp);
      var until = DateTime.now().add(Duration(minutes: 10));
      final SnackBar snackBar = SnackBar(
        content: Text(
          "Machine reserved until ${until.hour}:${until.minute}",
          textAlign: TextAlign.center,
        ),
      );

      Scaffold.of(context).showSnackBar(snackBar);
      _streamController.add("done");
    } catch (e) {
      print("Exception when calling MachineApi->machineHold: $e\n");
      _streamController.add("free");
    }
  }
}
