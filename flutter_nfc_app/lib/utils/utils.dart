import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:openapi/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static const platform = const MethodChannel('de.htw.nfc.flutter_nfc_app.readCard');

  static const _userIdPrefsKey = "userIdKey";

  static void saveUserIdToPreferences(String userId) async {
    //store user name
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdPrefsKey, userId);
  }

  static Future<String> loadUserIdFromPreferneces() async {
    //store user name
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdPrefsKey);
  }

  static Future<Either<Exception, User>> loadPrefsUserFromAPIEither() async {
    var userId = await loadUserIdFromPreferneces();
    var apiInstance = UserApi();
    try {
      var user = await apiInstance.getUserById(userId);
      return Right(user);
    } catch (e) {
      return Left(e);
    }
  }

  static Future<Option<User>> loadPrefsUserFromAPIOption() async {
    var result = await loadPrefsUserFromAPIEither();
    return result.toOption();
  }

  static Future<User> loadPrefsUserFromAPIorDefault() async {
    var result = await loadPrefsUserFromAPIEither();
    return result.toOption().getOrElse(() => User());
  }
}
