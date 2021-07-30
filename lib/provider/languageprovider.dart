import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  String? index;
  int? newindex;

  String? get lang {
    return index;
  }

  int? get lngindex {
    return newindex;
  }

  void setleanguage(String lan) {
    this.index = lan;
    notifyListeners();
  }

  void setindex(int index) {
    this.newindex = index;
    notifyListeners();
  }
}
