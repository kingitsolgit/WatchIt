import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/main.dart';
import 'package:watch_it/ui/main_menu.dart';
import 'package:watch_it/ui/medications_list.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/links/baserurl.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/log.dart';
import 'package:watch_it/model/meducine.dart';
import 'package:watch_it/model/snoozedmedicine.dart';

class SnoozeConfirm extends StatelessWidget {
  static String id = 'snooze_confirm';
  final String? pilname;
  final List<String>? medicatedList;
  String? intervalString;
  int? duration = 10;

  late String pName;
  late String pEmail;
  late String pCode;
  late String doctor;

  SnoozeConfirm({
    Key? key,
    this.pilname,
    this.medicatedList,
    this.intervalString,
    this.duration,
  }) : super(key: key);

  Future<void> getPatientInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    pName = sharedPreferences.getString('p_name')!;
    pEmail = sharedPreferences.getString('p_email')!;
    pCode = sharedPreferences.getString('p_code')!;
    doctor = sharedPreferences.getString('doctor')!;
  }

  @override
  Widget build(BuildContext context) {
    getPatientInfo();
    return Scaffold(
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
                  child: Image.asset(
                    'assets/images/clock.png',
                    scale: 1.5,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 25,
                ),
                height: Get.height / 4,
                width: Get.width,
                color: Colors.black,
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        tr('its time for'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          pilname!.toUpperCase(),
                          // 'Acyclovir (10mg) ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              skipNow(context);
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.task_alt,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              snoozeNow(context);
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.blueAccent,
                              child: Image.asset(
                                'assets/images/$intervalString.png',
                                scale: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> updateStatus(String medicineId, String status, String time,
      int medTimeIndex, Meducine meducine, BuildContext context) async {
    // DateTime newDT = newdateFormating.parse(snoozedMed.dosetime!);
    // String mTime = DateFormat('HH:mm').format(newDT);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String patientCode = sharedPreferences.getString('p_code')!;
    var url = Uri.parse(
        '${BaseUrl.baseurl}/api/patients/$patientCode/prescriptions/$medicineId');
    final response = await patch(url, body: {
      "status": status, // "Skipped",
      "time": time, // "13:30",
      "medicine_time_id": '$medTimeIndex' // 2
    });
    if (response.statusCode == 200) {
      print(response.body);
      addLogData(meducine, status, context);
    } else {
      print(response.body);
    }
  }

  static List<String>? snoozedList;

  Future<void> snoozeNow(BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? n = duration;

    if (sharedPreferences.getStringList('snoozedList') == null) {
      snoozedList = [];
      print('in if in snoozenow');
    } else {
      snoozedList = sharedPreferences.getStringList('snoozedList');
      ePrint('in else in snoozenow');
    }
    for (var i = 0; i < medicatedList!.length; i++) {
      Map<String, dynamic> dosingMaplistobj = jsonDecode(medicatedList![i]);
      Meducine meducine = Meducine.fromJson(dosingMaplistobj);
      ePrint(meducine.medicineId!);
      DateFormat dateFormating =
          DateFormat("dd-MM-yyyy HH:mm", context.locale.toString());
      DateTime myDT = dateFormating.parse(meducine.medicineTime!);
      DateTime snoozedDT = myDT.add(Duration(minutes: n == null ? 10 : n));
      ePrint('n==  ${n == null ? 10 : n} and my snoozedTime is $snoozedDT');
      SnoozedMedicine snoozedMedicine = SnoozedMedicine(
        id: meducine.medicineId!,
        name: meducine.medicineName,
        dosetime: snoozedDT.toString(),
        routine: meducine.dailyDosePill,
        timeIndex: meducine.medicinetimeindex,
        isSnoozed: true,
        snoozedIteration: meducine.snoozedIteration == null
            ? setSnoozedIter(meducine.snoozedIteration)
            : setSnoozedIter(meducine.snoozedIteration),
        snoozedDurationMins: duration == null ? 10 : duration,
      );
      // snoozedList!.add(medicatedList![i]);
      String snoozeString = jsonEncode(snoozedMedicine);
      snoozedList!.add(snoozeString);
      print('snooxestring is $snoozeString');
    }
    sharedPreferences.setStringList('snoozedList', snoozedList!);
    ePrint('snoozed added');
    sharedPreferences.setBool("isDoseTime", false);
    ePrint('isDoseTime is set false');
    // SystemNavigator.pop();
    // Get.offAll(MedicationList());
    Restart.restartApp();
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   new MaterialPageRoute(
    //     builder: (context) => SplashScreen(),
    //     // MainMenu(pname: pName, pemail: pEmail, pcode: pCode),
    //   ),
    //   (route) => false,
    // );
  }

  List<String>? logList;
  Future<void> addLogData(
      Meducine meducine, String status, BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getStringList('logList') == null) {
      ePrint('adlog from else');
      logList = [];
    } else {
      ePrint('ad log from else');
      logList = sharedPreferences.getStringList('logList');
    }
    Log log = Log(
      medicineName: meducine.medicineName,
      status: status, //'Taken',
      takenAt: meducine.medicineTime, // DateTime.now().toString(),
    );
    ePrint('$log');
    String logString = jsonEncode(log);
    ePrint('encoded logstring $logString');
    logList!.add(logString);
    sharedPreferences.setStringList('logList', logList!);
    ePrint('logAdded');
    // SystemNavigator.pop();
    Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(
          builder: (context) =>
              MainMenu(pname: pName, pemail: pEmail, pcode: pCode),
        ),
        (route) => false);
  }

  Future<void> skipNow(BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getStringList('dosingList') != null) {
      List<String>? encodedStringList =
          sharedPreferences.getStringList('dosingList');
      for (var i = 0; i < encodedStringList!.length; i++) {
        print('list obj $i is ${encodedStringList[i]}');
        Map<String, dynamic> dosingMaplistobj =
            jsonDecode(encodedStringList[i]);
        Meducine meducine = Meducine.fromJson(dosingMaplistobj);
        print('user dosing');
        print(meducine.medicineId);
        print(meducine.medicineName);
        print(meducine.dailyDosePill);
        print(meducine.medicineTime);
        print(meducine.dateRange);
        print(meducine.medicinetimeindex);
        DateFormat newdateFormating =
            DateFormat("dd-MM-yyyy HH:mm", context.locale.toString());
        DateTime newDT = newdateFormating.parse(meducine.medicineTime!);
        // DateTime newDT = DateFormat("HH:mm").format(meducine.medicineTime!);
        print('new Dt is $newDT');
        updateStatus(
          meducine.medicineId!,
          "Skipped",
          meducine.medicineTime!,
          meducine.medicinetimeindex!,
          meducine,
          context,
        );
        print('gone for skip');
      }
    }
  }

  setSnoozedIter(int? snoozedIteration) {
    int? iteration = 0;
    if (snoozedIteration == null) {
      iteration = 0;
    } else if (snoozedIteration == 0) {
      iteration = 1;
    } else if (snoozedIteration == 1) {
      iteration = 2;
    } else if (snoozedIteration == 2) {
      iteration = 3;
    }
    return iteration;
  }
}
