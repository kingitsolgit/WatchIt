import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/ui/medications_list.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/links/baserurl.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/log.dart';
import 'package:watch_it/model/meducine.dart';

class TakeItNow extends StatefulWidget {
  static String id = 'take_it_now';
  final List<String>? medicines;
  final String? pilname;

  TakeItNow({Key? key, this.pilname, this.medicines}) : super(key: key);

  @override
  _TakeItNowState createState() => _TakeItNowState(medicines);
}

class _TakeItNowState extends State<TakeItNow> {
  String notificationText = tr('press and hold');
  Color iconColor = Colors.white;
  Color iconBgColor = Colors.blueAccent;
  Color bgColor = Colors.blueGrey.shade400;
  IconData icon = Icons.task_alt;
  double iconSize = 20;

  String? medID;

  List<String>? logList;

  final List<String>? medicatedList;

  _TakeItNowState(this.medicatedList);

  timer() {
    Timer(
      Duration(seconds: 8),
      () {
        // Get.offAll(MedicationList());
        // SystemNavigator.pop();
        Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(builder: (context) => MedicationList()),
            (route) => false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WatchShape(
        builder: (context, shape, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
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
                padding: EdgeInsets.symmetric(horizontal: 25),
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
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.pilname!.toUpperCase(),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: Get.height / 2,
                width: Get.width,
                color: bgColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onLongPress: () {
                            Future<bool?> isOk = takeIt().whenComplete(() {
                              ePrint(
                                  "In Take it now: Take It now Function Completed");
                              changeUI();
                              timer();
                            });
                            ePrint("In Take it now: isOk = $isOk");
                          },
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: iconBgColor,
                            child: Icon(
                              Icons.task_alt,
                              size: iconSize,
                              color: iconColor, // Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              notificationText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Future showMyDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Color.fromARGB(255, 161, 33, 22),
          titlePadding: EdgeInsets.all(12),
          title: Center(
            child: Column(
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> changeUI() async {
    setState(() {
      iconColor = Colors.green;
      iconBgColor = Colors.blueGrey.shade800;
      bgColor = Colors.blueGrey.shade800;
      notificationText = tr('marked as taken');
      iconSize = 25;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("isDoseTime", false);
    ePrint('In Take it now: Dose time is set to false');
  }

  Future<bool?> takeIt() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getStringList('dosingList') != null) {
      List<String>? encodedStringList =
          sharedPreferences.getStringList('dosingList');
      for (var i = 0; i < encodedStringList!.length; i++) {
        ePrint('list obj $i is ${encodedStringList[i]}');
        Map<String, dynamic> dosingMaplistobj =
            jsonDecode(encodedStringList[i]);
        Meducine meducine = Meducine.fromJson(dosingMaplistobj);
        ePrint('meducine medicineId is ${meducine.medicineId}');
        ePrint('meducine time is ${meducine.medicineTime}');
        DateFormat newdateFormating =
            DateFormat("dd-MM-yyyy HH:mm", context.locale.toString());
        // DateFormat newdateFormating = DateFormat("yyyy-MM-dd HH:mm");
        DateTime newDT = newdateFormating.parse(meducine.medicineTime!);
        ePrint('new Dt is $newDT');
        ePrint('gone');
        return updateStatus(meducine);
      }
    }
  }

  Future<bool?> updateStatus(Meducine meducine) async {
    ePrint('update status has started');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String patientCode = sharedPreferences.getString('p_code')!;
    print('in update status after code in take it now.');
    var url = Uri.parse(
        '${BaseUrl.baseurl}/api/patients/$patientCode/prescriptions/${meducine.medicineId}');
    final response = await patch(url, body: {
      "status": "Taken", // "Skipped",
      "time": meducine.medicineTime, // "13:30",
      "medicine_time_id": '${meducine.medicinetimeindex}'
    });
    print('what is happening here');

    if (response.statusCode == 200) {
      print(response.body);
      addLogData(meducine);
      return true;
    } else {
      print(response.body);
      showMyDialog('Some Error Occur');
    }
  }

  Future<bool?> addLogData(Meducine meducine) async {
    ePrint('addlogdata started');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getStringList('logList') == null) {
      ePrint('ad log from else');
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
    showMyDialog('Done');
    return true;
  }
}
