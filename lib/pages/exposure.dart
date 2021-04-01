import 'dart:ui';

import 'package:contact_tracing/stores/login_store.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Exposure extends StatefulWidget {
  @override
  _ExposureState createState() => _ExposureState();
}

class _ExposureState extends State<Exposure> {

  bool _hasBeenPressed = true;
  Position _currentPosition;

  String user;
  List<String> infectedID = new List();

  Future<List<String>> queryInfectedPeople() async {
    List<String> infectedList = new List();
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('Infection Status').get();
    final List<DocumentSnapshot> documents = result.docs;
    documents.forEach((docs) => infectedList.add(docs.id));
    return infectedList;
  }

  Future getInfectedPeople() async{
    infectedID = await queryInfectedPeople();
    var collectionID = user;
    infectedID.forEach((infected) {
      var docID = infected;
      bool exists = false;
      try {
        FirebaseFirestore.instance.doc("$collectionID/$docID").get().then((doc) {
          if (doc.exists){
            exists = true;
            print('$docID');
            print('$exists');
          }
          else{
            exists = false;
            print('$docID');
            print('$exists');
          }
        });
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void initState(){
    super.initState();
    _getCurrentLocation();
    user = (LoginStore().getUser().toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getInfectedPeople();
    });
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



  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       backgroundColor: Colors.white,
  //       appBar: AppBar(
  //         title: Text(
  //           'Get Location',
  //         ),
  //         titleSpacing: 0.0,
  //         elevation: 1.0,
  //         automaticallyImplyLeading: true,
  //         leading: IconButton(
  //             icon: Icon(Icons.arrow_back),
  //             // Replace false with location to exit to
  //             onPressed: () {
  //               _getCurrentLocation();}
  //               ),
  //       ),
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           if (_currentPosition != null)
  //             Text(
  //                 "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}"),
  //           FlatButton(
  //             child: Text("Get location"),
  //             onPressed: () {
  //               _getCurrentLocation();
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //
  //   );
  //   }
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('Check for Exposure', style: TextStyle(color:Colors.blue))),
        body: _currentPosition != null ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0.5, 16, 0.5, 0),
              child: new RichText(
                text: new TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: new TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(text: 'Possible Exposure: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                    new TextSpan(text: 'February 25, 2021', ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.0),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.5, 0, 0.5, 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                  child: Container(
                    height: MediaQuery.of(context).size.height/1.5,
                    width: MediaQuery.of(context).size.width/1.1,
                    child: new FlutterMap(
                        options: new MapOptions(
                            center: new LatLng(_currentPosition.latitude, _currentPosition.longitude), minZoom: 16.0),
                        layers: [
                          new TileLayerOptions(
                              urlTemplate:
                              "https://api.mapbox.com/styles/v1/waleedhashmi/ckll230nf20vk17qn0nb77v2j/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoid2FsZWVkaGFzaG1pIiwiYSI6ImNrbGp4ZDFmbDV6ejgycHVpY2UyZzJ0aHEifQ.F4wqj6jwPXtLAYi_lGgHWg",
                              additionalOptions: {
                                'accessToken':
                                'pk.eyJ1Ijoid2FsZWVkaGFzaG1pIiwiYSI6ImNrbGp4ZnZ5djA5Y3YydnAyYThoNDZxY3UifQ.sfSgiCuh4jSrB8-wv7tORw',
                                'id': 'mapbox.mapbox-streets-v7'
                              }),
                          MarkerLayerOptions(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                                builder: (ctx) =>
                                    Container(
                                      child: Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 45.0,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ]),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 0, 7, 8),
              child: Center(child:
              Text('At this location, you were near someone who shared their positive COVID-19 result.', textAlign: TextAlign.center,)
              ),
            ),

          ],
        )
            : Center(child: CircularProgressIndicator()),

    );
  }
}
