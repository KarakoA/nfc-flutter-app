import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_app/admin/admin_detail_page.dart';
import 'package:flutter_nfc_app/admin/admin_home_page.dart';
import 'package:flutter_nfc_app/user/home_page.dart';
import 'package:flutter_nfc_app/login_page.dart';
import 'package:flutter_nfc_app/user/user_qr_page.dart';
import 'user/list_page.dart';

void main() => runApp(
      DynamicTheme(
        data: (brightness) => new ThemeData(primarySwatch: Colors.lightBlue),
        themedWidgetBuilder: (context, theme) => MaterialApp(
          title: 'Flutter Demo',
          initialRoute: LoginPage.routeName,
          theme: theme,
          routes: {
            LoginPage.routeName: (BuildContext context) => LoginPage(),
            HomePage.routeName: (BuildContext context) =>
                HomePage(title: 'Aristotelessteig'),
            ListPage.routeName: (BuildContext context) =>
                new ListPage(title: "Available Machines"),
            AdminHomePage.routeName: (BuildContext context) =>
                AdminHomePage(title: 'Admin'),
            AdminDetailPage.routeName: (BuildContext context) =>
                AdminDetailPage(title: 'Card Details'),
            UserQrPage.routeName: (BuildContext context) =>
                UserQrPage(title: "QR-Code"),
          },
        ),
      ),
    );
