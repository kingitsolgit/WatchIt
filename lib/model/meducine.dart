class Meducine {
  String? medicineId;
  String? medicineName;
  int? dailyDosePill;
  String? medicineTime;
  int? medicinetimeindex;
  String? dateRange;
  bool? isSnoozed;
  int? snoozedIteration;

  Meducine({
    this.medicineId,
    this.medicineName,
    this.dailyDosePill,
    this.medicineTime,
    this.medicinetimeindex,
    this.dateRange,
    this.snoozedIteration,
    this.isSnoozed,
  });

  Meducine.fromJson(Map<String, dynamic> json) {
    medicineId = json['medicineId'];
    medicineName = json['medicineName'];
    dailyDosePill = json['daily_dose_pill'];
    medicineTime = json['medicineTime'];
    medicinetimeindex = json['medicinetimeindex'];
    dateRange = json['dateRange'];
    isSnoozed = json['isSnoozed'];
    snoozedIteration = json['snoozedIteration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['medicineId'] = this.medicineId;
    data['medicineName'] = this.medicineName;
    data['daily_dose_pill'] = this.dailyDosePill;
    data['medicineTime'] = this.medicineTime;
    data['medicinetimeindex'] = this.medicinetimeindex;
    data['dateRange'] = this.dateRange;
    data['isSnoozed'] = this.isSnoozed;
    data['snoozedIteration'] = this.snoozedIteration;
    return data;
  }
}
