import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_easy_nfc/flutter_easy_nfc.dart';

class NFCUtils {
  static const platform =
      const MethodChannel('de.htw.nfc.flutter_nfc_app.readCard');

  static Future<String> readCardId() async {
    final int result = await platform.invokeMethod('getBatteryLevel');
    var batteryLevel = 'Battery level at $result % .';
    return batteryLevel;
    //final int result = await platform.invokeMethod(
    //    'readCard', <String, String>{'url': "https://flutter.dev"});
  }

  static Future<String> writeTag(String uuid) async {
    var isEnabled = await FlutterEasyNfc.isEnabled();
    if (!isEnabled) {
      await FlutterEasyNfc.startup();
    }
    var isEnabled2 = await FlutterEasyNfc.isEnabled();
    if (!isEnabled2) {
      var a = 5;
    }
    var sc = StreamController();

    FlutterEasyNfc.onNfcEvent((NfcEvent event) async {
      sc.add("ASDF");
      if (event.tag is MifareClassic) {
        MifareClassic m1 = event.tag;
        await m1.connect();

        var keyA = "FFFFFFFFFFFF";
        var keyB = "ABCDEF123456";
        var accessBits = "0F00FFFF";

        var data = "${keyA}${accessBits}${keyB}";
        //write to sector trailer
        await m1.writeBlock(7, data);

        var isSuccess = await m1.authenticateSectorWithKeyB(4, keyB);

        sc.add(event);
        if (isSuccess) {
          m1.writeBlock(4, "AB");
        }
        await m1.close();
      }
    });
    var a = await sc.stream.first;
    sc.close();
    return a;
  }

  Future<String> readTag() {
    FlutterEasyNfc.onNfcEvent((NfcEvent event) async {
      if (event.tag is MifareClassic) {
        MifareClassic m1 = event.tag;
        await m1.connect();
        await m1.authenticateSectorWithKeyA(0, "A0A1A2A3A4A5");
        print(await m1.readBlock(0));
        print(await m1.readBlock(1));
        print(await m1.readBlock(2));
        print(await m1.readBlock(3));
        await m1.close();
      }
    });
  }

//  static void readCardId(NfcData data) {
//  FlutterNfcReader.write(path, label)
//}

}
