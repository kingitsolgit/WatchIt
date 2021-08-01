import 'dart:async';
import 'dart:convert';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:app_launcher/app_launcher.dart';
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
import 'package:watch_it/medications_list.dart';
import 'package:watch_it/medications.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/meducine.dart';
import 'package:watch_it/model/myservices.dart';
import 'package:watch_it/model/prescription.dart';
import 'package:watch_it/model/snoozedmedicine.dart';
import 'package:watch_it/model/statics.dart';
import 'package:watch_it/notification_time.dart';
import 'package:watch_it/pair_screen.dart';
import 'package:watch_it/settings.dart';
import 'package:wear/wear.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key, this.pname, this.pemail, this.pcode})
      : super(key: key);
  static String id = 'main_menu';
  final String? pname;
  final String? pemail;
  final String? pcode;

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with WidgetsBindingObserver {
  WearShape? Nshape;
  bool _isInForeground = true;
  int alarmID = 1;

  @override
  initState() {
    super.initState();
    ePrint('pcode is ${widget.pcode}');
    WidgetsBinding.instance!.addObserver(this);
    // Timer.periodic(Duration(seconds: 10), ontMainMenuCallBack());
    // WidgetsFlutterBinding.ensureInitialized();
    // FlutterBackgroundService.initialize(onStartMainMenu);
    callBack1();
  }

  callBack1() {
    Timer.periodic(Duration(seconds: 57), (timer) {
      myCallBack();
    });
    ePrint('In callBack1');
  }

/*
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
    ePrint('In main menu: state is $state at ${DateTime.now()}');
    // showToast();
    switch (state) {
      case AppLifecycleState.resumed:
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
*/
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    ePrint('In build method pcode is ${widget.pcode}');
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
        ),
      ),
      backgroundColor: Colors.black,
      body: WatchShape(
        builder: (context, shape, child) {
          Nshape = shape;
          return Container(
            width: Get.width,
            height: Get.height,
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

  Future<dynamic> onStartMainMenu() async {
    WidgetsFlutterBinding.ensureInitialized();
    final service = FlutterBackgroundService();
    service.setForegroundMode(true);
    Timer.periodic(
      Duration(seconds: 5),
      (timer) async {
        ePrint('In mainmenu foreground service');
        var isRunning = await FlutterBackgroundService().isServiceRunning();
      },
    );
  }

  onMainMenuCallBack() async {
    List<String> dosingList = [];
    ePrint(
        ' In MainMenu ontMainMenuCallBack Function Start Time ${DateTime.now()}');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('p_code') != null) {
      String? pcode = sharedPreferences.getString('p_code')!;
      var url =
          Uri.parse('${BaseUrl.baseurl}/api/patients/${pcode}/prescriptions');
      final response = await get(url);
      if (response.statusCode == 200) {
        ePrint(response.body);
        print(akbarPrescription); //in service file
        var responc = Prescription.fromJson(jsonDecode(response.body));
        DateFormat dateFormating = DateFormat("dd-MM-yyyy HH:mm");
        // List<String> dosingList = [];
        for (var i = 0; i < responc.data!.length; i++) {
          List<MedicineTime>? medicineTime = responc.data![i].medicineTime;
          for (var j = 0; j < medicineTime!.length; j++) {
            String timeString =
                medicineTime[j].date! + ' ' + medicineTime[j].time!;
            Data preData = responc.data![i];
            DateTime myDT = dateFormating.parse(timeString);
            myDT.subtract(Duration(minutes: 1));
            ePrint('myDT $myDT');
            DateTime now = DateTime.now();
            if (now.year == myDT.year &&
                now.month == myDT.month &&
                now.day == myDT.day) {
              debugPrint('Day is same');
              if (now.hour == myDT.hour && now.minute == myDT.minute) {
                debugPrint('time is also same');
                ePrint('at index $i and $j');
                sharedPreferences.setBool("isDoseTime", true);
                Meducine meducine = Meducine(
                  medicineId: preData.sId,
                  medicineName: preData.medicineName,
                  dailyDosePill: preData.dailyDosePill,
                  medicineTime: preData.medicineTime![j].date! +
                      ' ' +
                      preData.medicineTime![j].time!,
                  medicinetimeindex: preData.medicineTime![j].id!,
                  dateRange: preData.doseTimeDuration,
                );
                String jsonn = jsonEncode(meducine);
                dosingList.add(jsonn);
                sharedPreferences.setStringList('dosingList', dosingList);
                // await AppLauncher.openApp(
                //     androidApplicationId: "com.example.watch_it");
              } else {
                ePrint('time is not same');
                // sharedPreferences.setBool("isDoseTime", false);
              }
            } else {
              ePrint('day is not same');
              // sharedPreferences.setBool("isDoseTime", false);
            }
          }
        }
        // if (dosingList.isNotEmpty) {
        //   Get.offAll(NotificationTime());
        //   // Get.offAll(AccountScreen());
        // } else {
        //   sharedPreferences.setBool("isDoseTime", false);
        //   ePrint('In MainMenu: dosing list is empty');
        // }
        ///////////code start for next doses
        List<String> nextDoseList = [];
        sharedPreferences.remove('nextDoseList');
        ePrint(' In MainMenu nextDoseList is removed');
        for (var i = 0; i < responc.data!.length; i++) {
          Data prescriptionData = responc.data![i];
          List<MedicineTime>? medicineTime = prescriptionData.medicineTime;
          for (var j = 0; j < medicineTime!.length; j++) {
            /////////////////   New code for next doses
            String timeInString =
                medicineTime[j].date! + ' ' + medicineTime[j].time!;
            DateFormat newdateFormating = DateFormat("dd-MM-yyyy HH:mm");

            DateTime newDT = newdateFormating.parse(timeInString);
            // ePrint('newDT $newDT');
            if (newDT.isAfter(DateTime.now())) {
              // ePrint('time isAfter from now');
              Meducine meducine = Meducine(
                medicineId: prescriptionData.sId,
                medicineName: prescriptionData.medicineName,
                dailyDosePill: prescriptionData.dailyDosePill,
                medicineTime: prescriptionData.medicineTime![j].date! +
                    ' ' +
                    prescriptionData.medicineTime![j].time!,
                medicinetimeindex: prescriptionData.medicineTime![j].id!,
                dateRange: prescriptionData.doseTimeDuration,
              );
              String meducineString = jsonEncode(meducine);
              // ePrint('Next doses Encoded $meducineString end the');
              nextDoseList.add(meducineString);
              // ePrint(nextDoseList);
              sharedPreferences.setStringList('nextDoseList', nextDoseList);
              ePrint(' In MainMenu next dose added');
              j = medicineTime.length - 1;
            }
            // setAsNextMedicines(myDT,responc);

          }
        }
        ///////////////////code ending for next doses

        /////////////////////////////////for snooze list checking

        if (sharedPreferences.getStringList('snoozedList') != null) {
          List<String>? snoozedList =
              sharedPreferences.getStringList('snoozedList');
          ePrint(' In MainMenu list assigned of ${snoozedList!.length} length');
          for (var i = 0; i < snoozedList.length; i++) {
            ePrint(' In MainMenu snooz loop started////////////////////');
            ePrint(' In MainMenu list obj $i is ${snoozedList[i]}');
            Map<String, dynamic> dosingMaplistobj = jsonDecode(snoozedList[0]);
            var snoozedMed = SnoozedMedicine.fromJson(dosingMaplistobj);
            ePrint(
                ' In MainMenu snoozedmedicinename: ${snoozedMed.name}, snoozedmedicinetime:  ${snoozedMed.dosetime}');
            DateFormat newdateFormating = DateFormat("dd-MM-yyyy HH:mm");
            DateTime snoozedDT = newdateFormating.parse(snoozedMed.dosetime!);
            // ///////////////new if structure start
            if (snoozedMed.snoozedIteration != null &&
                snoozedMed.snoozedIteration! < 3) {
              if (DateTime.now().hour.compareTo(snoozedDT.hour) == 0) {
                ePrint(' In MainMenu snooze hour is same');
                if (DateTime.now().minute.compareTo(snoozedDT.minute) == 0) {
                  ePrint('snooze minute is also same');
                  print('at index $i and j');
                  sharedPreferences.setBool("isDoseTime", true);
                  ////////  new code start here
                  print(' In MainMenu dosing list $dosingList');
                  Meducine meducine = Meducine(
                    medicineId: snoozedMed.id, // preData.sId,
                    medicineName: snoozedMed.name, //preData.medicineName,
                    dailyDosePill: snoozedMed.routine, //preData.dailyDosePill,
                    medicineTime: snoozedMed
                        .dosetime, //preData.medicineTime![j].date! + ' ' + preData.medicineTime![j].time!,
                    medicinetimeindex:
                        snoozedMed.timeIndex, //preData.medicineTime![j].id!,
                    dateRange: snoozedMed.dosetime, // preData.doseTimeDuration,
                  );
                  String jsonn = jsonEncode(meducine);
                  print(' In MainMenu encoded jsonn $jsonn');
                  dosingList.add(jsonn);
                  print(' In MainMenu dosing list $dosingList');
                  sharedPreferences.setStringList('dosingList', dosingList);
                  // await AppLauncher.openApp(
                  //     androidApplicationId: "com.example.watch_it");
                } else {
                  debugPrint(' In MainMenu minute is also not same');
                  // sharedPreferences.setBool("isDoseTime", false);
                }
              } else {
                debugPrint(' In MainMenu hour is not same');
                // sharedPreferences.setBool("isDoseTime", false);
              }
            } else {
              ePrint(' In MainMenu ${snoozedMed.dosetime}');
              SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              String patientCode = sharedPreferences.getString('p_code')!;
              var url = Uri.parse(
                  '${BaseUrl.baseurl}/api/patients/$patientCode/prescriptions/${snoozedMed.id}');
              final response = await patch(
                url,
                body: {
                  "status": "Skipped",
                  "time": snoozedMed.dosetime, // "13:30",
                  "medicine_time_id": '${snoozedMed.timeIndex}' // 2
                },
              );
              if (response.statusCode == 200) {
                ePrint(' In MainMenu ${response.body}');
              } else {
                ePrint(' In MainMenu ${response.body}');
              }
            }
          }
          // if (dosingList.isNotEmpty) {
          //   Get.offAll(NotificationTime());
          // } else {}
        } else {
          ePrint('  In MainMenu  equal null');
        }
      }
    } else {
      ePrint(' In MainMenu pcode is null');
    }
    if (dosingList.isNotEmpty) {
      Get.offAll(NotificationTime());
      // Get.offAll(AccountScreen());
    } else {
      sharedPreferences.setBool("isDoseTime", false);
      ePrint('In MainMenu: dosing list is empty');
    }
    ePrint(
        ' In MainMenu ontMainMenuCallBack Function End Time ${DateTime.now()}');
  }

  Future<void> mainMenuTimer() async {
    ePrint('In mainMenuTimer start');

    WidgetsFlutterBinding.ensureInitialized();
    // await AndroidAlarmManager.periodic(
    //     Duration(seconds: 57), alarmID, onMainMenuCallBack);
    ePrint('In mainMenuTimer end');
  }

  void myCallBack() {
    ePrint('In myCallBack end');
    onMainMenuCallBack();
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
