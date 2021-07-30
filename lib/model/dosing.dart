class Dosing {
  String? id;
  DoseData? doseData;

  Dosing({this.id, this.doseData});

  Dosing.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doseData = json['doseData'] != null
        ? new DoseData.fromJson(json['doseData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.doseData != null) {
      data['doseData'] = this.doseData!.toJson();
    }
    return data;
  }
}

class DoseData {
  String? name;
  String? dosetime;
  String? routine;
  bool? isSnoozed;
  int? timeIndex;
  int? snoozedIteration;
  int? snoozedDurationMins;

  DoseData({
    this.name,
    this.dosetime,
    this.routine,
    this.isSnoozed,
    this.timeIndex,
    this.snoozedIteration,
    this.snoozedDurationMins,
  });

  DoseData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    dosetime = json['dosetime'];
    routine = json['routine'];
    isSnoozed = json['isSnoozed'];
    timeIndex = json['timeIndex'];
    snoozedIteration = json['snoozedIteration'];
    snoozedDurationMins = json['snoozedDurationMins'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['dosetime'] = this.dosetime;
    data['routine'] = this.routine;
    data['isSnoozed'] = this.isSnoozed;
    data['timeIndex'] = this.timeIndex;
    data['snoozedIteration'] = this.snoozedIteration;
    data['snoozedDurationMins'] = this.snoozedDurationMins;
    return data;
  }
}
