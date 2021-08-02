import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wear/wear.dart';

class SnoozeDuration extends StatefulWidget {
  const SnoozeDuration({Key? key}) : super(key: key);
  static String id = 'snooze_time';

  @override
  _SnoozeDurationState createState() => _SnoozeDurationState();
}

class _SnoozeDurationState extends State<SnoozeDuration> {
  int? durationIndex = 1;

  WearShape? nShape;
  @override
  void initState() {
    super.initState();
    getSnoozeDuration();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 40,
        leading: Container(
          height: 1,
          width: 1,
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            tr('snooze duration'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // centerTitle: nShape == WearShape.round ? true : false,
        backgroundColor: Colors.black,
      ),
      body: WatchShape(
        builder: (context, shape, child) {
          nShape = shape;
          return Container(
            width: Get.width,
            height: Get.height,
            decoration: BoxDecoration(),
            child: ListView(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      saveSnoozeDuration(5);
                    });
                  },
                  child: SnoozeTimeButton(
                    shape: shape,
                    text: tr('five minutes'),
                    img: 'five.png',
                    color: durationIndex == 0 ? Colors.red : Colors.black,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      saveSnoozeDuration(10);
                    });
                  },
                  child: SnoozeTimeButton(
                    shape: shape,
                    text: tr('ten minutes'),
                    img: 'ten.png',
                    color: durationIndex == 1 ? Colors.red : Colors.black,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      saveSnoozeDuration(15);
                    });
                  },
                  child: SnoozeTimeButton(
                    shape: shape,
                    text: tr('fifteen minutes'),
                    img: 'fifteen.png',
                    color: durationIndex == 2 ? Colors.red : Colors.black,
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
    );
  }

  Future<void> saveSnoozeDuration(int duration) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt('snoozeDuration', duration);
    switch (duration) {
      case 5:
        setIndex(0);
        break;
      case 10:
        setIndex(1);
        break;
      case 15:
        setIndex(2);
        break;
      default:
    }
  }

  Future<void> getSnoozeDuration() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? duration = sharedPreferences.getInt('snoozeDuration');
    switch (duration) {
      case 5:
        setIndex(0);
        break;
      case 10:
        setIndex(1);
        break;
      case 15:
        setIndex(2);
        break;
      default:
    }
  }

  void setIndex(int i) {
    setState(() {
      durationIndex = i;
    });
  }
}

class SnoozeTimeButton extends StatelessWidget {
  final String? text;
  final String? img;
  final Color? color;
  final WearShape? shape;

  SnoozeTimeButton({
    @required this.text,
    @required this.img,
    @required this.shape,
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
              backgroundColor: Colors.grey.shade800,
              child: Image.asset(
                'assets/images/$img',
                scale: 4,
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
