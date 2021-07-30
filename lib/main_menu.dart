import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/account.dart';
import 'package:watch_it/links/baserurl.dart';
import 'package:watch_it/logs.dart';
import 'package:watch_it/main.dart';
import 'package:watch_it/med2.dart';
import 'package:watch_it/medications.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/statics.dart';
import 'package:watch_it/notification_time.dart';
import 'package:watch_it/pair_screen.dart';
import 'package:watch_it/settings.dart';
import 'package:wear/wear.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key, this.pname, this.pemail}) : super(key: key);
  static String id = 'main_menu';
  final String? pname;
  final String? pemail;

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with WidgetsBindingObserver {
  WearShape? Nshape;
  bool _isInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    Timer.periodic(Duration(seconds: 10), timerCallBack);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
    ePrint('In main menu: state is $state at ${DateTime.now()}');
    // showToast();
    switch (state) {
      case AppLifecycleState.resumed:
        setForegroundServis();
        print("app in resumed//////////////////////");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive////////////////////////");
        break;
      case AppLifecycleState.paused:
        print("app in paused////////////////////////");
        break;
      case AppLifecycleState.detached:
        print("app in detached////////////////////");
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.all(Nshape == WearShape.round ? 8.0 : 0.0),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.transparent,
          tooltip: 'I am in Emergency.',
          onPressed: () {
            getLocation();
          },
          child: Material(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(32),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/emergencybell.png',
                fit: BoxFit.cover,
                scale: 8,
              ),
            ),
          ),
          // Icon(
          //   Icons.mobile_screen_share_rounded,
          //   // Icons.task_alt,
          //   // size: 30,
          //   color: Colors.white,
          // ),
        ),
      ),
      backgroundColor: Colors.black,
      body: WatchShape(
        builder: (context, shape, child) {
          Nshape = shape;
          return Container(
            width: Get.width,
            height: Get.height,
            // padding: shape == WearShape.round
            //     ? EdgeInsets.symmetric(
            //         vertical: 10,
            //         horizontal: 10,
            //       )
            //     : EdgeInsets.symmetric(
            //         vertical: 10,
            //         horizontal: 10,
            //       ),
            decoration: BoxDecoration(
              borderRadius: shape == WearShape.round
                  ? BorderRadius.circular(100)
                  : BorderRadius.circular(10),
            ),
            child: ListView(
              children: [
                Material(
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          'Watch It',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.pname!,
                          // 'John Doe',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.pemail!,
                          // 'Johndoe@email.com',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (context) => Medicat(),
                      ),
                    );
                  },
                  child: MenuButton(
                    shape: shape,
                    text: tr('medication list'),
                    icon: Icons.list,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Logs.id,
                    );
                  },
                  child: MenuButton(
                    shape: shape,
                    text: tr('3 days log'),
                    icon: Icons.chat_rounded,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Settings.id,
                    );
                  },
                  child: MenuButton(
                    shape: shape,
                    text: tr('settings'),
                    icon: Icons.settings,
                  ),
                ),
                SizedBox(height: shape == WearShape.round ? 20 : 0),
              ],
            ),
          );
        },
        child: AmbientMode(
          builder: (context, mode, child) {
            return Text(
              'Mode: ${mode == WearMode.active ? 'Active' : 'Ambient'}',
            );
          },
        ),
      ),
    );
  }

  Future<void> getLocation() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        // Permission.accessMediaLocation,
      ].request();
      print(statuses[Permission.location]);
    }

// You can can also directly ask the permission about its status.
    if (await Permission.location.isRestricted) {
      // The OS restricts access, for example because of parental controls.
      print('location acces is restrictd');
    }
    print('position get started');
    // _determinePosition();
    Position? position = await Geolocator.getCurrentPosition();

    // position = _determinePosition() as Position?;
    print(position.latitude);
    emergencyAlertStatus(
        'Patient is in Emergency', position.latitude, position.longitude);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> emergencyAlertStatus(
    String text,
    double latitude,
    double longitude,
  ) async {
    // debugPrint('Longitude...=$longitude Latitude...=$latitude');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String patientCode = sharedPreferences.getString('p_code')!;
    var url = Uri.parse('${BaseUrl.baseurl}/api/emergency/$patientCode');
    // 'http://watchit-project.eu/api/emergency/$patientCode');
    final response = await post(url, body: {
      "text": text,
      "lat": latitude.toString(),
      "lng": longitude.toString()
    });
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print(response.body);
    }
  }

  Future<bool?> showTost() {
    return Fluttertoast.showToast(
      msg: "This is Center Short Toast",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> timerCallBack(Timer timer) async {
    ePrint('In MainMenu: callback is called at ${DateTime.now()}');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool("isDoseTime") != null) {
      var isDoseTime = sharedPreferences.getBool("isDoseTime");
      var a = Parameters.isDozeTime;
      ePrint('In MainMenu: a is equal to $a.');

      if (isDoseTime!) {
        ePrint('In MainMenu: It\'s a dosetime bcz isDoseTime is $isDoseTime.');
        Get.offAll(NotificationTime());
      } else {
        ePrint(
            'In MainMenu:  It\'s not a dosetime bcz isDoseTime is $isDoseTime.');
      }
    }
  }

  Future<void> setForegroundServis() async {
    var isRunning = await FlutterBackgroundService().isServiceRunning();
    if (isRunning) {
      FlutterBackgroundService().sendData(
        {"action": "setAsForeground"}, // {"action": "stopService"},
      );
    } else {
      // FlutterBackgroundService.initialize(onStart);
    }
  }
}

class MenuButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final WearShape? shape;
  const MenuButton({
    this.shape,
    this.text,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Container(
        padding: EdgeInsets.only(
          top: 0,
          bottom: 10,
          left: shape == WearShape.round ? 30 : 8,
          right: 10,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey,
              child: Icon(
                icon!,
                //Icons.list,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text!,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
