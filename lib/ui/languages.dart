import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/ui/account.dart';
import 'package:watch_it/ui/pair_screen.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/provider/languageprovider.dart';

class Languages extends StatefulWidget {
  final int accesspoint;
  const Languages({Key? key, required this.accesspoint}) : super(key: key);
  static String id = 'languages';

  @override
  _LanguagesState createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  int langindex = 0;

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
        print('Default English');
        setIndex(0);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<LanguageProvider>(
      create: (_) => LanguageProvider(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          toolbarHeight: 40,
          title: Text(
            tr('languages'), // 'Languages',
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
                    child: LanguageButton(
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
                    child: LanguageButton(
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
                    child: LanguageButton(
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
                    child: LanguageButton(
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
        context.setLocale(Locale("en", "US"));
        sharedPreferences.setString("apilang", "en");
        language.setleanguage("en");
      } else if (langindex == 1) {
        context.setLocale(Locale("el", "GR"));
        sharedPreferences.setString("apilang", "el");
        language.setleanguage("el");
      } else if (langindex == 2) {
        context.setLocale(Locale("de", "GE"));
        language.setleanguage("de");
        sharedPreferences.setString("apilang", "de");
      } else if (langindex == 3) {
        context.setLocale(Locale("fr", "FR"));
        sharedPreferences.setString("apilang", "fr");
        language.setleanguage("fr");
      }
    });
    sharedPreferences.setBool("languageselected", true);
    // Restart.restartApp();
    if (widget.accesspoint == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => PairScreen()));
    }
  }

  void setIndex(int i) {
    setState(() {
      langindex = i;
      isLangSelected = true;
    });
  }
}

class LanguageButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? color;
  final WearShape? shape;

  const LanguageButton({
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
