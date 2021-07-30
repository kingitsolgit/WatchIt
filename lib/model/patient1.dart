// class NewPatient {
//   bool? status;
//   Data? data;

//   NewPatient({this.status, this.data});

//   NewPatient.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }

// class Data {
//   String? sId;
//   String? name;
//   String? mobile;
//   String? city;
//   String? address;
//   String? email;
//   int? age;
//   String? diagnosis;
//   String? gender;
//   String? maritalStatus;
//   String? job;
//   String? socialSecurity;
//   Null? date;
//   String? bloodGroup;
//   String? description;
//   String? code;
//   List<Null>? prescription;

//   Data(
//       {this.sId,
//       this.name,
//       this.mobile,
//       this.city,
//       this.address,
//       this.email,
//       this.age,
//       this.diagnosis,
//       this.gender,
//       this.maritalStatus,
//       this.job,
//       this.socialSecurity,
//       this.date,
//       this.bloodGroup,
//       this.description,
//       this.code,
//       this.prescription});

//   Data.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     name = json['name'];
//     mobile = json['mobile'];
//     city = json['city'];
//     address = json['address'];
//     email = json['email'];
//     age = json['age'];
//     diagnosis = json['diagnosis'];
//     gender = json['gender'];
//     maritalStatus = json['marital_status'];
//     job = json['job'];
//     socialSecurity = json['social_security'];
//     date = json['date'];
//     bloodGroup = json['blood_group'];
//     description = json['description'];
//     code = json['code'];
//     if (json['prescription'] != null) {
//       prescription = new List<Null>();
//       json['prescription'].forEach((v) {
//         prescription.add(new Null.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     data['name'] = this.name;
//     data['mobile'] = this.mobile;
//     data['city'] = this.city;
//     data['address'] = this.address;
//     data['email'] = this.email;
//     data['age'] = this.age;
//     data['diagnosis'] = this.diagnosis;
//     data['gender'] = this.gender;
//     data['marital_status'] = this.maritalStatus;
//     data['job'] = this.job;
//     data['social_security'] = this.socialSecurity;
//     data['date'] = this.date;
//     data['blood_group'] = this.bloodGroup;
//     data['description'] = this.description;
//     data['code'] = this.code;
//     if (this.prescription != null) {
//       data['prescription'] = this.prescription.map((v) => v!.toJson()).toList();
//     }
//     return data;
//   }
// }