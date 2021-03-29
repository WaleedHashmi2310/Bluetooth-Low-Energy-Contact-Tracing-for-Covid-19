import 'dart:async';
import 'dart:io';

import 'package:contact_tracing/pages/report.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';

import 'app_scanning.dart';
import 'app_broadcasting.dart';
import 'package:contact_tracing/stores/login_store.dart';
import '../controller/requirement_state_controller.dart';
import 'exposure.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {

  final controller = Get.find<RequirementStateController>();
  StreamSubscription<BluetoothState> _streamBluetooth;
  int currentIndex = 0;

  var obj = LoginStore();
  var user;


  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    user = obj.firebaseUser;

    super.initState();

    listeningState();
  }

  listeningState() async {
    print('Listening to bluetooth state');
    _streamBluetooth = flutterBeacon
        .bluetoothStateChanged()
        .listen((BluetoothState state) async {
      controller.updateBluetoothState(state);
      await checkAllRequirements();
    });
  }

  checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;
    controller.updateBluetoothState(bluetoothState);
    print('BLUETOOTH $bluetoothState');

    final authorizationStatus = await flutterBeacon.authorizationStatus;
    controller.updateAuthorizationStatus(authorizationStatus);
    print('AUTHORIZATION $authorizationStatus');

    final locationServiceEnabled =
    await flutterBeacon.checkLocationServicesIfEnabled;
    controller.updateLocationService(locationServiceEnabled);
    print('LOCATION SERVICE $locationServiceEnabled');

    if (controller.bluetoothEnabled &&
        controller.authorizationStatusOk &&
        controller.locationServiceEnabled) {
      print('STATE READY');
      if (currentIndex == 0) {
        print('SCANNING');
        controller.startScanning();
      } else {
        print('BROADCASTING');
        controller.startBroadcasting();
      }
    } else {
      print('STATE NOT READY');
      controller.pauseScanning();
    }
  }

  @override
  void dispose() {
    _streamBluetooth?.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState = $state');
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null && _streamBluetooth.isPaused) {
        _streamBluetooth.resume();
      }
      await checkAllRequirements();
    } else if (state == AppLifecycleState.paused) {
      _streamBluetooth?.pause();
    }
  }


  @override
  Widget build(BuildContext context) {

    return Consumer<LoginStore>(
        builder: (_, loginStore, __) {
          return Scaffold(
            backgroundColor: Colors.white,
              drawer: Drawer(
                // Add a ListView to the drawer. This ensures the user can scroll
                // through the options in the drawer if there isn't enough vertical
                // space to fit everything.
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    // Important: Remove any padding from the ListView.
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                      ),
                      ListTile(
                          leading: Icon(Icons.label_important_outlined),
                          title: Text('Report Infection'),
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Report()),
                            ),
                          }
                      ),
                      ListTile(
                          leading: Icon(Icons.label_important_outlined),
                          title: Text('Check for Exposure'),
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Exposure()),
                            ),
                          }
                      ),

                      ListTile(
                          leading: Icon(Icons.exit_to_app, color: Colors.red[400],),
                          title:Text('Sign Out', style: TextStyle(color: Colors.red[400]),),
                          onTap: () {
                            loginStore.signOut(context);
                          }
                      ),

                    ],
                  ),
                ),
              ),
              appBar: AppBar(
                title: Text(
                    'CovTrace',
                    style: TextStyle(fontSize: 20.0, color: Colors.blue),
                ),
              centerTitle: false,
              actions: <Widget>[
                Obx(() {
                  if (!controller.locationServiceEnabled)
                    return IconButton(
                      tooltip: 'Not Determined',
                      icon: Icon(Icons.portable_wifi_off),
                      color: Colors.grey,
                      onPressed: () {},
                    );

                  if (!controller.authorizationStatusOk)
                    return IconButton(
                      tooltip: 'Not Authorized',
                      icon: Icon(Icons.portable_wifi_off),
                      color: Colors.red,
                      onPressed: () async {
                        await flutterBeacon.requestAuthorization;
                      },
                    );

                  return IconButton(
                    tooltip: 'Authorized',
                    icon: Icon(Icons.wifi_tethering),
                    color: Colors.blue,
                    onPressed: () async {
                      await flutterBeacon.requestAuthorization;
                    },
                  );
                }),
                Obx(() {
                  return IconButton(
                    tooltip: controller.locationServiceEnabled
                        ? 'Location Service ON'
                        : 'Location Service OFF',
                    icon: Icon(
                      controller.locationServiceEnabled
                          ? Icons.location_on
                          : Icons.location_off,
                    ),
                    color:
                    controller.locationServiceEnabled ? Colors.blue : Colors.red,
                    onPressed: controller.locationServiceEnabled
                        ? () {}
                        : handleOpenLocationSettings,
                  );
                }),
                Obx(() {
                  final state = controller.bluetoothState.value;

                  if (state == BluetoothState.stateOn) {
                    return IconButton(
                      tooltip: 'Bluetooth ON',
                      icon: Icon(Icons.bluetooth_connected),
                      onPressed: () {},
                      color: Colors.blue,
                    );
                  }

                  if (state == BluetoothState.stateOff) {
                    return IconButton(
                      tooltip: 'Bluetooth OFF',
                      icon: Icon(Icons.bluetooth),
                      onPressed: handleOpenBluetooth,
                      color: Colors.red,
                    );
                  }

                  return IconButton(
                    icon: Icon(Icons.bluetooth_disabled),
                    tooltip: 'Bluetooth State Unknown',
                    onPressed: () {},
                    color: Colors.grey,
                  );
                }),

                // IconButton(
                //   icon: Icon(Icons.logout),
                //   tooltip: 'Sign Out',
                //   onPressed: () {
                //     loginStore.signOut(context);
                //   },
                //   color: Colors.grey,
                // ),

              ],
            ),
            body: Column(
              children: [
                Scan(),
                Broadcast(),
              ],
            )
          );
        }
    );
  }

  handleOpenLocationSettings() async {
    if (Platform.isAndroid) {
      await flutterBeacon.openLocationSettings;
    } else if (Platform.isIOS) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Location Services Off'),
            content: Text(
              'Please enable Location Services on Settings > Privacy > Location Services.',
            ),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  handleOpenBluetooth() async {
    if (Platform.isAndroid) {
      try {
        await flutterBeacon.openBluetoothSettings;
      } on PlatformException catch (e) {
        print(e);
      }
    } else if (Platform.isIOS) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Bluetooth is Off'),
            content: Text('Please enable Bluetooth on Settings > Bluetooth.'),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
