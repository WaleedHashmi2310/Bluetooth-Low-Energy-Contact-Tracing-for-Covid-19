import 'package:contact_tracing/stores/login_store.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme.dart';
class Report extends StatefulWidget {
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {

  String _hasBeenPressed;
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
          _hasBeenPressed = 'Yes';
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
            _hasBeenPressed = 'Yes';
          });
        }
        else{
          exists = false;
          setState(() {
            _hasBeenPressed = 'No';
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
              style: TextStyle(fontSize: 20.0, color: Colors.blue),
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
        child: (_hasBeenPressed == null)? CircularProgressIndicator():
        Container(
          child: (_hasBeenPressed == 'No')? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Center(
                  child: Container(
                      constraints: const BoxConstraints(maxHeight: 240),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset('assets/img/Report.png')
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
                            TextSpan(text: 'Tested Positive?', style: TextStyle(color: MyColors.primaryColor, fontSize: 20.0,fontWeight: FontWeight.w500)),
                            TextSpan(text: '\n\nReport infection', style: TextStyle(color: MyColors.primaryColor, fontSize: 16.0,)),
                            TextSpan(text: ' anonymously ', style: TextStyle(color: MyColors.primaryColor, fontSize: 16.0, fontWeight: FontWeight.w500)),
                            TextSpan(text: 'to people you interacted with in the past 2 weeks.', style: TextStyle(color: MyColors.primaryColor, fontSize: 16.0,)),
                          ]),
                        )
                    ),
                  )
              ),
              Container(
                margin: EdgeInsets.all(48),
                child: Column(
                  children: [
                    ButtonTheme(
                      minWidth: 200.0,
                      height: 48.0,
                      child: FlatButton(
                        color: Colors.red,
                        child: Center(child: Text('Report Infection',textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.white))),
                        onPressed: () async{setInfected(user);},
                      ),
                    ),
                    Text('\nInfection Status will be reset after 2 weeks of report date.' ,style: TextStyle(color: Colors.black54), textAlign: TextAlign.center),
                  ],
                ),
              )
            ],
          ): Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Center(
                  child: Container(
                      constraints: const BoxConstraints(maxHeight: 240),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset('assets/img/Positive.png')
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
                            TextSpan(text: 'You have already reported infection!', style: TextStyle(color: MyColors.primaryColor, fontSize: 20.0,fontWeight: FontWeight.w500)),
                            TextSpan(text: '\n\nInfection status will reset after 2 weeks of report date.', style: TextStyle(color: MyColors.primaryColor, fontSize: 16.0,)),
                          ]),
                        )
                    ),
                  )
              ),
            ],
          ),
        ),
      )
    );
  }
}
