class Pill {
  String? name;
  String? unit;
  String? dosetime;
  String? routine;
  bool? isSnoozed;
  int? snoozedIteration;
  int? snoozedDuration;

  Pill({
    this.name,
    this.unit,
    this.dosetime,
    this.routine,
    this.isSnoozed,
    this.snoozedIteration,
    this.snoozedDuration,
  });

  Pill.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    unit = json['unit'];
    dosetime = json['dosetime'];
    routine = json['routine'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['unit'] = this.unit;
    data['dosetime'] = this.dosetime;
    data['routine'] = this.routine;
    return data;
  }
}
