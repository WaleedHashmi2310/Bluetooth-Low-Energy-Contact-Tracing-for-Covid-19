import 'package:contact_tracing/stores/login_store.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Report extends StatefulWidget {
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {

  bool _hasBeenPressed = false;
  String user;

  Future<void> setInfected(String docID) async{
    bool exists = false;
    String collectionID = 'Infection Status';
    try {
      FirebaseFirestore.instance.doc("$collectionID/$docID").get().then((doc) {
        if (doc.exists){
          exists = true;
          FirebaseFirestore.instance.collection('$collectionID').doc('$docID').update({
            'isInfected':true
          });
        }
        else{
          exists = false;
          FirebaseFirestore.instance.collection('$collectionID').doc('$docID').set({
            'isInfected':true
          });
        }
        setState(() {
          _hasBeenPressed = true;
        });
      });
    } catch (e) {
      print(e);
    }

  }

  @override
  void initState() {
    super.initState();
    var obj = LoginStore();
    bool exists = false;
    user = (obj.getUser().toString());
    String collectionID = 'Infection Status';
    try {
      FirebaseFirestore.instance.doc("$collectionID/$user").get().then((doc) {
        if (doc.exists){
          exists = true;
          setState(() {
            _hasBeenPressed = true;
          });
        }
        else{
          exists = false;
          setState(() {
            _hasBeenPressed = false;
          });
        }
      });
    } catch (e) {
      print(e);
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
              'Report Infection',
            style: TextStyle(color: Colors.blue),
          ),
          titleSpacing: 0.0,
          elevation: 0.0,
          automaticallyImplyLeading: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              // Replace false with location to exit to
              onPressed: () => Navigator.pop(context)),
        ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: 200, height: 200),
              child: _hasBeenPressed? Text('Take Care') : MaterialButton(
                color: Colors.blue,
                child: Center(child: Text('Report Infection',textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.white))),
                shape: CircleBorder(),
                onPressed: () async{setInfected(user);},
              ),
            ),
          ],
        ),
      )
    );
  }
}
