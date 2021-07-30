class Prescription {
  bool? status;
  List<Data>? data;

  Prescription({this.status, this.data});

  Prescription.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? medicineName;
  int? dailyDosePill;
  String? doseTimeDuration;
  String? date;
  String? patientCode;
  List<MedicineTime>? medicineTime;

  Data({
    this.sId,
    this.medicineName,
    this.dailyDosePill,
    this.doseTimeDuration,
    this.date,
    this.patientCode,
    this.medicineTime,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    medicineName = json['medicine_name'];
    dailyDosePill = json['daily_dose_pill'];
    doseTimeDuration = json['dose_time_duration'];
    date = json['date'];
    patientCode = json['patient_code'];
    if (json['medicine_time'] != null) {
      medicineTime = <MedicineTime>[];
      json['medicine_time'].forEach((v) {
        medicineTime!.add(new MedicineTime.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['medicine_name'] = this.medicineName;
    data['daily_dose_pill'] = this.dailyDosePill;
    data['dose_time_duration'] = this.doseTimeDuration;
    data['date'] = this.date;
    data['patient_code'] = this.patientCode;
    if (this.medicineTime != null) {
      data['medicine_time'] =
          this.medicineTime!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MedicineTime {
  int? id;
  String? date;
  String? time;
  String? status;

  MedicineTime({this.id, this.date, this.time, this.status});

  MedicineTime.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    time = json['time'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['time'] = this.time;
    data['status'] = this.status;
    return data;
  }
}


/*

class Prescription {
  bool? status;
  List<Data>? data;

  Prescription({this.status, this.data});

  Prescription.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? medicineName;
  int? dailyDosePill;
  String? doseTimeDuration;
  String? date;
  String? patientCode;
  List<String>? medicineTime;

  Data({
    this.sId,
    this.medicineName,
    this.dailyDosePill,
    this.doseTimeDuration,
    this.date,
    this.patientCode,
    this.medicineTime,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    medicineName = json['medicine_name'];
    dailyDosePill = json['daily_dose_pill'];
    doseTimeDuration = json['dose_time_duration'];
    date = json['date'];
    patientCode = json['patient_code'];
    medicineTime = json['medicine_time'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['medicine_name'] = this.medicineName;
    data['daily_dose_pill'] = this.dailyDosePill;
    data['dose_time_duration'] = this.doseTimeDuration;
    data['date'] = this.date;
    data['patient_code'] = this.patientCode;
    data['medicine_time'] = this.medicineTime;
    return data;
  }

  static void getData() {}
}





// class Prescription {
//   bool? status;
//   List<Data>? data;

//   // List<Data>? myData;

//   Prescription({this.status, this.data});

//   Prescription.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     // if (json['data'] != null) {
//     data = List<Data>.from(json["data"].map((x) => Data.fromJson(x)));
//     //   json['data'].forEach((v) {
//     //     data!.add(new Data.fromJson(v));
//     //   });
//     // }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Data {
//   String? sId;
//   String? medicineName;
//   int? dailyDosePill;
//   String? doseTimeDuration;
//   String? date;
//   String? patientCode;
//   List<MedicineTime>? medicineTime;

//   // List<MedicineTime>? myMedicineTime;

//   Data({
//     this.sId,
//     this.medicineName,
//     this.dailyDosePill,
//     this.doseTimeDuration,
//     this.date,
//     this.patientCode,
//     this.medicineTime,
//   });

//   Data.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     medicineName = json['medicine_name'];
//     dailyDosePill = json['daily_dose_pill'];
//     doseTimeDuration = json['dose_time_duration'];
//     date = json['date'];
//     patientCode = json['patient_code'];
//     medicineTime = List<MedicineTime>.from(
//         json["medicine_time"].map((x) => MedicineTime.fromJson(x)));
//     // if (json['medicine_time'] != null) {
//     //   medicineTime = myMedicineTime;
//     //   json['medicine_time'].forEach((v) {
//     //     medicineTime!.add(new MedicineTime.fromJson(v));
//     //   });
//     // }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     data['medicine_name'] = this.medicineName;
//     data['daily_dose_pill'] = this.dailyDosePill;
//     data['dose_time_duration'] = this.doseTimeDuration;
//     data['date'] = this.date;
//     data['patient_code'] = this.patientCode;
//     if (this.medicineTime != null) {
//       data['medicine_time'] =
//           this.medicineTime!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class MedicineTime {
//   int? id;
//   String? time;
//   String? status;

//   MedicineTime({this.id, this.time, this.status});

//   MedicineTime.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     time = json['time'];
//     status = json['status'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['time'] = this.time;
//     data['status'] = this.status;
//     return data;
//   }
// }

// /*


//  00001
// I/flutter ( 3853): response body in mediction before
// I/flutter ( 3853): MEDICATIONS DATA
// I/flutter ( 3853): {"status":true,"data":[{"_id":"60e42db07cc3637ed3a765ad",
// "medicine_name":"Brufen Syrup","daily_dose_pill":3,"dose_time_duration":"3 days","date":"06-07-2021","patient_code":"00001","medicine_time":[{"id":1,"time":"13:50","status":"Pending"},{"id":2,"time":"19:50","status":"Pending"}]}]}
// E/flutter ( 3853): [ERROR:flutter/lib/ui/ui_dart_state.cc(199)] Unhandled Exception: NoSuchMethodError: The method 'map' was called on null.

// response body in mediction before
// I/flutter ( 3853): MEDICATIONS DATA
// I/flutter ( 3853): {"status":true,"data":[{"_id":"60e42db07cc3637ed3a765ad","medicine_name":"Brufen Syrup","daily_dose_pill":3,"dose_time_duration":"3 days","date":"06-07-2021","patient_code":"00001","medicine_time":[{"id":1,"time":"13:50","status":"Pending"},{"id":2,"time":"19:50","status":"Pending"}]}]}
// E/flutter ( 3853): [ERROR:flutter/lib/ui/ui_dart_state.cc(199)] Unhandled Exception: NoSuchMethodError: The method 'map' was called on null.
// E/flutter ( 3853): Receiver: null
// E/flutter ( 3853): Tried calling: map(Closure: (dynamic) => Data)
// E/flutter ( 3853): #0      Object.noSuchMethod (dart:core-patch/object_patch.dart:54:5)
// E/flutter ( 3853): #1      new Prescription.fromJson (package:watch_it/model/prescription.dart:12:41)
// E/flutter ( 3853): #2      _MedicationsState.getMedications (package:watch_it/medications.dart:46:24)
// E/flutter ( 3853): <asynchronous suspension>
// E/flutter ( 3853):
// I/flutter ( 3853): in sound callback true




// */

*/
