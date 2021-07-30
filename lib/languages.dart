import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:watch_it/account.dart';
import 'package:watch_it/model/eprint.dart';
import 'package:watch_it/notification_time.dart';
import 'package:watch_it/pair_screen.dart';
import 'package:wear/wear.dart';

import 'provider/languageprovider.dart';

class Languages extends StatefulWidget {
  final int accesspoint;
  const Languages({Key? key, required this.accesspoint}) : super(key: key);
  static String id = 'languages';

  @override
  _LanguagesState createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  int langindex = 0;
  // var language;

  List<String> languages = [
    "English",
    "Greek",
    "German",
    "French",
  ];
  List<String> selectedlanguage = ["en", "gr", "ger", "fr"];
  List<String> countrycode = ["US", "GR", "GER", "FR"];
  String? selectedlanguag;
  bool? isLangSelected = false;
  @override
  void initState() {
    super.initState();
    // if (isLangSelected==true&&widget.accesspoint == 0) {
      
    // }
    getData();
  }

  Future<void> getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? sllang = sharedPreferences.getString("apilang");
    print(sllang);
    switch (sllang) {
      case 'en':
        print('English is already selected');
        setIndex(0);
        break;
      case 'el':
        print('Greek is already selected');
        setIndex(1);
        break;
      case 'de':
        print('German is already selected');
        setIndex(2);
        break;
      case 'fr':
        print('French is already selected');
        setIndex(3);
        break;
      default:
      // print('Default English');
      // setIndex(0);
      // break;
    }
    // if (sllang != null) {
    //   setState(() {
    //     selectedlanguag = sllang;
    //   });
    // } else {
    //   setState(() {
    //     selectedlanguag = "en";
    //   });
    // }
    // print('and then ' + selectedlanguage.toString());
    // var setlanguage = Provider.of<LanguageProvider>(context, listen: false);
    // setlanguage.setleanguage(selectedlanguage!);
  }

  @override
  Widget build(BuildContext context) {
    // language = Provider.of<LanguageProvider>(context, listen: false);
    return Provider<LanguageProvider>(
      create: (_) => LanguageProvider(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          toolbarHeight: 40,
          title: Text(
            'Languages',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        body: WatchShape(
          builder: (contaxt, shape, child) {
            return Container(
              width: Get.width,
              height: Get.height,
              decoration: BoxDecoration(),
              child: ListView(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        langindex = 0;
                        saveLanguage();
                      });
                    },
                    child: menuButtons(
                      shape: shape,
                      text: 'English',
                      icon: Icons.language,
                      color: langindex == 0 ? Colors.red : Colors.black,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        langindex = 1;
                        saveLanguage();
                      });
                    },
                    child: menuButtons(
                      shape: shape,
                      text: 'Greek',
                      icon: Icons.language,
                      color: langindex == 1 ? Colors.red : Colors.black,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        langindex = 2;
                        saveLanguage();
                      });
                    },
                    child: menuButtons(
                      shape: shape,
                      text: 'German',
                      icon: Icons.language,
                      color: langindex == 2 ? Colors.red : Colors.black,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        langindex = 3;
                        saveLanguage();
                      });
                    },
                    child: menuButtons(
                      shape: shape,
                      text: 'French',
                      icon: Icons.language,
                      color: langindex == 3 ? Colors.red : Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 20,
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
      ),
    );
  }

  void saveLanguage() async {
    var language = Provider.of<LanguageProvider>(context, listen: false);
    print('provider listener');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("language", languages[langindex]);

    print(languages[langindex]);
    setState(() {
      if (langindex == 0) {
        setState(() {
          context.setLocale(Locale("en", "US"));
          sharedPreferences.setString("apilang", "en");
          language.setleanguage("en");
        });
        // context.setLocale(Locale("en", "US"));
        // sharedPreferences.setString("apilang", "en");
        // language.setleanguage("en");
      } else if (langindex == 1) {
        context.setLocale(Locale("el", "GR"));
        // debugPrint('context.setLocale(Locale("el", "GR"));');
        sharedPreferences.setString("apilang", "el");
        // ePrint('sharedPreferences.setString("apilang", "el");');
        language.setleanguage("el");
        // debugPrint('language.setleanguage("el")');
      } else if (langindex == 2) {
        context.setLocale(Locale("de", "GE"));
        language.setleanguage("de");
        sharedPreferences.setString("apilang", "de");
      } else if (langindex == 3) {
        setState(() {
          context.setLocale(Locale("fr", "FR"));
          sharedPreferences.setString("apilang", "fr");
          language.setleanguage("fr");
        });
        // context.setLocale(Locale("fr", "FR"));
        // sharedPreferences.setString("apilang", "fr");
        // language.setleanguage("fr");
      }
    });
    sharedPreferences.setBool("languageselected", true);
    if (widget.accesspoint == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AccountScreen()));
    }
    //  else {
    //   Navigator.pop(context);
    // }
  }

  void setIndex(int i) {
    setState(() {
      langindex = i;
      isLangSelected = true;
    });
  }
}

class menuButtons extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? color;
  final WearShape? shape;

  const menuButtons({
    @required this.shape,
    @required this.text,
    @required this.icon,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: Container(
        padding: EdgeInsets.only(
          left: shape == WearShape.round ? 30 : 12,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey,
              child: Icon(
                icon,
                color: Colors.white,
                size: 15,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              text!,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
