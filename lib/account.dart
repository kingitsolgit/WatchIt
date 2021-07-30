import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/links/baserurl.dart';
import 'package:watch_it/model/patient.dart';
import 'package:watch_it/pair_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);
  static String id = 'account';

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late String selectedlanguage;

  TextEditingController passwordController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    getAccountInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WatchShape(
        builder: (contaxt, shape, child) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 25,
                  ),
                  height: Get.height / 4,
                  width: Get.width,
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      tr('account'),
                      // 'Account',
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
                    horizontal: 25,
                  ),
                  height: Get.height / 4,
                  width: Get.width,
                  color: Color.fromARGB(255, 161, 33, 22),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: TextField(
                        controller: passwordController,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
                        // obscureText: true,
                        // obscuringCharacter: '*',
                        // maxLength: 6,

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your ID', // "******",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            letterSpacing: 0,
                            fontSize: 12,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: new BorderSide(
                              width: 0.0,
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: new BorderSide(
                              width: 0.0,
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          print(value);
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                  height: Get.height / 1.5,
                  width: Get.width,
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 24,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Color.fromARGB(255, 161, 33, 22)),
                            ),
                            onPressed: () async {
                              String password =
                                  passwordController.text.toString();
                              if (password.isNotEmpty) {
                                print(password);
                                if (password == "44294") {
                                  Navigator.pushNamed(
                                    context,
                                    PairScreen.id,
                                  );
                                }
                                pairMe(password);
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return new SimpleDialog(
                                        backgroundColor:
                                            Color.fromARGB(255, 161, 33, 22),
                                        titlePadding: EdgeInsets.all(12),
                                        title: Center(
                                          child: Column(
                                            children: [
                                              new Text(
                                                'Input is Invalid',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              }
                            },
                            child: Text(tr('done')),
                          ),
                        ),
                      ),
                      Text(
                        tr('ask your caretaker'),
                        // 'Ask your caretaker to enter this code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Text(
                          'watchit.eu/pair',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 161, 33, 22),
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
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
  }

  Future<void> getAccountInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? sllang = sharedPreferences.getString("apilang");
    if (sllang != null) {
      setState(() {
        selectedlanguage = sllang;
      });
    } else {
      setState(() {
        selectedlanguage = "en";
      });
    }
  }

  Future<void> pairMe(String password) async {
    // Future<UserLoginModel> userlogin(
    //     BuildContext context, email, password) async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(
      textAlign: TextAlign.center,
      message: 'Processing',
      borderRadius: 2.0,
      backgroundColor: Colors.white,
      progressWidget: Container(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(),
      ),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
      ),
      messageTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 19.0,
        fontWeight: FontWeight.w600,
      ),
    );
    // progressDialog.show();

// 00001
    var url = Uri.parse('${BaseUrl.baseurl}/api/patients/$password');
    // "http://watchit-project.eu/api/patients/$password");
    final response = await get(url);
    if (response.statusCode == 200) {
      print('response is here');
      print(response.body);
      Patient pdata = Patient.fromJson(jsonDecode(response.body));
      print('Patient response is here');
      print(pdata.data!.toString());
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('p_name', pdata.data!.name.toString());
      sharedPreferences.setString('p_email', pdata.data!.email.toString());
      sharedPreferences.setString('p_code', pdata.data!.code.toString());
      sharedPreferences.setString('doctor', pdata.data!.doctorName.toString());
      sharedPreferences.setBool('isPaired', true);
      String s = sharedPreferences.getString('p_name')! +
          sharedPreferences.getString('p_email')! +
          sharedPreferences.getString('p_code')!;
      print(s);

      goNext();
    } else {
      print(response.body);
      await progressDialog.hide();
      showMyDialog("Invalid ID");
      // showDialog(
      //   context: context,
      //   builder: (_) => LogoutOverlay(
      //     message: "Some Error",
      //   ),
      // );
    }
  }

  void signInUser(String text) {}

  void goNext() {
    Navigator.pushReplacementNamed(
      context,
      PairScreen.id,
    );
  }

  Future<void> fetchPientData(String pairkey) async {
    var url = Uri.parse("http://mobistylz.com/api/patients/$pairkey");
    final response = await get(url);
    if (response.statusCode == 200) {
      print('response is here');
      print(response.body);

      Patient pdata = Patient.fromJson(jsonDecode(response.body));
      print('Patient response is here');
      print(pdata.data!);
      // SharedPreferences sharedPreferences =
      //     await SharedPreferences.getInstance();

      // sharedPreferences.setStringList('key', pdata);
      goNext();
    } else {}
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
        });
  }
}
