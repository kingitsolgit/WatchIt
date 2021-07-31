import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/main_menu.dart';
import 'package:wear/wear.dart';

class PairScreen extends StatefulWidget {
  final int accesspoint;
  const PairScreen({
    required this.accesspoint,
    Key? key,
  }) : super(key: key);
  static String id = 'pair';

  @override
  _PairScreenState createState() => _PairScreenState();
}

class _PairScreenState extends State<PairScreen> {
  String? pName;
  String? pEmail;
  String? pCode;
  String? doctor;
  @override
  // void initState() {
  //   super.initState();
  //   getPatientInfo();
  // }

  @override
  Widget build(BuildContext context) {
    // Timer(
    //   Duration(seconds: 10),
    //   () => Navigator.of(context).pushReplacement(
    //     new MaterialPageRoute(
    //       builder: (BuildContext context) {
    //         return new MainMenu(
    //           pname: pName,
    //           pemail: pEmail,
    //         );
    //       },
    //     ),
    //   ),
    // );
    getPatientInfo();
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 81, 17, 6),
      body: WatchShape(
        builder: (context, shape, child) {
          return ListView(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 5,
                ),
                height: (Get.height / 4) - 20,
                width: Get.width,
                color: Colors.black,
                child: Center(
                  child: Text(
                    tr('account'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 5,
                ),
                height: (Get.height / 4) + 10,
                width: Get.width,
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Padding(
                    //   padding: EdgeInsets.only(bottom: 8.0),
                    //   child: Text(
                    //     // 'Doctor: Ameer Moavia',
                    //     doctor == null ? '' : 'Doctor: $doctor!',
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       fontSize: 14,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                    Text(
                      pName == null ? '' : pName!,
                      // 'John Doe',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pEmail == null ? '' : pEmail!,
                      // 'Johndoe@email.com',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 25,
                ),
                // height: Get.height,
                width: Get.width,
                color: Color.fromARGB(255, 81, 17, 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      height: 35,
                      width: 35,
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/pair.png'),
                      // child: Icon(
                      //   Icons.link_rounded,
                      // ),
                      // child: Image.network(
                      //   'http://cdn.onlinewebfonts.com/svg/img_519173.png',
                      // ),
                    ),
                    Text(
                      tr('successfully paired') +
                          ': ' +
                          "$doctor", //'Ameer Moavia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    widget.accesspoint == 0
                        ? IconButton(
                            onPressed: () {
                              Restart();
                              // Restart.restartApp();
                              Navigator.of(context).pushReplacement(
                                new MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return new MainMenu(
                                      pname: pName,
                                      pemail: pEmail,
                                      pcode: pCode
                                    );
                                  },
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios_sharp,
                              color: Colors.white,
                            ),
                          )
                        : Container(),
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

  // bool? isPaired = false;

  Future<void> getPatientInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // if (isPaired != null && isPaired == true) {
    pName = sharedPreferences.getString('p_name')!;
    pEmail = sharedPreferences.getString('p_email')!;
    pCode = sharedPreferences.getString('p_code')!;
    doctor = sharedPreferences.getString('doctor')!;
    // }
  }
}
