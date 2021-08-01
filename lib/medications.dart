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
  @override
  Widget build(BuildContext context) {
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
                    padding: EdgeInsets.all(12),
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
                  height: 5,
                ),
                MedButton(
                  shape: shape,
                  name: 'Panadol',
                  time: '2021-07-31 12:10',
                ),
                MedButton(
                  shape: shape,
                  name: 'Brufen (12 mg)',
                  time: 'Every other day at 17:00',
                ),
                MedButton(
                  shape: shape,
                  name: 'Diazepam (12 mg)',
                  time: 'Every other day at 17:00',
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MedButton extends StatelessWidget {
  final String? name;
  final String? time;

  final WearShape? shape;
  const MedButton({
    this.name,
    this.time,
    Key? key,
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
                    itemCount: 3, //times!.length,
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
                                '${201 + index}',
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
                '25-10-2020 to 23-23-32',
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
