import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:background_location/background_location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maskcheck/util/MySlide.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({this.firstCamera});
  final firstCamera;

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String currentScreen;
  bool _onChanged;
  var homeLatitude = 0.0;
  var homeLongitude = 0.0;
  var changeLatitude = 0.0;
  var changeLongitude = 0.0;
  int distanceInMeters = 0;
  int result;
  String num;

  // ignore: cancel_subscriptions
  StreamSubscription<Position> positionStream;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // ignore: missing_return
  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('payload: $payload');
    }
  }

  showNotification(int val) async {
    var android = AndroidNotificationDetails(
        'channel id', 'channel NAME', 'channel description');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'WARNING', 'You are $val' + 'm away from home', platform);
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.grey[800],
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    setState(() {
      currentScreen = '';
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);

    setState(() {
      _onChanged = true;
      currentScreen = 'locationScreen';
    });
    gettingScreen();

    BackgroundLocation.startLocationService();

    BackgroundLocation.getPermissions(
      onGranted: () {
        BackgroundLocation.checkPermissions().then((status) {
          print('the status is: $status');
        });
        BackgroundLocation.getLocationUpdates((_location) {
          setState(() {
            changeLatitude = _location.latitude;
            changeLongitude = _location.longitude;
            liveLocation();
          });
        });
      },
      onDenied: () {
        print('denied');
      },
    );

    liveLocation();
  }

  Future<void> getLocation() async {
    _onChanged = false;
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      homeLatitude = position.latitude;
      homeLongitude = position.longitude;
    });

    showToast('Location set successfully');

    var prefs1 = await SharedPreferences.getInstance();
    var prefs2 = await SharedPreferences.getInstance();
    prefs1.setDouble('homelat', position.latitude);
    prefs2.setDouble('homelon', position.longitude);
  }

  dynamic gettingScreen() async {
    var prefs3 = await SharedPreferences.getInstance();
    var prefs4 = await SharedPreferences.getInstance();

    var lat = prefs3.getDouble('homelat');
    var lon = prefs4.getDouble('homelon');

    if (lat != null && lon != null) {
      setState(() {
        homeLatitude = lat;
        homeLongitude = lon;
        _onChanged = false;
      });
    } else {
      return;
    }
  }

  Future<void> liveLocation() async {
    double distanceInMeters1 = await Geolocator().distanceBetween(
        homeLatitude, homeLongitude, changeLatitude, changeLongitude);

    if (homeLatitude != 0.0 &&
        homeLongitude != 0.0 &&
        changeLatitude != 0.0 &&
        changeLongitude != 0.0) {
      if (distanceInMeters > 50 && distanceInMeters < 70000) {
        int val = distanceInMeters - 50;
        if (currentScreen == 'locationScreen') showNotification(val);
      }
      if (distanceInMeters < 70000) {
        setState(() {
          distanceInMeters = distanceInMeters1.round();
        });
      }
      print('Distance: $distanceInMeters');
    } else {
      setState(() {
        distanceInMeters = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var _onPressed;
    if (_onChanged) {
      _onPressed = () {
        getLocation();
      };
    } else {
      _onPressed = null;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF13161D),
        centerTitle: true,
        title: Text(
          'Mask Check',
          style:
              GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Color(0xDD1C1D1F),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.blueAccent),
              child: Image.asset('images/earth.jpg'),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.all(15),
              height: MediaQuery.of(context).size.height * 0.545,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Color(0xFF282C4F),
              ),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'HOME COORDINATES',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: Text(
                      '$homeLatitude, $homeLongitude',
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      'DISTANCE AWAY\n$distanceInMeters' + ' m',
                      style: GoogleFonts.montserrat(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Tooltip(
                          message: 'Set location',
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                (states) => Color(0xFF13161D),
                              ),
                            ),
                            onPressed: _onPressed,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.add_location,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Reset Coordinates',
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                        (states) => Color(0xFF13161D))),
                            onPressed: () {
                              setState(() {
                                _onChanged = true;
                                homeLatitude = 0.0;
                                homeLongitude = 0.0;
                                distanceInMeters = 0;
                              });
                              showToast('Set coordinates');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.replay,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Tooltip(
                      message: 'Open camera',
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => Color(0xFF13161D),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MySlide(
                              builder: (context) => CameraScreen(
                                camera: widget.firstCamera,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Icon(
                            Icons.camera,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
