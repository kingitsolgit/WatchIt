import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/links/baserurl.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/log.dart';
import 'package:watch_it/model/pill.dart';
import 'package:watch_it/model/prescription.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key}) : super(key: key);
  static String id = 'logs';

  static List<Pill> pills = [
    Pill(name: 'Baclofen', unit: '10 mg', dosetime: '1 PM', routine: 'Daily'),
    Pill(name: 'Citalpram', unit: '10 mg', dosetime: '10 PM', routine: 'Daily'),
    Pill(name: 'Baclofen', unit: '22 mg', dosetime: '1 PM', routine: 'Daily'),
    Pill(name: 'Citalopram', unit: '10 mg', dosetime: '8 PM', routine: 'Daily'),
    Pill(name: 'Baclofen', unit: '14 mg', dosetime: '4 PM', routine: 'Daily'),
  ];

  @override
  _LogsState createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  String? pcode;
  List<Log> logList = [];

  Future getSavedLogList() async {
    logList.clear();
    ePrint('getSavedLogList in logs started');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getStringList('logList') != null) {
      ePrint('not equal null');
      List<String>? logStringList = sharedPreferences.getStringList('logList');
      ePrint('list assigned of ${logStringList!.length} length');
      for (var i = 0; i < logStringList.length; i++) {
        ePrint('loop started');
        print('list obj $i is ${logStringList[i]}');
        Map<String, dynamic> dosingMaplistobj = jsonDecode(logStringList[0]);
        var userDosing = Log.fromJson(dosingMaplistobj);
        print(userDosing.medicineName);
        Log log = Log(
          medicineName: userDosing.medicineName,
          status: userDosing.status,
          takenAt: userDosing.takenAt,
        );
        logList.add(log);
      }
    } else {
      ePrint('  equal null');
    }
    ePrint(' current locale is ${context.locale}');

    return logList;
  }

  Future getPosts() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    pcode = sharedPreferences.getString('p_code')!;

    var url = Uri.parse('${BaseUrl.baseurl}/api/patients/$pcode/prescriptions');
    // "http://watchit-project.eu/api/patients/$pcode/prescriptions");
    final response = await get(url);
    if (response.statusCode == 200) {
      print(response.body);

      ///
      var responc = Prescription.fromJson(jsonDecode(response.body));
      var date = responc.data![0].date;
      print('new extracted date is $date');
      for (var i = 0; i < responc.data!.length; i++) {
        for (var j = 0; j < responc.data![i].medicineTime!.length; j++) {
          // var myInt = int.parse('12345');
          // assert(myInt is int);
          print('myInt $i, $j'); // 12345
          // logList.add(
          //   Log(
          //     medicineName: responc.data![i].sId,
          //     status: 'Taken',
          //     takenAt: DateTime.now().toString(),
          //   ),
          // );
        }
      }
      print(logList.length);

      return Prescription.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSavedLogList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Log>? logs = snapshot.data as List<Log>?;
            print('3 days logs are $logs');
            // Prescription? prescription = snapshot.data as Prescription;
            // print('snapshot length ${prescription.data!.length}');
            if (logList.isNotEmpty) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: WatchShape(
                  builder: (context, shape, child) {
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
                          // Container(
                          //   width: Get.width,
                          //   color: Colors.deepOrange,
                          //   height: 30,
                          //   child: Center(
                          //     child: Text(
                          //       getDayString(DateTime.now())!,
                          //       // getDayString(
                          //       //     logList[logList.length - 2].takenAt!)!,
                          //       // logList[0]
                          //       //             .takenAt!
                          //       //             .day
                          //       //             .isEqual(DateTime.now().day) ==
                          //       //         true
                          //       //     ? 'Today'
                          //       //     : 'Not sure', // 'Today',
                          //       textAlign: TextAlign.center,
                          //       style: TextStyle(
                          //         color: Colors.white,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // InkWell(
                          //   onTap: () {},
                          //   child: LogButtons(
                          //     name:
                          //         '${Logs.pills[1].name}', //'Baclofen (1000 mg)',
                          //     time: 'Taken at 07:20',
                          //   ),
                          // ),
                          // InkWell(
                          //   onTap: () {},
                          //   child: LogButtons(
                          //     name: 'Citalopram (5 mg)',
                          //     time: 'Skipped',
                          //   ),
                          // ),
                          // InkWell(
                          //   onTap: () {},
                          //   child: LogButtons(
                          //     name: 'Acyclovir (10 mg)',
                          //     time: 'Taken at 13:00',
                          //   ),
                          // ),
                          // Container(
                          //   width: Get.width,
                          //   color: Colors.deepOrange,
                          //   height: 30,
                          //   child: Center(
                          //     child: Text(
                          //       getDayString(DateTime(2021, 07, 13, 12,
                          //           22))!, // 'Wednesday, April 8th',
                          //       textAlign: TextAlign.center,
                          //       style: TextStyle(
                          //         color: Colors.white,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // InkWell(
                          //   onTap: () {},
                          //   child: LogButtons(
                          //     name: 'Baclofen (1000 mg)',
                          //     time: 'Taken at 07:00',
                          //   ),
                          // ),
                          // InkWell(
                          //   onTap: () {},
                          //   child: LogButtons(
                          //     name: 'Citalopram (5 mg)',
                          //     time: 'Taken at 09:00',
                          //   ),
                          // ),
                          // Container(
                          //   width: Get.width,
                          //   color: Colors.deepOrange,
                          //   height: 30,
                          //   child: Center(
                          //     child: Text(
                          //       getDayString(DateTime(2021, 07, 12, 12,
                          //           22))!, // 'Wednesday, April 8th',
                          //       textAlign: TextAlign.center,
                          //       style: TextStyle(
                          //         color: Colors.white,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // InkWell(
                          //   onTap: () {},
                          //   child: LogButtons(
                          //     name: 'Baclofen (1000 mg)',
                          //     time: 'Taken at 07:00',
                          //   ),
                          // ),
                          // InkWell(
                          //   onTap: () {},
                          //   child: LogButtons(
                          //     name: 'Citalopram (5 mg)',
                          //     time: 'Taken at 09:00',
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 30,
                          // ),
                          Container(
                            height: Get.height * 0.8,
                            child: ListView.builder(
                                itemCount: logList.length,
                                itemBuilder: (context, index) {
                                  DateFormat newdateFormating =
                                      DateFormat("yyyy-MM-dd HH:mm", "en_PK");

                                  DateTime newDT = newdateFormating
                                      .parse(logList[index].takenAt!);
                                  String s =
                                      '${logList[index].status} at ${newDT.hour}:${newDT.minute} ${newDT.day}-${newDT.month}-${newDT.year}';
                                  return LogButtons(
                                    name: logList[index].medicineName,
                                    time: s, //logList[index].takenAt,
                                  );
                                }),
                          ),
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
            } else {
              return Scaffold(
                body: Center(
                  child: Text('No Record Yet'),
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
        });
  }

  String? getDayString(DateTime dateTime) {
    DateTime d1 = DateTime(2021, 07, 16, 06, 13); //'2021-07-12 14:01';
    DateTime d2 = DateTime(2021, 07, 14, 06, 13); // '2021-07-14 14:01';
    // debugPrint('daysttring......');
    // var cd = d1.compareTo(d2);
    // var c = dateTime.compareTo(DateTime.now());
    // Duration duration = d1.difference(d2);
    // debugPrint('$d1 and $cd ${duration.toString()}');

    // Duration duration2 = DateTime.now().difference(dateTime);
    // debugPrint('daysttring..duuration  mm....is $duration2');
    DateFormat dateFormating = DateFormat("yyyy-MM-dd HH:mm");
    DateTime myDT = dateFormating.parse(dateTime.toString());
    // dayString = dateFormating.parse(dateTime.toString()).toString();
    // myDT.toString(); //dateTime.toString();
    String formattedDate = DateFormat('yyyy-MM-dd kk:mm').format(dateTime);
    print(formattedDate);

    String? dayString;
    Duration diff = DateTime.now().difference(dateTime);
    if (DateTime.now().day.isEqual(dateTime.day)) {
      dayString = 'Today';
      return dayString;
    } else if (diff >= Duration(days: 1) && diff <= Duration(days: 2)) {
      dayString = 'Yesterday';
      return dayString;
    } else {
      dayString = DateFormat('dd MMMM yyyy').format(dateTime);
      return dayString;
    }
  }
}

class LogButtons extends StatelessWidget {
  final String? name;
  final String? time;
  const LogButtons({
    this.name,
    this.time,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 30,
        ),
        child: Container(
          padding: EdgeInsets.only(
            top: 5,
            bottom: 5,
            right: 10,
          ),
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
              Text(
                name!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                time!,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
