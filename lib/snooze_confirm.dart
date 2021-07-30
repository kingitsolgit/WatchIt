import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/links/baserurl.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/log.dart';
import 'package:watch_it/model/meducine.dart';
import 'package:watch_it/model/snoozedmedicine.dart';
// import 'package:watch_it/pair.dart';
import 'package:watch_it/take_it_now.dart';
import 'package:wear/wear.dart';
import 'package:get/get.dart';

class SnoozeConfirm extends StatelessWidget {
  //const SnoozeConfirm{Key? key}) : super(key: key);
  static String id = 'snooze_confirm';
  final String? pilname;
  final List<String>? medicatedList;
  String? intervalString;
  int? duration;

  SnoozeConfirm({
    Key? key,
    this.pilname,
    this.medicatedList,
    this.intervalString,
    this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WatchShape(
        builder: (context, shape, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Text(
              //   'Shape: ${shape == WearShape.round ? 'round' : 'square'}',
              // ),
              // child,
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
                              // Navigator.pop(context);
                              // skipNow("","");
                              // updateStatus('medicineId', 'status', 'time', 2);
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
                              // Navigator.pop(context);
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
                    // Container(
                    //   padding: EdgeInsets.only(
                    //     left: 10,
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       CircleAvatar(
                    //         radius: 15,
                    //         backgroundColor: Colors.blueAccent,
                    //         child: Icon(
                    //           Icons.snooze_outlined,
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: 10,
                    //       ),
                    //       Text(
                    //         'Snooz',
                    //         textAlign: TextAlign.center,
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
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

  Future<void> updateStatus(String medicineId, String status, String time,
      int medTimeIndex, Meducine meducine) async {
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
      addLogData(meducine);
    } else {
      print(response.body);
    }
  }

  static List<String>? snoozedList;

  Future<void> snoozeNow(BuildContext context) async {
    // Timer.periodic(Duration(minutes: 1), (val) {});
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? n = duration;

    if (sharedPreferences.getStringList('snoozedList') == null) {
      snoozedList = [];
      print('in if in snoozenow');
      // for (var i = 0; i < medicatedList!.length; i++) {
      //   print('list obj $i is ${medicatedList![i]}');
      //   Map<String, dynamic> dosingMaplistobj = jsonDecode(medicatedList![i]);
      //   Meducine meducine = Meducine.fromJson(dosingMaplistobj);
      //   SnoozedMedicine snoozedMedicine = SnoozedMedicine(
      //     id: meducine.medicineId,
      //     name: meducine.medicineName,
      //     dosetime: meducine.medicineTime,
      //     routine: meducine.dailyDosePill,
      //     timeIndex: meducine.medicinetimeindex,
      //     isSnoozed: true,
      //     snoozedDurationMins: duration,
      //   );
      //   // snoozedList!.add(medicatedList![i]);
      //   String snoozeString = jsonEncode(snoozedMedicine);
      //   snoozedList!.add(snoozeString);
      //   print('snooxestring is $snoozeString');
      // }
      // sharedPreferences.setStringList('snoozedList', snoozedList!);
    } else {
      snoozedList = sharedPreferences.getStringList('snoozedList');
      ePrint('in else in snoozenow');
    }
    for (var i = 0; i < medicatedList!.length; i++) {
      // print('list obj $i is ${medicatedList![i]}');
      // ePrint('list obj $i is ${snoozedList![i]}');

      Map<String, dynamic> dosingMaplistobj = jsonDecode(medicatedList![i]);
      Meducine meducine = Meducine.fromJson(dosingMaplistobj);
      DateFormat dateFormating =
          DateFormat("dd-MM-yyyy HH:mm", context.locale.toString());
      DateTime myDT = dateFormating.parse(meducine.medicineTime!);
      myDT.add(Duration(minutes: n == null ? 10 : n));
      ePrint('n============== ${n == null ? 10 : n} and my DateTime is $myDT');
      // meducine.medicineTime

      SnoozedMedicine snoozedMedicine = SnoozedMedicine(
        id: meducine.medicineId,
        name: meducine.medicineName,
        dosetime: myDT.toString(), // meducine.medicineTime,
        routine: meducine.dailyDosePill,
        timeIndex: meducine.medicinetimeindex,
        isSnoozed: true,
        snoozedDurationMins: duration == null ? 10 : duration,
      );
      // snoozedList!.add(medicatedList![i]);
      String snoozeString = jsonEncode(snoozedMedicine);
      snoozedList!.add(snoozeString);
      print('snooxestring is $snoozeString');
    }
    sharedPreferences.setStringList('snoozedList', snoozedList!);
    ePrint('snoozed added');
    SystemNavigator.pop();
  }

  List<String>? logList;
  Future<void> addLogData(Meducine meducine) async {
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
      status: 'Taken',
      takenAt: DateTime.now().toString(),
    );
    ePrint('$log');
    String logString = jsonEncode(log);
    ePrint('encoded logstring $logString');
    logList!.add(logString);
    sharedPreferences.setStringList('logList', logList!);
    ePrint('logAdded');
    SystemNavigator.pop();
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
        print('new Dt is $newDT');
        updateStatus(
          meducine.medicineId!,
          "Skipped",
          meducine.medicineTime!,
          meducine.medicinetimeindex!,
          meducine,
        );
        print('gone');
      }
    }
  }
}