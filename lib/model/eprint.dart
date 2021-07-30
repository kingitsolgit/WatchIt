import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

ePrint(Object object) {
  if (!kReleaseMode) print('E-Print: $object');
}

DateTime now = DateTime.now();
String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
