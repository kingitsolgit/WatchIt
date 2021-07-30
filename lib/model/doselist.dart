// class DoseList {
//   String? id;
//   Data? data;

//   DoseList({this.id, this.data});

//   DoseList.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }

// class Data {
//   String? name;
//   String? dosetime;
//   String? routine;
//   bool? isSnoozed;
//   int? snoozedIteration;
//   int? snoozedDurationMins;

//   Data({
//     this.name,
//     this.dosetime,
//     this.routine,
//     this.isSnoozed,
//     this.snoozedIteration,
//     this.snoozedDurationMins,
//   });

//   Data.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//     dosetime = json['dosetime'];
//     routine = json['routine'];
//     isSnoozed = json['isSnoozed'];
//     snoozedIteration = json['snoozedIteration'];
//     snoozedDurationMins = json['snoozedDurationMins'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['name'] = this.name;
//     data['dosetime'] = this.dosetime;
//     data['routine'] = this.routine;
//     data['isSnoozed'] = this.isSnoozed;
//     data['snoozedIteration'] = this.snoozedIteration;
//     data['snoozedDurationMins'] = this.snoozedDurationMins;
//     return data;
//   }
// }
