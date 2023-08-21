import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocaldbHelper {
  static SharedPreferences? prefs;

  static Future saveUserName({@required String? gateNo}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", gateNo!);
  }

  static Future<String?> getUserName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("username")) {
      return sharedPreferences.getString("username");
    }
    return null;
  }

  static Future saveGateNo({required String gateNo}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("gateno", gateNo!);
  }

  static Future<String?> gateNo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("gateno")) {
      return sharedPreferences.getString("gateno");
    }
    return null;
  }

  static Future saveToken({@required String? token}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token!);
  }

  static Future<String?> getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("token")) {
      return sharedPreferences.getString("token");
    }
    return null;
  }

  static Future saveSignup({@required bool? isSignUp}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isSignUp", isSignUp!);
  }

  static Future<bool?> isSignUp() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("isSignUp")) {
      return sharedPreferences.getBool("isSignUp");
    }
    return false;
  }

  // save selected location

}
