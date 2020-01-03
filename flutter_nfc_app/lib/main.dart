import 'package:flutter/material.dart';
import 'package:flutter_nfc_app/home_page.dart';

import 'list_page.dart';

void main() => runApp(
      MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.lightBlue,
        ),
        initialRoute: '/',
        routes: {
          '/': (BuildContext context) => HomePage(title: 'Laundry Room App'),
          '/list': (BuildContext context) =>
              new ListPage(title: "Available Machines")
        },
      ),
    );
