import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/logs.dart';
import 'package:watch_it/main_menu.dart';
import 'package:watch_it/model/prescription.dart';
import 'package:watch_it/pair_screen.dart';
import 'package:watch_it/provider/prescriptionprovider.dart';
import 'package:wear/wear.dart';

class Medications extends StatefulWidget {
  const Medications({Key? key}) : super(key: key);
  static String id = 'medications';

  @override
  _MedicationsState createState() => _MedicationsState();
}

class _MedicationsState extends State<Medications> {
  // User? user;
  late final mdata;
  @override
  void initState() {
    super.initState();
    getMedications();
    // saveMyMedications();
  }

  Future<void> getMedications() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String patientCode = sharedPreferences.getString('p_code')!;
    // await SharedPreferences.getInstance();
    print(patientCode);
    var url = Uri.parse(
        "http://mobistylz.com/api/patients/$patientCode/prescriptions");
    final response = await get(url);
    if (response.statusCode == 200) {
      print('response body in mediction before');
      print('medications data'.toUpperCase());
      print(response.body);
      Prescription patPrescription =
          Prescription.fromJson(jsonDecode(response.body));
      var presProvider =
          Provider.of<PrescriptionProvider>(context, listen: false);
      presProvider.addData(patPrescription);

      print(patPrescription.data!.length);
      print('response body in mediction if');
      mdata = patPrescription.data!;
      print('object');
      print(mdata.length);
      print(mdata[0].date);
      print('object');
      // setState(() {
      // hour = true;
      // hourly = jsonEncode(
      //     weather.HourlyWeatherModel.fromJson(jsonDecode(response.body)));

      // String hdata = jsonEncode(
      //     weather.HourlyWeatherModel.fromJson(jsonDecode(response.body)));
      // sharedPreferences.setString("hourly", hdata);
      // });
      // return weather.HourlyWeatherModel.fromJson(jsonDecode(response.body));
    } else {
      print('response body in else');
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    var prescribedData =
        Provider.of<PrescriptionProvider>(context, listen: true);
    Prescription prescription = prescribedData.prescription;
    print(prescribedData);
    print(prescription.data![0].medicineName);
    print('jkl');
    return Scaffold(
      backgroundColor: Colors.black,
      body: WatchShape(
        builder: (context, shape, child) {
          return Container(
              width: Get.width,
              height: Get.height,
              decoration: BoxDecoration(),
              child: ListView(
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
                    height: 20,
                  ),
                  // InkWell(
                  //   onTap: () {},
                  //   child: menuButtons(
                  //     name: '${Logs.pills[1].name} (${Logs.pills[1].unit})',
                  //     time:
                  //         '${Logs.pills[1].routine} at ${Logs.pills[1].dosetime}',
                  //   ),
                  // ),
                  InkWell(
                    onTap: () {
                      print('mdata[0].medicineName');
                    },
                    child: MedButton(
                      shape: shape,
                      name: '{prescription.data![0].medicineName.toString()} ',
                      time:
                          '${Logs.pills[2].routine} at ${Logs.pills[2].dosetime}',
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: MedButton(
                      name: '${Logs.pills[3].name} (${Logs.pills[3].unit})',
                      time:
                          '${Logs.pills[3].routine} at ${Logs.pills[3].dosetime}',
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: MedButton(
                      name: 'Diazepam (12 mg)',
                      time: 'Every other day at 17:00',
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              )
              //  Center(child: CircularProgressIndicator()),
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

  static Future<void> saveMyMedications() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("nextDoseTime", "12:55");
    sharedPreferences.setBool("isDoseTime", true);
    // print("12:55");
  }
}

class MedButton extends StatelessWidget {
  final String? name;
  final String? time;
  final String? medicineDuration;
  final int? dailydoses;
  final List<MedicineTime>? times;

  final WearShape? shape;
  const MedButton({
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
