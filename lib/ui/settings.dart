import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/ui/languages.dart';
import 'package:wear/wear.dart';

import 'package:watch_it/ui/account.dart';
import 'package:watch_it/ui/notification_time.dart';
import 'package:watch_it/ui/pair_screen.dart';
import 'package:watch_it/ui/snooze_time.dart';


class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);
  static String id = 'settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 40,
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: Icon(
        //     Icons.arrow_back_ios,
        //     color: Colors.white,
        //     size: 18,
        //   ),
        // ),
        title: Text(
          'settings',
          // tr('settings'),
          // "${('settings'.tr().toString())}",
          // 'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ).tr(),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: WatchShape(
        builder: (context, shape, child) {
          return Container(
            width: Get.width,
            height: Get.height,
            decoration: BoxDecoration(),
            child: ListView(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (context) => PairScreen(
                          accesspoint: 1,
                        ),
                      ),
                    );
                  },
                  child: SettingsButton(
                    shape: shape,
                    text: tr('account'),
                    icon: Icons.person,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      NotificationTime.id,
                    );
                  },
                  child: SettingsButton(
                    shape: shape,
                    text: tr('notifications'),
                    icon: Icons.notifications,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      SnoozeTime.id,
                    );
                  },
                  child: SettingsButton(
                    shape: shape,
                    text: tr('snooze time'),
                    icon: Icons.snooze,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (context) => Languages(accesspoint: 1),
                      ),
                    );
                  },
                  child: SettingsButton(
                    shape: shape,
                    text: tr('languages'),
                    icon: Icons.language,
                  ),
                ),
                InkWell(
                  onTap: () {
                    logOut(context);
                  },
                  child: SettingsButton(
                    text: tr('log out'),
                    icon: Icons.exit_to_app,
                    shape: shape,
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
    );
  }

  Future<void> logOut(BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    sharedPreferences.setBool('isPaired', false);

    Get.offAll(AccountScreen());

  }
}

class SettingsButton extends StatelessWidget {
  final String? text;
  final IconData? icon;

  final WearShape? shape;

  const SettingsButton({
    @required this.text,
    @required this.icon,
    @required this.shape,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Container(
        padding: EdgeInsets.only(
          left: shape == WearShape.round ? 30 : 8,
          top: 8,
          bottom: 8,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey,
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
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
