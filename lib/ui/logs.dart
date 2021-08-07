import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/log.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key}) : super(key: key);
  static String id = 'logs';

  @override
  _LogsState createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  String? pcode;
  List<Log> logList1 = [];
  List<Log> logList2 = [];
  List<Log> logList3 = [];
  List<Log> logList = [];

  List<Log> myLogList = [
    Log(
      medicineName: 'Panadol 1',
      status: "Taken",
      takenAt: '2021-08-1 09:10',
    ),
    Log(
      medicineName: 'Panadol 2',
      status: "Taken",
      takenAt: '2021-08-1 17:10',
    ),
    Log(
      medicineName: 'Panadol 3',
      status: "Taken",
      takenAt: '2021-07-31 09:10',
    ),
    Log(
      medicineName: 'Panadol 4',
      status: "Taken",
      takenAt: '2021-07-31 19:10',
    ),
    Log(
      medicineName: 'Panadol 5',
      status: "Taken",
      takenAt: '2021-07-30 09:10',
    ),
    Log(
      medicineName: 'Panadol 6',
      status: "Taken",
      takenAt: '2021-07-30 19:10',
    ),
  ];

  Future getSavedLogList() async {
    logList.clear();
    ePrint('getSavedLogList in logs started');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getStringList('logList') != null) {
      ePrint('In 3 day Log: logList not equal null.');
      List<String>? logStringList = sharedPreferences.getStringList('logList');
      ePrint('In 3 day Log: list assigned of ${logStringList!.length} length');
      // for (var i = 0; i < logStringList.length; i++) {
      for (var i = logStringList.length - 1; i >= 0; i--) {
        ePrint('In 3 day Log: logStringList loop started');
        ePrint('In 3 day Log: list obj $i is ${logStringList[i]}');
        Map<String, dynamic> dosingMaplistobj = jsonDecode(logStringList[i]);
        var userDosing = Log.fromJson(dosingMaplistobj);
        ePrint(userDosing.takenAt!);
        Log log = Log(
          medicineName: userDosing.medicineName,
          status: userDosing.status,
          takenAt: userDosing.takenAt,
        );
        DateFormat newdateFormating =
            DateFormat("dd-MM-yyyy", context.locale.toString());
        // DateFormat("yyyy-MM-dd", context.locale.toString());
        DateTime nowDate = newdateFormating.parse(DateTime.now().toString());
        DateTime takenAtDate = newdateFormating.parse(userDosing.takenAt!);
        // if (nowDate.difference(takenAtDate) == Duration(hours: 0)) {
        //   ePrint('Duration(hours: 0)');
        //   logList1.add(log);
        // } else if (nowDate.difference(takenAtDate) == Duration(hours: 24)) {
        //   ePrint('Duration(hours: 24)');
        //   logList2.add(log);
        // } else if (nowDate.difference(takenAtDate) == Duration(hours: 48)) {
        //   ePrint('Duration(hours: 48)');
        //   logList3.add(log);
        // }
        ePrint('In logs nowDate is $nowDate and takeat is $takenAtDate');
        logList.add(log);
      }
      // logList.sort
    } else {
      ePrint('In 3 day Log: logList equal null');
    }
    ePrint('In 3 day Log: current locale is ${context.locale}');

    return logList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getSavedLogList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Log>? logs = snapshot.data as List<Log>?;
          if (logList.isNotEmpty) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: WatchShape(
                builder: (context, shape, child) {
                  // child = SizedBox();
                  return Container(
                    width: Get.width,
                    height: Get.height,
                    decoration: BoxDecoration(),
                    child: Column(
                      children: [
                        Material(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                              bottom: 10,
                            ),
                            child: Text(
                              tr('3 days log'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: Get.height * 0.8,
                          child: ListView.builder(
                            itemCount: logList.length,
                            itemBuilder: (context, index) {
                              DateFormat newdateFormating;
                              if (logList[index].status == "Taken") {
                                newdateFormating = DateFormat(
                                  "yyyy-MM-dd HH:mm",
                                  context.locale.toString(),
                                );
                              } else {
                                newdateFormating = DateFormat(
                                  "dd-MM-yyyy HH:mm",
                                  context.locale.toString(),
                                );
                              }
                              DateTime newDT = newdateFormating
                                  .parse(logList[index].takenAt!);
                              ePrint('NEW DT $index IS this $newDT');
                              String mTime = DateFormat('HH:mm').format(newDT);
                              return LogButtons(
                                setHead: true,
                                name: logList[index].medicineName,
                                text: '${logList[index].status} at $mTime',
                                datetime: newDT,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            return Scaffold(
              body: Center(
                child: Text(tr('no record')),
              ),
            );
          }
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class LogButtons extends StatefulWidget {
  final bool? setHead;
  final String? name;
  final String? text;
  final DateTime? datetime;
  LogButtons({
    Key? key,
    this.setHead,
    this.name,
    this.text,
    this.datetime,
  }) : super(key: key);

  @override
  _LogButtonsState createState() => _LogButtonsState();
}

class _LogButtonsState extends State<LogButtons> {
  // bool? today = true;
  // bool? yesterday = false;
  // bool? nextDay = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Column(
        children: [
          widget.setHead == false
              ? Container(
                  width: Get.width,
                  color: Colors.deepOrange,
                  height: 30,
                  child: Center(
                    child: Text(
                      getDayString(widget.datetime!)!, // 'Today',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.only(
              left: 24,
              top: 5,
              bottom: 5,
            ),
            child: Container(
              width: Get.width,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.deepOrange,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text(
                          widget.name!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 2.0,
                          ),
                          child: Text(
                            getDayString(widget.datetime!)!, // 'Today',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.text!,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? getDayString(DateTime dateTime) {
    String nowDateString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DateTime nowDate = DateTime.parse(nowDateString);
    String formattedDateString = DateFormat('yyyy-MM-dd').format(dateTime);
    DateTime formattedDate = DateTime.parse(formattedDateString);
    print(formattedDate);
    String? dayString;
    if (nowDate.day.isEqual(dateTime.day)) {
      dayString = 'Today';
      return dayString;
    } else if (DateTime.now()
        .subtract(Duration(days: 1))
        .day
        .isEqual(dateTime.day)) {
      dayString = 'Yesterday';
      return dayString;
    } else {
      dayString = DateFormat('dd MMM yyyy').format(dateTime);
      return dayString;
    }
  }
}
