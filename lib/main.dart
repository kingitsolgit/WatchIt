import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:app_launcher/app_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/account.dart';
import 'package:watch_it/languages.dart';
import 'package:watch_it/links/baserurl.dart';
import 'package:watch_it/logs.dart';
import 'package:watch_it/main_menu.dart';
import 'package:watch_it/medications.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/meducine.dart';
import 'package:watch_it/model/prescription.dart';
import 'package:watch_it/model/snoozedmedicine.dart';
import 'package:watch_it/model/statics.dart';
import 'package:watch_it/notification_time.dart';
import 'package:watch_it/provider/languageprovider.dart';
import 'package:watch_it/services/apidata.dart';
import 'package:watch_it/settings.dart';
import 'package:watch_it/snooze_confirm.dart';
import 'package:watch_it/snooze_time.dart';
import 'package:watch_it/take_it_now.dart';

bool isAlarmOn = false;

Future<void> playSound() async {
  isAlarmOn = true;
  print('in sound callback $isAlarmOn');

  // print('in sound callback $isAlarmOn');

  // await AppLauncher.openApp(
  //   androidApplicationId: "com.example.watch_it", // "com.whatsapp",
  // );
// com.example.watch_it

  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Play with, world! isolate=${isolateId} function='$playSound'");

  getmediList();

////////////////////  Check here if it is dose time or not ////////////////////
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
  DateTime myDateTime = dateFormat.parse("2021-07-05 15:25");
  print(myDateTime);
  // myDateTime.add(Duration(minutes: 10));
  print('added date is $myDateTime');
  if (DateTime.now().hour.compareTo(myDateTime.hour) == 0) {
    print('hour is same');
    if (DateTime.now().minute.compareTo(myDateTime.minute) == 0) {
      print('minute is also same');
      sharedPreferences.setBool("isDoseTime", true);
      await AppLauncher.openApp(
        androidApplicationId: "com.example.watch_it", // "com.whatsapp",
      );
    } else {
      sharedPreferences.setBool("isDoseTime", false);
    }
  } else {
    sharedPreferences.setBool("isDoseTime", false);
  }
  /////// for on testin and implementation..............
  // sharedPreferences.setBool("isDoseTime", false);
////////////////////  checking end   ///////////////////////////

  // FlutterRingtonePlayer.stop();
  // await FlutterRingtonePlayer.playNotification();

  // void main() {
  //   runApp(NotificationTime());
  // }
}

Future<void> getmediList() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  List<String>? listmedi = sharedPreferences.getStringList("preslist");
  print(listmedi);
}

void hitMeicationAPIRecursively() {
  ApiData.getData();
}

Future<void> getMedicationAndSaveIt() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  Map<String, dynamic> values = new Map<String, dynamic>();

  String? medicString = sharedPreferences.getString("medicString");
  print(medicString);
  values = jsonDecode(medicString!);
  values.forEach((key, value) {
    // print(value);
    if (key == 'data') {
      print('object of keyvalue');
      print(value.length);
      print('///WE ARE IN MAIN FILE////');
      String? date2;
      List<String>? mediList = [];
      for (var i = 0; i < value.length; i++) {
        for (var j = 0; j < value[i]['medicine_time'].length; j++) {
          print(value[i]['date']);
          print(value[i]['medicine_time'][j]);
          date2 = '${value[i]['date']} ${value[i]['medicine_time'][j]}';

          DateFormat dateFormating = DateFormat("dd-MM-yyyy HH:mm");
          DateTime dateTime2 = dateFormating.parse(date2);

          if (DateTime.now().hour.compareTo(dateTime2.hour) == 0) {
            if (DateTime.now().minute.compareTo(dateTime2.minute) == 0) {
              print('Allarm OONNNN');
              List<String> list = [];
              list.add(value[i]['_id']);
              list.add(value[i]['medicine_name']);
            } else {
              print('Allarm FAILED IN MINUTE');
            }
          } else {
            print('Allarm  FAILED IN HOUR');
          }
        }
      }
      print(mediList);
      print('date2 $date2');
      DateFormat dateFormat2 = DateFormat("dd-MM-yyyy HH:mm");
      DateTime myDateTime2 = dateFormat2.parse(date2!);
      //("20-07-2005 18:26");
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
      DateTime myDateTime = dateFormat.parse("2021-07-05 18:26");
      DateTime myNowDateTime = dateFormat.parse(DateTime.now().toString());
      ePrint('myNowDateTime is $myNowDateTime');

      print('date is $myDateTime2');
      print('///111111111111111111111111111111111111111////');
      print(value[0]['date']);
      // print(value[0]['medicine_time'][1]['time']);
      print(value[0]['medicine_time'].length);
    }
  });
}

getAndCheck() async {
  debugPrint('Call back start time ${DateTime.now()}');
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  if (sharedPreferences.getString('p_code') != null) {
    String? pcode = sharedPreferences.getString('p_code')!;
    var url =
        Uri.parse('${BaseUrl.baseurl}/api/patients/${pcode}/prescriptions');
    final response = await get(url);
    if (response.statusCode == 200) {
      ePrint(response.body);
      // print(akbarPrescription);

      var responc = Prescription.fromJson(jsonDecode(response.body));
      // var responc = Prescription.fromJson(jsonDecode(akbarPrescription!));
      // var date = responc.data![0].date;
      // print('new extracted date is $date');
      DateFormat dateFormating = DateFormat("dd-MM-yyyy HH:mm");
      List<String> dosingList = [];
      for (var i = 0; i < responc.data!.length; i++) {
        var dur = responc.data![i].doseTimeDuration;
        // print('Duration is $dur');
        List<MedicineTime>? medicineTime = responc.data![i].medicineTime;
        for (var j = 0; j < medicineTime!.length; j++) {
          String timeString =
              medicineTime[j].date! + ' ' + medicineTime[j].time!;
          Data preData = responc.data![i];
          DateTime myDT = dateFormating.parse(timeString);
          myDT.subtract(Duration(minutes: 1));
          ePrint('In Main.dart: myDT $myDT');

          // if (DateTime.now().hour.compareTo(myDT.hour) == 0) {
          DateTime now = DateTime.now();
          if (now.year == myDT.year &&
              now.month == myDT.month &&
              now.day == myDT.day) {
            debugPrint('In Main.dart: Day is same');
            if (now.hour == myDT.hour && now.minute == myDT.minute) {
              debugPrint('In Main.dart: time is also same');
              int index = i;
              ePrint('In Main.dart: at index $i and $j');
              sharedPreferences.setBool("isDoseTime", true);
              Parameters.isDozeTime = true;
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
              // ePrint('encoded $jsonn');
              dosingList.add(jsonn);
              // ePrint(dosingList);
              sharedPreferences.setStringList('dosingList', dosingList);
              // await AppLauncher.openApp(
              //     androidApplicationId: "com.example.watch_it");
            } else {
              ePrint('In Main.dart: time is not same');
              sharedPreferences.setBool("isDoseTime", false);
            }
          } else {
            ePrint('In Main.dart: day is not same');
            sharedPreferences.setBool("isDoseTime", false);
          }
        }
      }
      if (dosingList.isNotEmpty) {
        await AppLauncher.openApp(androidApplicationId: "com.example.watch_it");
      }
      ///////////code start for next doses
      List<String> nextDoseList = [];
      sharedPreferences.remove('nextDoseList');
      ePrint('In Main.dart: nextDoseList is removed');
      for (var i = 0; i < responc.data!.length; i++) {
        Data prescriptionData = responc.data![i];
        List<MedicineTime>? medicineTime = prescriptionData.medicineTime;
        for (var j = 0; j < medicineTime!.length; j++) {
          /////////////////   New code for next doses
          String timeInString =
              medicineTime[j].date! + ' ' + medicineTime[j].time!;
          DateFormat newdateFormating = DateFormat("dd-MM-yyyy HH:mm");

          DateTime newDT = newdateFormating.parse(timeInString);
          // ePrint('In Main.dart: newDT $newDT');
          if (newDT.isAfter(DateTime.now())) {
            // ePrint('In Main.dart: time isAfter from now');
            j = medicineTime.length - 1;
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
            // ePrint('In Main.dart: Next doses Encoded $meducineString end the');
            nextDoseList.add(meducineString);
            // ePrint(In Main.dart: nextDoseList);
            sharedPreferences.setStringList('nextDoseList', nextDoseList);
            ePrint('In Main.dart: next dose added');
          }
          // setAsNextMedicines(myDT,responc);

        }
      }
      //////////////////code ending for next doses
      //////for snooze list checking
      // List<String>? snoozedList;
      // sharedPreferences.setStringList('snoozedList', snoozedList!);

      if (sharedPreferences.getStringList('snoozedList') != null) {
        // ePrint('In Main.dart: not equal null');
        List<String>? snoozedList =
            sharedPreferences.getStringList('snoozedList');
        ePrint('In Main.dart: list assigned of ${snoozedList!.length} length');
        for (var i = 0; i < snoozedList.length; i++) {
          ePrint('In Main.dart: snooz loop started////////////////////');
          ePrint('In Main.dart: list obj $i is ${snoozedList[i]}');
          Map<String, dynamic> dosingMaplistobj = jsonDecode(snoozedList[0]);
          var snoozedMed = SnoozedMedicine.fromJson(dosingMaplistobj);
          ePrint(
              'In Main.dart: snoozedmedicinename: ${snoozedMed.name}, snoozedmedicinetime:  ${snoozedMed.dosetime}');
          DateFormat newdateFormating = DateFormat("dd-MM-yyyy HH:mm");
          DateTime snoozedDT = newdateFormating.parse(snoozedMed.dosetime!);

          // .add(Duration(minutes: snoozedMed.snoozedDurationMins!));
          // ///////////////new if structure start
          if (snoozedMed.snoozedIteration != null &&
              snoozedMed.snoozedIteration! < 3) {
            if (DateTime.now().hour.compareTo(snoozedDT.hour) == 0) {
              debugPrint('In Main.dart: snooze hour is same');
              if (DateTime.now().minute.compareTo(snoozedDT.minute) == 0) {
                debugPrint('In Main.dart: snooze minute is also same');
                int index = i;
                print('In Main.dart: at index $i and j');
                sharedPreferences.setBool("isDoseTime", true);
                ////////  new code start here
                print('In Main.dart: $dosingList');

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
                print('In Main.dart: encoded $jsonn');
                dosingList.add(jsonn);
                print(dosingList);
                sharedPreferences.setStringList('dosingList', dosingList);

                await AppLauncher.openApp(
                    androidApplicationId: "com.example.watch_it");
              } else {
                debugPrint('In Main.dart: minute is also not same');
                sharedPreferences.setBool("isDoseTime", false);
              }
            } else {
              debugPrint('In Main.dart: hour is not same');
              sharedPreferences.setBool("isDoseTime", false);
            }
          } else {
            ePrint('In Main.dart: ${snoozedMed.dosetime}');

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
              print('In Main.dart: ${response.body}');
            } else {
              print('In Main.dart: ${response.body}');
            }
          }
        }
      } else {
        ePrint('In Main.dart: equal null');
      }
      // ///////////
    }
  } else {
    print('In Main.dart: pcode is null');
  }

  ePrint('In Main.dart: Call back end time ${DateTime.now()}');
}

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // FlutterBackgroundService.initialize(onStart);
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  final int alarmID = 0;
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await AndroidAlarmManager.periodic(
      Duration(seconds: 57), alarmID, getAndCheck);
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool? isDoseTime = sharedPreferences.getBool("isDoseTime");
  print('In servise dosetime $isDoseTime');
  int screenindex = 0;
  if (isDoseTime == true) {
    screenindex = 1;
    print('screen index in if is $screenindex');
  }

  var screens = [
    MyApp(),
    NotificationTime(),
  ];

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale("en", "US"),
        Locale("el", "GR"),
        Locale("fr", "FR"),
        Locale("de", "GE"),
      ],
      path: "assets/locals",
      saveLocale: true,
      child: screens[screenindex], // MyApp(), // MyAlertApp(),
    ),
  );
  // runApp(MyApp());
}

void onStart() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {
    if (event!["action"] == "setAsForeground") {
      service.setForegroundMode(true);
      return;
    }

    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
      service.setNotificationInfo(title: 'Watch It is working in background');
    }

    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
  });

  // bring to foreground
  service.setForegroundMode(true);
  Timer.periodic(Duration(seconds: 50), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();

    //   get dose time
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? doseTime = sharedPreferences.getString("nextDoseTime");
    // == null
    //     ? "2:50"
    //     : sharedPreferences.getString("nextDoseTime");
    print('In servise dosetime $doseTime');
    bool? isDoseTime = sharedPreferences.getBool("isDoseTime");
    print('In servise dosetime $isDoseTime');

    service.setNotificationInfo(
      title: "Watch IT",
      content:
          "Your Next Dose Time is $doseTime", //${Duration(hours: 13, minutes: 15)}",
      // content: "Updated at ${DateTime.now()}",
    );

    service.sendData(
      {
        // "current_date": DateTime.now().toIso8601String(),
        "dose_time":
            DateTime.now().add(Duration(minutes: 15)).toIso8601String(),
      },
    );
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LanguageProvider>(
          create: (context) {
            return LanguageProvider();
          },
        ),
      ],
      child: GetMaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        initialRoute: SplashScreen.id,
        routes: {
          SplashScreen.id: (context) => SplashScreen(),
          AccountScreen.id: (context) => AccountScreen(),
          // PairScreen.id: (context) => PairScreen(),
          MainMenu.id: (context) => MainMenu(),
          Settings.id: (context) => Settings(),
          Medications.id: (context) => Medications(),
          Logs.id: (context) => Logs(),
          NotificationTime.id: (context) => NotificationTime(),
          SnoozeConfirm.id: (context) => SnoozeConfirm(),
          SnoozeTime.id: (context) => SnoozeTime(),
          TakeItNow.id: (context) => TakeItNow(),
          // Languages.id: (context) => Languages(),
        },
        // home: MyApp(),
      ),
    );
  }
}

////////////// Splash Screen ////////////////////////////////////

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static String id = 'splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? selectedlanguage;
  bool? isPaired = false;
  String? pName;
  String? pEmail;
  String? pCode;
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return Scaffold(
          body: Container(
            height: Get.height,
            width: Get.width,
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/clock.png',
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Watch it'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> getData() async {
    print('in splash getdata');

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? sllang = sharedPreferences.getString("apilang");
    isPaired = sharedPreferences.getBool("isPaired");
    // print('after pair');
    if (isPaired != null && isPaired == true) {
      pName = sharedPreferences.getString('p_name');
      pEmail = sharedPreferences.getString('p_email');
      pCode = sharedPreferences.getString('p_code');
    }
    // print('after if condition');

    Timer(
      Duration(seconds: 6),
      () => Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
          builder: (BuildContext context) {
            return isPaired == true
                ? new MainMenu(
                    pemail: pEmail,
                    pname: pName,
                  )
                : sllang == null
                    ? new Languages(accesspoint: 0)
                    : AccountScreen();
          },
        ),
      ),
    );
    print(sllang);
    if (sllang != null) {
      setState(() {
        selectedlanguage = sllang;
      });
    } else {
      setState(() {
        selectedlanguage = "en";
      });
    }
    print(selectedlanguage);
    // print('and then ' + selectedlanguage.toString());
    var setlanguage = Provider.of<LanguageProvider>(context, listen: false);
    setlanguage.setleanguage(selectedlanguage!);
  }
}
