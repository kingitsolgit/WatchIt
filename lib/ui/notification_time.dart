import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/main.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/meducine.dart';
import 'package:watch_it/model/snoozedmedicine.dart';
import 'package:watch_it/ui/account.dart';
import 'package:watch_it/ui/logs.dart';
import 'package:watch_it/ui/main_menu.dart';
import 'package:watch_it/ui/settings.dart';
import 'package:watch_it/ui/snooze_confirm.dart';
import 'package:watch_it/ui/snooze_time.dart';
import 'package:watch_it/ui/take_it_now.dart';

class NotificationTime extends StatefulWidget {
  //const NotificationTime{Key? key}) : super(key: key);
  static String id = 'notification_time';

  @override
  _NotificationTimeState createState() => _NotificationTimeState();
}

class _NotificationTimeState extends State<NotificationTime> {
  String? selectedlanguage;
  //  pillName;
  String? intervalString = 'ten';
  final int alarmID = 0;
  int? duration;
  List<String>? currentMedicines;
  var pillName;
  String? medicinesName;

  bool? isDoseTime;
  @override
  void initState() {
    super.initState();
    // await AndroidAlarmManager.initialize();
    // await AndroidAlarmManager.periodic(
    //     Duration(minutes: 2), alarmID, playAlarm);

    // getSnoozedData();
    getData();
    ringTheBell();
  }

  Future<void> getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // pillName = sharedPreferences.getString('currentMediName');
    currentMedicines = sharedPreferences.getStringList('currentMedicines');
    String? sllang = sharedPreferences.getString("apilang");
    isDoseTime = sharedPreferences.getBool('isDoseTime');
    duration = sharedPreferences.getInt('snoozeDuration');
    print('duration $duration');
    print('slllal $sllang');
    ////for language
    if (sllang != null) {
      setState(() {
        selectedlanguage = sllang;
      });
    } else {
      setState(() {
        selectedlanguage = "en";
      });
    }

    ////////for snooze interval
    switch (duration) {
      case 5:
        setInterval('five');
        print('5');
        break;
      case 10:
        setInterval('ten');
        print('10');
        break;
      case 15:
        setInterval('fifteen');
        print('15');
        break;
      default:
        setInterval('ten');
        print('10 is default');
    }
    // print('and then ' + selectedlanguage.toString());
    // var setlanguage = Provider.of<LanguageProvider>(context, listen: false);
    // setlanguage.setleanguage(selectedlanguage!);
    if (isDoseTime != null && isDoseTime == true) {
      getMedicatedData();
      ePrint('its a dose time');
    } else {
      getNextDosesData();
      ePrint('its not a dose time');
    }
  }

  void setInterval(String interval) {
    setState(() {
      intervalString = interval;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routes: {
        // PairScreen.id: (context) => PairScreen(),
        TakeItNow.id: (context) => TakeItNow(),
        SplashScreen.id: (context) => SplashScreen(),
        AccountScreen.id: (context) => AccountScreen(),
        MainMenu.id: (context) => MainMenu(),
        Settings.id: (context) => Settings(),
        Logs.id: (context) => Logs(),
        NotificationTime.id: (context) => NotificationTime(),
        SnoozeConfirm.id: (context) => SnoozeConfirm(),
        SnoozeTime.id: (context) => SnoozeTime(),
        TakeItNow.id: (context) => TakeItNow(),
        // Languages.id: (context) => Languages(),
      },
      home: Scaffold(
        body: WatchShape(
          builder: (context, shape, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 25,
                  ),
                  height: Get.height / 4,
                  width: Get.width,
                  color: Colors.black,
                  child: Center(
                    child: Icon(
                      Icons.alarm,
                      color: Colors.red,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 4,
                  ),
                  height: isDoseTime == true
                      ? Get.height / 4
                      : Get.height * (3 / 4),
                  width: Get.width,
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          dosesNames!.isNotEmpty
                              ? isDoseTime == false
                                  ? 'Next Doses are'
                                  : tr('its time for')
                              : 'No Medicine Yet..!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            dosesNames!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                isDoseTime == true
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 20,
                        ),
                        height: Get.height / 2,
                        width: Get.width,
                        color: Colors.black,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                FlutterRingtonePlayer.stop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TakeItNow(pilname: dosesNames),
                                  ),
                                );
                                // ePrint('${dosesNames!.length} doses $dosesNames');
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.blueAccent,
                                      child: Icon(
                                        Icons.check_outlined,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      tr('take it now'),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              onTap: () {
                                FlutterRingtonePlayer.stop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SnoozeConfirm(
                                      pilname: dosesNames,
                                      medicatedList: encodedStringList,
                                      duration: duration,
                                      intervalString: intervalString,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.blueAccent,
                                      child: Image.asset(
                                        'assets/images/$intervalString.png',
                                        scale: 2.5,
                                      ),
                                      // Icon(
                                      //   Icons.snooze_outlined,
                                      // ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      tr('snooze'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> ringTheBell() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? isDoseTime = sharedPreferences.getBool("isDoseTime");
    debugPrint('In notification dosetime is $isDoseTime');
    if (isDoseTime == true) {
      await FlutterRingtonePlayer.play(
        android: AndroidSounds.alarm,
        ios: IosSounds.electronic,
        looping: false,
        volume: 0.9,
        asAlarm: true,
      );
    }
    Timer(Duration(seconds: 50), () {
      FlutterRingtonePlayer.stop();
    });
    // FlutterRingtonePlayer.stop();
  }

  String? dosesNames = '';
  List<String>? encodedStringList;
  List<String>? snoozedList;

  Future<void> getMedicatedData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getStringList('dosingList') != null) {
      encodedStringList = sharedPreferences.getStringList('dosingList');
      for (var i = 0; i < encodedStringList!.length; i++) {
        ePrint('list obj $i is ${encodedStringList![i]}');
        Map<String, dynamic> dosingMaplistobj =
            jsonDecode(encodedStringList![i]);
        Meducine meducine = Meducine.fromJson(dosingMaplistobj);
        ePrint('user dosing id and time');
        ePrint(meducine.medicineId! + meducine.medicineTime!);
        ePrint('user medname');
        dosesNames = dosesNames! + meducine.medicineName!.toString() + ', ';
        ePrint('user dosname string length in for loop ${dosesNames!.length}');
      }
    }
    ePrint('user dosname strring length ${dosesNames!.length}');
  }

  Future<void> getSnoozedData() async {
    ePrint('In NotificationTime getSnoozedData start');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getStringList('snoozedList') != null) {
      snoozedList = sharedPreferences.getStringList('snoozedList');
      for (var i = 0; i < snoozedList!.length; i++) {
        ePrint('snoozedList obj $i is ${snoozedList![i]}');
        Map<String, dynamic> snoozedListobj = jsonDecode(snoozedList![i]);
        SnoozedMedicine snoozedMedicine =
            SnoozedMedicine.fromJson(snoozedListobj);
        ePrint('snoozed  dosing');
        ePrint(snoozedMedicine.id!);
        ePrint('snoozed medname and time ${snoozedMedicine.dosetime}');
        dosesNames = dosesNames! +
            snoozedMedicine.name!.toString() +
            ' at ' +
            snoozedMedicine.dosetime!.toString();
        ePrint('In NotificationTime getSnoozedData end');
      }
    }
  }

  List<String>? nextDoseList = [];
  getNextDosesData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getStringList('nextDoseList') != null) {
      nextDoseList = sharedPreferences.getStringList('nextDoseList');
      for (var i = 0; i < nextDoseList!.length; i++) {
        ePrint('nextDoseList obj $i is ${nextDoseList![i]}');
        Map<String, dynamic> nextDoseListobj = jsonDecode(nextDoseList![i]);
        Meducine meducine = Meducine.fromJson(nextDoseListobj);
        ePrint('nextDoseList  dosing');
        ePrint(meducine.medicineId!);
        dosesNames = dosesNames! +
            meducine.medicineName!.toString() +
            ' at ' +
            meducine.medicineTime!.toString() +
            '\n';
        ePrint('nextDose dosname');
      }
      ePrint('user dosname strring length ${dosesNames!.length}');
    }
  }
}
