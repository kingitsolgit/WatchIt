import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/ui/main_menu.dart';

class AccountScreen extends StatefulWidget {
  final int accesspoint;
  const AccountScreen({
    required this.accesspoint,
    Key? key,
  }) : super(key: key);
  static String id = 'account';

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? pName;
  String? pEmail;
  String? pCode;
  String? doctor;
  bool? isLoaded = false;
  @override
  void initState() {
    super.initState();
    getPatientInfo().whenComplete(() {
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // getPatientInfo();
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 81, 17, 6),
      body: WatchShape(
        builder: (context, shape, child) {
          return ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
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
                padding: EdgeInsets.symmetric(horizontal: 5),
                height: (Get.height / 4) + 10,
                width: Get.width,
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                padding: EdgeInsets.symmetric(horizontal: 25),
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
                              print('pressed..!');
                              if (isLoaded!) {
                                print('Loaded, you can proceed..!');
                                Restart.restartApp();
                              }
                              // Navigator.of(context).pushReplacement(
                              //   new MaterialPageRoute(
                              //     builder: (BuildContext context) {
                              //       return new MainMenu(
                              //           pname: pName,
                              //           pemail: pEmail,
                              //           pcode: pCode);
                              //     },
                              //   ),
                              // );
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
