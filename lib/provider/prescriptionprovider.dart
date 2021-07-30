import 'package:flutter/cupertino.dart';
import 'package:watch_it/model/prescription.dart';

class PrescriptionProvider extends ChangeNotifier {
  Prescription prescription = Prescription();
  Prescription get prescriptiondata {
    return prescription;
  }

  void addData(Prescription prescription) {
    prescription = prescription;
    notifyListeners();
  }
}
