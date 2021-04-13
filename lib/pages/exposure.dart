import 'dart:ui';
import 'package:contact_tracing/stores/login_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme.dart';

class Exposure extends StatefulWidget {
  @override
  _ExposureState createState() => _ExposureState();
}

class _ExposureState extends State<Exposure> {

  String date;
  List<String> results = new List();
  var _currentPosition;
  String user;
  String exposure = 'None';

  Future<List<String>> queryInfectedPeople() async {
    List<String> infectedQuery = new List();
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('Infection Status').get();
    final List<DocumentSnapshot> documents = result.docs;
    documents.forEach((docs) => infectedQuery.add(docs.id));
    return infectedQuery;
  }


  Future<List<String>> checkForExposure() async{
    List<String> infectedList  = await queryInfectedPeople();
    List<String> infectedInteraction = new List();
    if (infectedList.isEmpty == false){
      var collectionID = user;
      bool exists = false;
      for (var infected in infectedList){

          if (infected == user && (infectedList.length)==1){
            setState(() {
              exposure = 'No';
            });
            break;
          }

          if (infected != user){
            var docID = infected;
            try {
              await FirebaseFirestore.instance.doc("$collectionID/$docID").get().then((doc){
                if (doc.exists) {
                  setState(() {
                    exposure = 'Yes';
                  });
                  exists = true;
                  infectedInteraction.add(docID);
                }
                else {
                  if (exists != true){
                    setState(() {
                      exposure = 'No';
                    });
                  }
                }
              });
            } catch (e) {
              print(e);
            }
          }
      }
    }
    else{
      setState(() {
        exposure = 'No';
      });
    }
    return infectedInteraction;
  }

  Future<void> getResults() async{
    List<String> infectedInteraction = await checkForExposure();
    if (infectedInteraction.isEmpty == false){
      var collectionID = user;
      var docID = infectedInteraction[((infectedInteraction.length)-1)];
      await FirebaseFirestore.instance.doc("$collectionID/$docID").get().then((doc){
        if (doc.exists) {
          var len = (doc.data()['interactions']).length;
          var x = doc.data()['interactions'][len-1];
          results.add((x['longitude']).toString());
          results.add((x['latitude']).toString());
          date = x['scanTime'];
          date = date.substring(0, date.length-12);
        }
        else {
          print('Error');
        }
      });
    }
  }



  void myFunc() async {
    var x = checkForExposure();
    await x;
    await getResults();
    if (results.isEmpty == false){
      var long = double.parse(results[0]);
      var lat = double.parse(results[1]);
      setState(() {
        _currentPosition = [long, lat];
      });
      print(_currentPosition);
    }

  }

  @override
  void initState(){
    super.initState();
    user = (LoginStore().getUser().toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      myFunc();
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('Check for Exposure', style: TextStyle(fontSize: 20.0, color: Colors.blue))),
        body: (_currentPosition != null && exposure == 'Yes')  ? Column(
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
                    new TextSpan(text: 'Potential Exposure: ', style: new TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                    new TextSpan(text: '$date', style: new TextStyle(fontSize: 18.0)),
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
                            center: new LatLng(_currentPosition[1], _currentPosition[0]), minZoom: 16.0),
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
                                point: LatLng(_currentPosition[1], _currentPosition[0]),
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
              Text('At this location, you were near someone who shared their positive COVID-19 result.', textAlign: TextAlign.center, style: new TextStyle(fontSize: 16.0))
              ),
            ),

          ],
        )
            : Center(child: (exposure == 'No')?
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Center(
                    child: Container(
                        constraints: const BoxConstraints(maxHeight: 240),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Image.asset('assets/img/Exposure.png')
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  //margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Container(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(children: <TextSpan>[
                            TextSpan(text: 'We couldn\'t find a potential exposure in our records.', style: TextStyle(color: MyColors.primaryColor, fontSize: 20.0, fontWeight: FontWeight.w400)),
                          ]),
                        )
                      ),
                    )
                )
              ],
            ):
            CircularProgressIndicator(),
        ),

    );
  }
}
