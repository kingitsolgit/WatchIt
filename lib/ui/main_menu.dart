import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/links/baserurl.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/meducine.dart';
import 'package:watch_it/model/prescription.dart';
import 'package:watch_it/model/snoozedmedicine.dart';
import 'package:watch_it/ui/logs.dart';
import 'package:watch_it/ui/medications_list.dart';
import 'package:watch_it/ui/notification_time.dart';
import 'package:watch_it/ui/settings.dart';

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
  WearShape? nShape;

  @override
  initState() {
    super.initState();
    ePrint('pcode is ${widget.pcode}');
    // WidgetsBinding.instance!.addObserver(this);
    callBack1();
  }

  callBack1() {
    Timer.periodic(Duration(seconds: 57), (timer) {
      myCallBack();
    });
    ePrint('In callBack1');
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
        padding: EdgeInsets.all(nShape == WearShape.round ? 8.0 : 0.0),
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
          nShape = shape;
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
                        builder: (context) => MedicationList(),
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

  Future<void> emergencyAlertStatus(
      String text, double latitude, double longitude) async {
    ePrint('Longitude...=$longitude Latitude...=$latitude');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String patientCode = sharedPreferences.getString('p_code')!;
    var url = Uri.parse('${BaseUrl.baseurl}/api/emergency/$patientCode');
    final response = await post(url, body: {
      "text": text,
      "lat": latitude.toString(),
      "lng": longitude.toString()
    });
    if (response.statusCode == 200) {
      ePrint(response.body);
    } else {
      ePrint(response.body);
    }
  }

  onMainMenuCallBack() async {
    List<String> dosingList = [];
    ePrint(
        ' In MainMenu ontMainMenuCallBack Function Start Time ${DateTime.now()}');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('p_code') != null) {
      String? pcode = sharedPreferences.getString('p_code')!;
      var url =
          Uri.parse('${BaseUrl.baseurl}/api/patients/$pcode/prescriptions');
      final response = await get(url);
      if (response.statusCode == 200) {
        ePrint(response.body);
        // print(akbarPrescription); //in service file
        var responc = Prescription.fromJson(jsonDecode(response.body));
        DateFormat dateFormating = DateFormat("dd-MM-yyyy HH:mm");
        // List<String> dosingList = [];
        for (var i = 0; i < responc.data!.length; i++) {
          List<MedicineTime>? medicineTime = responc.data![i].medicineTime;
          for (var j = 0; j < medicineTime!.length; j++) {
            String timeString =
                medicineTime[j].date! + ' ' + medicineTime[j].time!;
            Data preData = responc.data![i];
            DateTime medicineDT = dateFormating.parse(timeString);
            DateTime medicineSubDT = medicineDT.subtract(Duration(minutes: 1));
            ePrint('mySubDT $medicineSubDT');
            DateTime now = DateTime.now();
            if (now.year == medicineSubDT.year &&
                now.month == medicineSubDT.month &&
                now.day == medicineSubDT.day) {
              debugPrint('Day is same');
              if (now.hour == medicineSubDT.hour &&
                  now.minute == medicineSubDT.minute) {
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
              } else {
                ePrint('time is not same');
              }
            } else {
              ePrint('day is not same');
            }
          }
        }
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
              ePrint('In MainMenu next dose added');
              j = medicineTime.length - 1;
            }
            // setAsNextMedicines(myDT,responc);

          }
        }
        ///////////////////code ending for next doses

        /////////////////////////////////for snooze list checking
        ePrint('Outside of snoozed list checking');
        if (sharedPreferences.getStringList('snoozedList') != null) {
          List<String>? snoozedList =
              sharedPreferences.getStringList('snoozedList');
          ePrint('In MainMenu list assigned of ${snoozedList!.length} length');
          for (var i = 0; i < snoozedList.length; i++) {
            ePrint(
                'In MainMenu snooz loop started snoozedList Length ${snoozedList.length}');
            ePrint('In MainMenu list obj $i is ${snoozedList[i]}');
            Map<String, dynamic> dosingMaplistobj = jsonDecode(snoozedList[i]);
            var snoozedMed = SnoozedMedicine.fromJson(dosingMaplistobj);
            // ePrint('In MainMenu snoozedmedicinename: ${snoozedMed.name}, snoozedmedicinetime:  ${snoozedMed.dosetime}');
            DateFormat newdateFormating = DateFormat("dd-MM-yyyy HH:mm");
            DateTime snoozedDT = newdateFormating.parse(snoozedMed.dosetime!);
            //             new if structure start
            if (snoozedMed.snoozedIteration != null &&
                snoozedMed.snoozedIteration! < 3) {
              if (DateTime.now().hour.compareTo(snoozedDT.hour) == 0) {
                ePrint('In MainMenu snooze hour is same');
                if (DateTime.now().minute.compareTo(snoozedDT.minute) == 0) {
                  ePrint('snooze minute is also same');
                  ePrint('At index $i and j');
                  sharedPreferences.setBool("isDoseTime", true);
                  ////////  new code start here
                  print('In MainMenu dosing list $dosingList');
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
                  // print('In MainMenu encoded jsonn $jsonn');
                  dosingList.add(jsonn);
                  ePrint('In MainMenu dosing list $dosingList');
                  sharedPreferences.setStringList('dosingList', dosingList);
                  // await AppLauncher.openApp(
                  //     androidApplicationId: "com.example.watch_it");
                } else {
                  ePrint('In MainMenu minute is also not same.');
                }
              } else {
                ePrint('In MainMenu hour is not same.');
              }
            } else {
              ePrint('In MainMenu ${snoozedMed.dosetime}');
              // DateTime newDT = newdateFormating.parse(snoozedMed.dosetime!);
              // String mTime = DateFormat('HH:mm').format(newDT);
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
                ePrint('In MainMenu ${response.body}');
                snoozedList.removeAt(i);
                ePrint(
                    'In MainMenu: removed by index and snoozedList is $snoozedList');
                sharedPreferences.setStringList('snoozedList', snoozedList);
                ePrint('In MainMenu: snooze list submitted after skipped');
              } else {
                ePrint('In MainMenu ${response.body}');
              }
            }
          }
        } else {
          ePrint('In MainMenu shared snoozed list equal null');
        }
      }
    } else {
      ePrint('In MainMenu pcode is null');
    }
    if (dosingList.isNotEmpty) {
      Get.offAll(NotificationTime());
    } else {
      sharedPreferences.setBool("isDoseTime", false);
      ePrint('In MainMenu: dosing list is empty');
    }
    ePrint(
        ' In MainMenu ontMainMenuCallBack Function End Time ${DateTime.now()}');
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
