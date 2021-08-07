import 'dart:async';
import 'dart:convert';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:app_launcher/app_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/model/my_strings.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/links/baserurl.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/meducine.dart';
import 'package:watch_it/model/prescription.dart';
import 'package:watch_it/model/snoozedmedicine.dart';
import 'package:watch_it/provider/languageprovider.dart';
import 'package:watch_it/ui/languages.dart';
import 'package:watch_it/ui/logs.dart';
import 'package:watch_it/ui/main_menu.dart';
import 'package:watch_it/ui/notification_time.dart';
import 'package:watch_it/ui/pair_screen.dart';
import 'package:watch_it/ui/settings.dart';
import 'package:watch_it/ui/snooze_confirm.dart';
import 'package:watch_it/ui/snooze_duration.dart';
import 'package:watch_it/ui/take_it_now.dart';

getAndCheck() async {
  DateTime nowExact = DateTime.now();
  ePrint('In Main.dart: getAndCheck Call back start time ${DateTime.now()}');
  List<String> dosingList = [];
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  if (sharedPreferences.getString('p_code') != null) {
    String? pcode = sharedPreferences.getString('p_code')!;
    var url = Uri.parse('${BaseUrl.baseurl}/api/patients/$pcode/prescriptions');
    final response = await get(url);
    if (response.statusCode == 200) {
      ePrint(response.body);
      sharedPreferences.setString('responseString', response.body);
      ePrint('Response Saved');
      var responc = Prescription.fromJson(jsonDecode(response.body));
      DateFormat dateFormating = DateFormat("dd-MM-yyyy HH:mm");
      // List<String> dosingList = [];
      for (var i = 0; i < responc.data!.length; i++) {
        Data preData = responc.data![i];
        List<MedicineTime>? medicineTime = responc.data![i].medicineTime;
        for (var j = 0; j < medicineTime!.length; j++) {
          String timeString =
              medicineTime[j].date! + ' ' + medicineTime[j].time!;
          DateTime myDT =
              dateFormating.parse(timeString).subtract(Duration(minutes: 1));
          // myDT.subtract(Duration(minutes: 1));
          ePrint('In Main.dart: subtracted myDT $myDT');
          // if (DateTime.now().hour.compareTo(myDT.hour) == 0) {
          // DateTime now = DateTime.now();
          if (medicineTime[j].status == 'Pending') {
            if (nowExact.year == myDT.year &&
                nowExact.month == myDT.month &&
                nowExact.day == myDT.day) {
              ePrint('In Main.dart: Day is same');
              if (nowExact.hour == myDT.hour &&
                  nowExact.minute == myDT.minute) {
                ePrint('In Main.dart: time is also same');
                // ePrint('In Main.dart: at index $i and $j');
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
                // ePrint('encoded $jsonn');
                dosingList.add(jsonn);
                // ePrint(dosingList);
                sharedPreferences.setStringList('dosingList', dosingList);
              } else {
                ePrint('In Main.dart: time is not same');
              }
            } else {
              ePrint('In Main.dart: day is not same');
            }
          }
        }
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
            j = medicineTime.length - 1;
          }
          // setAsNextMedicines(myDT,responc);
        }
      }
      //////////////////code ending for next doses

    } else {
      ePrint(response.body);
    }
  } else {
    ePrint('In Main.dart: pcode is null');
  }
  //////for snooze list checking
  ePrint('Outside of snoozed list checking');
  List<String>? snoozedList;
  if (sharedPreferences.getStringList('snoozedList') != null) {
    // ePrint('In Main.dart: not equal null');
    snoozedList = sharedPreferences.getStringList('snoozedList');
    ePrint('In Main.dart: list assigned of ${snoozedList!.length} length');
    for (var i = 0; i < snoozedList.length; i++) {
      // ePrint('In Main.dart: snooz loop started snoozedList Length ${snoozedList.length}');
      ePrint('In Main.dart: list obj $i is ${snoozedList[i]}');
      Map<String, dynamic> dosingMaplistobj = jsonDecode(snoozedList[i]);
      var snoozedMed = SnoozedMedicine.fromJson(dosingMaplistobj);
      // ePrint('In Main.dart: snoozedmedicinename: ${snoozedMed.name}, snoozedmedicinetime:  ${snoozedMed.dosetime}');
      DateFormat newdateFormating = DateFormat("dd-MM-yyyy HH:mm");
      DateTime snoozedDT = newdateFormating.parse(snoozedMed.dosetime!);
      //                 new if structure start
      if (snoozedMed.snoozedIteration != null &&
          snoozedMed.snoozedIteration! <= 3) {
        if (nowExact.hour.compareTo(snoozedDT.hour) == 0) {
          // ePrint('In Main.dart: snooze hour is same');
          if (nowExact.minute.compareTo(snoozedDT.minute) == 0) {
            // ePrint('In Main.dart: snooze minute is same');
            sharedPreferences.setBool("isDoseTime", true);
            ////////  new code start here
            ePrint('In Main.dart: $dosingList');
            Meducine meducine = Meducine(
              medicineId: snoozedMed.id,
              medicineName: snoozedMed.name,
              dailyDosePill: snoozedMed.routine,
              medicineTime: snoozedMed.dosetime,
              medicinetimeindex: snoozedMed.timeIndex,
              dateRange: snoozedMed.dosetime,
              isSnoozed: snoozedMed.isSnoozed,
              snoozedIteration: snoozedMed.snoozedIteration,
            );
            String jsonn = jsonEncode(meducine);
            // ePrint('In Main.dart: snoozed encoded $jsonn');
            dosingList.add(jsonn);
            ePrint('dosingList encoded $dosingList');
            sharedPreferences.setStringList('dosingList', dosingList);
          } else {
            ePrint('In Main.dart: snoozed minute is also not same');
          }
        } else {
          ePrint('In Main.dart: snoozed hour is not same');
        }
      } else {
        ePrint(
            'In Main.dart: SnoozedIteration >= 3 and value is ${snoozedMed.snoozedIteration}');
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
          ePrint('In Main.dart: snooze skip response ${response.body}');
          snoozedList.removeAt(i);
          ePrint(
              'In Main.dart: removed by index and snoozedList is $snoozedList');
          sharedPreferences.setStringList('snoozedList', snoozedList);
          ePrint('In Main.dart: snooze list submitted after skipped');
        } else {
          ePrint('In Main.dart: ${response.body}');
        }
      }
    }
  } else {
    ePrint('In Main.dart:shared snoozedlist equal null');
  }
  /////////////  snoozed checking end
  /////////////  lauching code
  if (dosingList.isNotEmpty) {
    await AppLauncher.openApp(androidApplicationId: "com.example.watch_it");
  } else {
    ePrint('In Main.dart: dosingList is empty');
    sharedPreferences.setBool("isDoseTime", false);
  }
  ePrint('In Main.dart: getAndCheck Call back end time ${DateTime.now()}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  final int alarmID = 0;
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.periodic(
      Duration(seconds: 59), alarmID, getAndCheck);
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool? isDoseTime = sharedPreferences.getBool("isDoseTime");
  ePrint('In main() dosetime $isDoseTime');
  int screenindex = 0;
  if (isDoseTime == true) {
    screenindex = 1;
    ePrint('screen index in if is $screenindex');
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
      child: screens[screenindex],
    ),
  );
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
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        initialRoute: SplashScreen.id,
        routes: {
          SplashScreen.id: (context) => SplashScreen(),
          MainMenu.id: (context) => MainMenu(),
          Settings.id: (context) => Settings(),
          Logs.id: (context) => Logs(),
          NotificationTime.id: (context) => NotificationTime(),
          SnoozeConfirm.id: (context) => SnoozeConfirm(),
          SnoozeDuration.id: (context) => SnoozeDuration(),
          TakeItNow.id: (context) => TakeItNow(),
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
    ePrint('in splash getdata');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? sllang = sharedPreferences.getString("apilang");
    isPaired = sharedPreferences.getBool("isPaired");
    if (isPaired != null && isPaired == true) {
      pName = sharedPreferences.getString('p_name');
      pEmail = sharedPreferences.getString('p_email');
      pCode = sharedPreferences.getString('p_code');
    }

    Timer(
      Duration(seconds: 6),
      () => Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
          builder: (BuildContext context) {
            return isPaired == true
                ? new MainMenu(
                    pemail: pEmail,
                    pname: pName,
                    pcode: pCode,
                  )
                : sllang == null
                    ? new Languages(accesspoint: 0)
                    : PairScreen();
          },
        ),
      ),
    );
    // print(sllang);
    if (sllang != null) {
      setState(() {
        selectedlanguage = sllang;
      });
    } else {
      setState(() {
        selectedlanguage = "en";
      });
    }
    ePrint(selectedlanguage!);
    // print('and then ' + selectedlanguage.toString());
    var setlanguage = Provider.of<LanguageProvider>(context, listen: false);
    setlanguage.setleanguage(selectedlanguage!);
  }
}

getAndCheckFromLocal() async {
  DateTime nowExact = DateTime.now();
  ePrint(
      'In Main.dart: getAndCheckFromLocal Call back start time ${DateTime.now()}');
  List<String> dosingList = [];
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var responc = Prescription.fromJson(jsonDecode(akbarPrescription!));
  DateFormat dateFormating = DateFormat("dd-MM-yyyy HH:mm");
  for (var i = 0; i < responc.data!.length; i++) {
    Data preData = responc.data![i];
    List<MedicineTime>? medicineTime = responc.data![i].medicineTime;
    for (var j = 0; j < medicineTime!.length; j++) {
      String timeString = medicineTime[j].date! + ' ' + medicineTime[j].time!;
      DateTime myDT =
          dateFormating.parse(timeString).subtract(Duration(minutes: 1));
      ePrint('In Main.dart: subtracted myDT $myDT');
      if (medicineTime[j].status == 'Pending') {
        if (nowExact.year == myDT.year &&
            nowExact.month == myDT.month &&
            nowExact.day == myDT.day) {
          ePrint('In Main.dart: Day is same');
          if (nowExact.hour == myDT.hour && nowExact.minute == myDT.minute) {
            ePrint('In Main.dart: time is also same');
            ePrint('In Main.dart: at index $i and $j');
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
            // ePrint('encoded $jsonn');
            dosingList.add(jsonn);
            // ePrint(dosingList);
            sharedPreferences.setStringList('dosingList', dosingList);
          } else {
            ePrint('In Main.dart: time is not same');
          }
        } else {
          ePrint('In Main.dart: day is not same');
        }
      }
    }
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
      String timeInString = medicineTime[j].date! + ' ' + medicineTime[j].time!;
      DateFormat newdateFormating = DateFormat("dd-MM-yyyy HH:mm");
      DateTime newDT = newdateFormating.parse(timeInString);
      // ePrint('In Main.dart: newDT $newDT');
      if (newDT.isAfter(DateTime.now())) {
        // ePrint('In Main.dart: time isAfter from now');
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
        j = medicineTime.length - 1;
      }
      // setAsNextMedicines(myDT,responc);
    }
  }
  //////////////////code ending for next doses

  //////for snooze list checking
  ePrint('Outside of snoozed list checking');
  List<String>? snoozedList;
  if (sharedPreferences.getStringList('snoozedList') != null) {
    // ePrint('In Main.dart: not equal null');
    snoozedList = sharedPreferences.getStringList('snoozedList');
    ePrint('In Main.dart: list assigned of ${snoozedList!.length} length');
    for (var i = 0; i < snoozedList.length; i++) {
      // ePrint('In Main.dart: snooz loop started snoozedList Length ${snoozedList.length}');
      ePrint('In Main.dart: list obj $i is ${snoozedList[i]}');
      Map<String, dynamic> dosingMaplistobj = jsonDecode(snoozedList[i]);
      var snoozedMed = SnoozedMedicine.fromJson(dosingMaplistobj);
      // ePrint('In Main.dart: snoozedmedicinename: ${snoozedMed.name}, snoozedmedicinetime:  ${snoozedMed.dosetime}');
      DateFormat newdateFormating = DateFormat("dd-MM-yyyy HH:mm");
      DateTime snoozedDT = newdateFormating.parse(snoozedMed.dosetime!);
      //                 new if structure start
      if (snoozedMed.snoozedIteration != null &&
          snoozedMed.snoozedIteration! <= 3) {
        if (nowExact.hour.compareTo(snoozedDT.hour) == 0) {
          // ePrint('In Main.dart: snooze hour is same');
          if (nowExact.minute.compareTo(snoozedDT.minute) == 0) {
            // ePrint('In Main.dart: snooze minute is same');
            sharedPreferences.setBool("isDoseTime", true);
            ////////  new code start here
            ePrint('In Main.dart: $dosingList');
            Meducine meducine = Meducine(
              medicineId: snoozedMed.id,
              medicineName: snoozedMed.name,
              dailyDosePill: snoozedMed.routine,
              medicineTime: snoozedMed.dosetime,
              medicinetimeindex: snoozedMed.timeIndex,
              dateRange: snoozedMed.dosetime,
              isSnoozed: snoozedMed.isSnoozed,
              snoozedIteration: snoozedMed.snoozedIteration,
            );
            String jsonn = jsonEncode(meducine);
            // ePrint('In Main.dart: snoozed encoded $jsonn');
            dosingList.add(jsonn);
            ePrint('dosingList encoded $dosingList');
            sharedPreferences.setStringList('dosingList', dosingList);
          } else {
            ePrint('In Main.dart: snoozed minute is also not same');
          }
        } else {
          ePrint('In Main.dart: snoozed hour is not same');
        }
      } else {
        ePrint(
            'In Main.dart: SnoozedIteration >= 3 and value is ${snoozedMed.snoozedIteration}');
        String patientCode = sharedPreferences.getString('p_code')!;
        var url = Uri.parse(
            '${BaseUrl.baseurl}/api/patients/$patientCode/prescriptions/${snoozedMed.id}');
        final response = await patch(
          url,
          body: {
            "status": "Skippedz",
            "time": snoozedMed.dosetime, // "13:30",
            "medicine_time_id": '${snoozedMed.timeIndex}' // 2
          },
        );
        if (response.statusCode == 200) {
          ePrint('In Main.dart: snooze skip response ${response.body}');
          snoozedList.removeAt(i);
          ePrint(
              'In Main.dart: removed by index and snoozedList is $snoozedList');
          sharedPreferences.setStringList('snoozedList', snoozedList);
          ePrint('In Main.dart: snooze list submitted after skipped');
        } else {
          ePrint('In Main.dart: ${response.body}');
        }
      }
    }
  } else {
    ePrint('In Main.dart:shared snoozedlist equal null');
  }
  /////////////  snoozed checking end
  /////////////  lauching code
  if (dosingList.isNotEmpty) {
    await AppLauncher.openApp(androidApplicationId: "com.example.watch_it");
  } else {
    ePrint('In Main.dart: dosingList is empty');
    sharedPreferences.setBool("isDoseTime", false);
  }
  ePrint(
      'In Main.dart: getAndCheckFromLocal Call back end time ${DateTime.now()}');
}
