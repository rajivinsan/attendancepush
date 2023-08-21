import 'dart:async';
import 'package:attendance_system/Providers/local_db_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter/material.dart';
import 'Providers/SendNameProvider.dart';
import 'database_helper.dart';
import 'package:provider/provider.dart';
import 'Providers/SendNameProvider.dart';
import 'database_helper.dart';

import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';

class Loginscreen extends StatefulWidget {
  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  List Data = [];
  // homepage layout
  int unsyncrecord = 0;
  int syncrecord = 0;
  String lastsync = "";

  late bool connectionStatus;
  bool showkeyboard = false;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  List<String> list = [];

  TextEditingController textid = TextEditingController();
  final FocusNode uidCtrlFocusNode = FocusNode();

  Future<int?> queryRowCount() async {
    var countData = await dbHelper.queryRowCount();
    setState(() {
      unsyncrecord = countData!;
    });

    return countData;
  }

  String? gateNumber = "1";
  Future<void> GateNumber() async {
    String? number = await LocaldbHelper.gateNo();
    setState(() {
      gateNumber = number;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    //GateNumber();
    queryRowCount();
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  _syncitnow(connectionStatus) async {
    final nameProvider = Provider.of<SendDataProvider>(context, listen: false);
    if (connectionStatus == true) {
      var allRows = await dbHelper.queryUnsynchedRecords();
      allRows.forEach((row) async {
        await nameProvider.sync(
            row['id'], row['gateno'].toString(), row['date'], connectionStatus);
        delete(row['id']);
        //update(row['id'], row['gateno'], row['date']);
        lastsync = DateTime.now().toString().substring(0, 15);
      });

      setState(() {});
    }
  }

  void delete(String id) async {
    // Assuming that the number of rows is the id for the last row.
    //final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');

    setState(() {});
  }

  void update(id, gateno, date) async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnGate: gateno,
      DatabaseHelper.columnDate: date,
      DatabaseHelper.status: 1
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  void reqSubmit(value) {
    list.add(value);
    textid.text = value;

    setState(() {
      SendDataProvider()
          .addName(
              value,
              gateNumber!,
              '${DateFormat('dd-MM-yyyy').format(DateTime.now())}_${DateFormat('HH:mm:ss').format(DateTime.now())}',
              connectionStatus)
          .then((value) {
        queryRowCount();
      });
      textid.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Color.fromARGB(255, 226, 205, 173),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text('Online Attendance System')),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            OfflineBuilder(
              connectivityBuilder: (
                BuildContext context,
                ConnectivityResult connectivity,
                Widget child,
              ) {
                connectionStatus = connectivity != ConnectivityResult.none;
                if (connectionStatus) {
                  _syncitnow(connectionStatus);
                }

                return Stack(children: [
                  child,
                  connectionStatus
                      ? Container(
                          color: Colors.greenAccent,
                          child: const Center(
                              child: Text(
                            "Status : Online",
                            style: TextStyle(fontSize: 20),
                          )))
                      : Container(
                          color: Colors.redAccent,
                          child: const Center(
                              child: Text(
                            "Status : offline",
                            style: TextStyle(fontSize: 20),
                          )))
                ]);
              },
              builder: (BuildContext context) {
                return SizedBox();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(child: Image.asset("assets/svms.png", width: 300)),
            ),
            Center(
              child: Text(
                "Gate :$gateNumber",
                style: TextStyle(fontSize: 20),
              ),
            ),
            BarcodeKeyboardListener(
                bufferDuration: Duration(milliseconds: 200),
                onBarcodeScanned: (barcode) {
                  reqSubmit(barcode);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextField(
                    controller: textid,
                    autofocus: false,
                    //focusNode: uidCtrlFocusNode,

                    keyboardType: showkeyboard
                        ? TextInputType.number
                        : TextInputType.none,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: showkeyboard
                            ? Icon(Icons.keyboard_alt_outlined)
                            : Icon(Icons.keyboard_hide_outlined),
                        onPressed: () {
                          setState(() {
                            showkeyboard = !showkeyboard;
                            FocusScope.of(context)
                                .requestFocus(uidCtrlFocusNode);
                          });
                        },
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'Enter Attendance id',
                    ),
                    onSubmitted: (value) {
                      //FocusScope.of(context).requestFocus(uidCtrlFocusNode);
                      reqSubmit(value);
                    },
                  ),
                )),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          //leading: const Icon(Icons.list),
                          trailing: Text(
                            DateTime.now().toString().substring(0, 16),
                          ),
                          title: Text(list[(list.length - 1) - index]));
                    }),
              ),
            ),
            Center(
              child: Text(
                "Offline Record :$unsyncrecord",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                  child: Text(
                    "Last Sync :$lastsync",
                    style: TextStyle(fontSize: 15),
                  )),
            ),
          ],
        ));
  }
}
