class Log {
  String? medicineName;
  String? status;
  String? takenAt;

  Log({this.medicineName, this.status, this.takenAt});

  Log.fromJson(Map<String, dynamic> json) {
    medicineName = json['medicineName'];
    status = json['status'];
    takenAt = json['takenAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['medicineName'] = this.medicineName;
    data['status'] = this.status;
    data['takenAt'] = this.takenAt;
    return data;
  }
}
