import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/links/baserurl.dart';
import 'package:watch_it/medications.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/model/meducine.dart';
import 'package:watch_it/model/prescription.dart';

class Medicat extends StatefulWidget {
  const Medicat({Key? key}) : super(key: key);

  @override
  _MedicatState createState() => _MedicatState();
}

class _MedicatState extends State<Medicat> {
  String? pcode;

  getAndSet() async {
    debugPrint('Call back start time ${DateTime.now()}');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? pcode = sharedPreferences.getString('p_code')!;
    if (pcode != null) {
      var url =
          Uri.parse('${BaseUrl.baseurl}/api/patients/${pcode}/prescriptions');
      // "http://watchit-project.eu/api/patients/$pcode/prescriptions");
      final response = await get(url);
      if (response.statusCode == 200) {
        print(response.body);
        // print(akbarPrescription);

        var responc = Prescription.fromJson(jsonDecode(response.body));
        // var responc = Prescription.fromJson(jsonDecode(akbarPrescription!));

        ////////////////
        ///////////code start for next doses
        List<String> nextDoseList = [];
        sharedPreferences.remove('nextDoseList');
        ePrint('nextDoseList is removed');
        for (var i = 0; i < responc.data!.length; i++) {
          Data prescriptionData = responc.data![i];
          List<MedicineTime>? medicineTime = prescriptionData.medicineTime;
          for (var j = 0; j < medicineTime!.length; j++) {
            /////////////////   New code for next doses
            String timeInString =
                medicineTime[j].date! + ' ' + medicineTime[j].time!;
            DateFormat newdateFormating =
                DateFormat("dd-MM-yyyy HH:mm", "en_US");

            DateTime newDT = newdateFormating.parse(timeInString);
            print('newDT $newDT');
            if (newDT.isAfter(DateTime.now())) {
              print('time isAfter from now');
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
              print('Next doses Encoded $meducineString end the');
              nextDoseList.add(meducineString);
              print(nextDoseList);
              sharedPreferences.setStringList('nextDoseList', nextDoseList);
              ePrint('next dose added');
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
      ePrint('code not found in medication');
    }
  }

  Future getPosts() async {
    getAndSet();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    pcode = sharedPreferences.getString('p_code')!;
    var url = Uri.parse('${BaseUrl.baseurl}/api/patients/$pcode/prescriptions');
    // "http://watchit-project.eu/api/patients/$pcode/prescriptions");
    final response = await get(url);
    if (response.statusCode == 200) {
      print(response.body);
      print('before response');
      return Prescription.fromJson(jsonDecode(response.body));
      // return Prescription.fromJson(jsonDecode(akbarPrescription!));
    } else {
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Prescription? prescription = snapshot.data as Prescription;
            print('snapshot length ');
            // saveTimeandMed(prescription);
            print(prescription.data!.length);
            // print(prescription.data![0].medicineName);
            return Scaffold(
              backgroundColor: Colors.black,
              body: WatchShape(
                builder: (context, shape, child) {
                  if (prescription.data!.length != 0) {
                    return Container(
                      width: Get.width,
                      height: Get.height,
                      decoration: BoxDecoration(),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Material(
                              color: Colors.black,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  tr('medications'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: Get.width,
                              color: Colors.black,
                              height: 4,
                            ),
                            SizedBox(
                              height: shape == WearShape.round
                                  ? Get.height / 1.1
                                  : Get.height / 1.2,
                              child: ListView.builder(
                                itemCount: prescription.data!.length + 1,
                                itemBuilder: (context, index) {
                                  print(index);
                                  return index != prescription.data!.length
                                      ? MedicineButton(
                                          shape: shape,
                                          name:
                                              '${prescription.data![index].medicineName.toString()} ',
                                          time: 'The Time is: ',
                                          medicineDuration: prescription
                                              .data![index].doseTimeDuration,
                                          times: prescription
                                              .data![index].medicineTime,
                                          dailydoses: prescription
                                              .data![index].dailyDosePill,
                                        )
                                      : SizedBox(
                                          height: 50,
                                        );
                                },
                              ),
                            ),
                            // SizedBox(
                            //   height: 80,
                            // ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Scaffold(
                      body: Center(
                        child: Text('Medicine Not Assigned.'),
                      ),
                    );
                  }
                },
                // child: AmbientMode(
                //   builder: (context, mode, child) {
                //     return Text(
                //       'Mode: ${mode == WearMode.active ? 'Active' : 'Ambient'}',
                //     );
                //   },
                // ),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('No Medication Data')),
            );
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  mediTimeText(List<String>? thisMediTime) {
    String t = '';
    switch (thisMediTime!.length) {
      case 1:
        t = 'Daily at ${thisMediTime[0]}';
        break;
      case 2:
        t = 'Twice a day at ${thisMediTime[0]} and ${thisMediTime[1]}';
        break;
      case 3:
        t = 'In a day at ${thisMediTime[0]}, ${thisMediTime[1]} and ${thisMediTime[2]}';
        break;
      case 4:
        t = 'In a day at ${thisMediTime[0]}, ${thisMediTime[1]}, ${thisMediTime[2]} and ${thisMediTime[3]}';
        break;
      case 5:
        t = 'In a day at ${thisMediTime[0]}, ${thisMediTime[1]}, ${thisMediTime[2]}, ${thisMediTime[3]} and ${thisMediTime[4]}';
        break;
      case 6:
        t = 'In a day at ${thisMediTime[0]}, ${thisMediTime[1]}, ${thisMediTime[2]}, ${thisMediTime[3]}, ${thisMediTime[4]} and ${thisMediTime[5]}';
        break;
      case 7:
        t = 'In a day at ${thisMediTime[0]}, ${thisMediTime[1]}, ${thisMediTime[2]}, ${thisMediTime[3]}, ${thisMediTime[4]}, ${thisMediTime[5]} and ${thisMediTime[6]}';
        break;
      case 8:
        t = 'In a day at ${thisMediTime[0]}, ${thisMediTime[1]}, ${thisMediTime[2]}, ${thisMediTime[3]}, ${thisMediTime[4]}, ${thisMediTime[5]}, ${thisMediTime[6]} and ${thisMediTime[7]}';
        break;
      case 9:
        t = 'In a day at ${thisMediTime[0]}, ${thisMediTime[1]}, ${thisMediTime[2]}, ${thisMediTime[3]}, ${thisMediTime[4]}, ${thisMediTime[5]}, ${thisMediTime[6]}, ${thisMediTime[7]} and ${thisMediTime[8]}';
        break;
      case 10:
        t = 'In a day at ${thisMediTime[0]}, ${thisMediTime[1]}, ${thisMediTime[2]}, ${thisMediTime[3]}, ${thisMediTime[4]}, ${thisMediTime[5]}, ${thisMediTime[6]}, ${thisMediTime[7]}, ${thisMediTime[8]}  and ${thisMediTime[9]}';

        break;
      default:
    }
    return t;
  }

  Future<void> setNextDoses(var body) async {
    var responc = Prescription.fromJson(jsonDecode(body));
    List<String> nextDoseList = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('nextDoseList');
    ePrint('nextDoseList is removed');
    for (var i = 0; i < responc.data!.length; i++) {
      Data prescriptionData = responc.data![i];
      List<MedicineTime>? medicineTime = prescriptionData.medicineTime;
      for (var j = 0; j < medicineTime!.length; j++) {
        /////////////////   New cdoe for next doses
        String timeInString =
            medicineTime[j].date! + ' ' + medicineTime[j].time!;
        DateFormat newdateFormating = DateFormat("dd-MM-yyyy HH:mm");

        DateTime newDT = newdateFormating.parse(timeInString);
        print('newDT $newDT');
        if (newDT.isAfter(DateTime.now())) {
          print('time isAfter from now');
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
          print('Next doses Encoded $meducineString end the');
          nextDoseList.add(meducineString);
          print(nextDoseList);
          sharedPreferences.setStringList('nextDoseList', nextDoseList);
          ePrint('next dose added');
        }
      }
    }
  }
}

class MedicineButton extends StatelessWidget {
  final String? name;
  final String? time;
  final String? medicineDuration;
  final int? dailydoses;
  final List<MedicineTime>? times;

  final WearShape? shape;
  const MedicineButton({
    this.name,
    this.time,
    Key? key,
    this.times,
    this.medicineDuration,
    this.dailydoses,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.only(
          left: shape == WearShape.round ? 30 : 12,
        ),
        child: Container(
          width: Get.width,
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
                name!.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  time!,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(
                height: 28,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dailydoses!, // 3, //times!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Material(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Text(
                                times![index].time!,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              Text(
                medicineDuration!,
                // '25-10-2020 to 23-23-32',
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
