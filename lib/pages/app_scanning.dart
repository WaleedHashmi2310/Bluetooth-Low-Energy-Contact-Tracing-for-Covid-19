import 'package:contact_tracing/pages/app_broadcasting.dart';
import 'package:contact_tracing/stores/login_store.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../controller/requirement_state_controller.dart';
import 'dart:convert';

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  String user;
  var _beaconResult = new Map();
  var _listResult;
  int _nrMessaggesReceived = 0;
  var isRunning = true;
  Position _currentPosition;
  List myData;

  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();

  final controller = Get.find<RequirementStateController>();

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    beaconEventsController.close();
    super.dispose();
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {

    var obj = LoginStore();
    user = (obj.getUser().toString());

    // bool docExists = await checkIfDocExists(s.toString());

    await BeaconsPlugin.startMonitoring;

    BeaconsPlugin.listenToBeacons(beaconEventsController);

    // await BeaconsPlugin.addRegion(
    //     "BeaconType1", "909c3cf9-fc5c-4841-b695-380958a51a5a");
    // await BeaconsPlugin.addRegion(
    //     "BeaconType2", "6a84c716-0f2a-1ce9-f210-6a63bd873dd9");

    beaconEventsController.stream.listen(
        (data) {
          if (data.isNotEmpty || _currentPosition != null) {
            setState(() {
              _beaconResult = json.decode(data);
              _listResult = _beaconResult.values.toList();
              _nrMessaggesReceived++;
            });
            print("Beacons DataReceived: " +
                (data));

            var otherUser = _listResult[1];
            var otherUserID = otherUser.substring(otherUser.length - 12);

            myData = [{'scanTime': _listResult[7], 'distance': _listResult[5], 'proximity': _listResult[6],
            'latitude':_currentPosition.latitude, 'longitude': _currentPosition.longitude }];

            var collectionID = user;
            var docID = otherUserID;
            bool exists = false;
            try {
              FirebaseFirestore.instance.doc("$collectionID/$docID").get().then((doc) {
                if (doc.exists){
                  exists = true;
                  FirebaseFirestore.instance.collection('$collectionID').doc('$docID').update({
                    'interactions': FieldValue.arrayUnion(myData),
                  });
                }
                else{
                  exists = false;
                  FirebaseFirestore.instance.collection('$collectionID').doc('$docID').set({
                    'interactions': FieldValue.arrayUnion(myData),
                  });
                }

              });
            } catch (e) {
              print(e);
            }

            // var majorID = 12;
            // var docExists = await checkIfDocExists(majorID.toString(),_listResult[3]);
            // bool docExists = true;
            // if (!docExists){
            //   FirebaseFirestore.instance.collection(majorID.toString()).doc(_listResult[3]).set({
            //     'interactions': FieldValue.arrayUnion(myData),
            //   });
            // }else{
            //   FirebaseFirestore.instance.collection(majorID.toString()).doc(_listResult[3]).update({
            //     'interactions': FieldValue.arrayUnion(myData),
            //   });
            // }
          }
        },
        onDone: () {},
        onError: (error) {
          print("Error: $error");
        });

    //Send 'true' to run in background
    await BeaconsPlugin.runInBackground(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginStore>(
        builder: (_, loginStore, __) {
          return Padding(
            padding: const EdgeInsets.all(0.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(),
                  // Text('$myData' ,style: TextStyle(fontSize: 16.0, color: Colors.black)),
                  // // if (_currentPosition != null) Text(
                  // //     "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}"),
                  // Padding(
                  //   padding: EdgeInsets.all(10.0),
                  // ),
                  // Text('$_nrMessaggesReceived', style: TextStyle(color: Colors.red)),
                  // Container(
                  //   height: MediaQuery.of(context).size.height/1.16,
                  //   width: MediaQuery.of(context).size.width/1.16,
                  //   decoration: BoxDecoration(
                  //     image: DecorationImage(
                  //         image: AssetImage("assets/img/home1.png"), fit: BoxFit.contain),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        }
    );
  }
}
