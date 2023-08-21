import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:flutter/material.dart';

import '../Model/NameModel.dart';
import '../database_helper.dart';

class SendDataProvider with ChangeNotifier {
  final List<DataModel> _items = [];
  final dbHelper = DatabaseHelper.instance;
  List<DataModel> get items {
    return [..._items];
  }

  Future<void> addName(
      String uid, String gateno, String date, connectionStatus) async {
    int a = 1;
    //print(connectionStatus.toString());
    try {
      if (connectionStatus == true) {
        Response response = await Dio().get(
          //'https://attendance.svms.live/rfid/get?rfiddata=${gateno}_${uid}_$date',
          'http://192.168.10.5/rfid/rfid/get?rfiddata=${gateno}_${uid}_$date',
          
          
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          // data: jsonEncode(
          //     <String, dynamic>{"name": text.toString(), "status": a}),
        );
        // final http.Response response = await http.post(
        //   ' http://localhost/SqliteSync/saveName.php',
        //   headers: <String, String>{
        //     'Content-Type': 'application/json; charset=UTF-8',
        //   },
        //   body: jsonEncode(<String, dynamic>{
        //     "name": text.toString(),
        //     "status": a
        //   }),
        // );
        if (response.statusCode == 200) {
          String? body = response.statusMessage;
          print(body);
          // Map<String, dynamic> row = {
          //   DatabaseHelper.columnDate: text.toString(),
          //   DatabaseHelper.status: 1,
          // };
          //await dbHelper.insert(row);
        } else {
          //print('Request failed with status: ${response.statusCode}.');
          addRowOffline(uid, gateno, date);
        }
      } else {
        addRowOffline(uid, gateno, date);
        //print('inserted row id: $id');
      }

      notifyListeners();
    } catch (error) {
      addRowOffline(uid, gateno, date);
      throw (error);
    }
  }

  Future<void> addRowOffline(String uid, String gateNo, String dt) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: uid.toString(),
      DatabaseHelper.columnGate: gateNo,
      DatabaseHelper.columnDate: dt,
      DatabaseHelper.status: 0,
    };
    final id = await dbHelper.insert(row);
  }

  Future<void> sync(
      String uid, String gateno, String date, connectionStatus) async {
    try {
      if (connectionStatus == true) {
        Response response = await Dio().get(
          // 'https://attendance.svms.live/rfid/get?rfiddata=${gateno}_${uid}_$date',
          'http://192.168.10.5/rfid/get?rfiddata=${gateno}_${uid}_$date',
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          // data: jsonEncode(
          //     <String, dynamic>{"name": text.toString(), "status": a}),
        );
        if (response.statusCode == 200) {
          String? body = response.statusMessage;
          print(body);
        } else {
          print('Request failed with status: ${response.statusCode}.');
        }
      } else {}

      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
