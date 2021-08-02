class SnoozedMedicine {
  String? id;
  String? name;
  String? dosetime;
  int? routine;
  bool? isSnoozed;
  int? timeIndex;
  int? snoozedIteration;
  int? snoozedDurationMins;

  SnoozedMedicine({
    this.id,
    this.name,
    this.dosetime,
    this.routine,
    this.isSnoozed,
    this.timeIndex,
    this.snoozedIteration,
    this.snoozedDurationMins,
  });

  SnoozedMedicine.fromJson(Map<String, dynamic> json) {
    id = json['id'];
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
    data['id'] = this.id;
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
