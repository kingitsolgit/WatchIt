import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiData {
  static String? pcode;

  static Future<void> getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    pcode = sharedPreferences.getString('p_code')!;

    var url =
        Uri.parse("http://mobistylz.com/api/patients/$pcode/prescriptions");
    final response = await get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> newMedication = jsonDecode(response.body);
      newMedication.forEach((key, value) {
        print('$key and $value');
      });
      var newMedicationAsString = json.encode(newMedication);
      print('s is $newMedicationAsString');
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('medicString', newMedicationAsString);

      // Map<String, dynamic> values = new Map<String, dynamic>();
      // String? medicationAsString = sharedPreferences.getString("medicString");
      // values = jsonDecode(medicationAsString!);
    }
  }
}
