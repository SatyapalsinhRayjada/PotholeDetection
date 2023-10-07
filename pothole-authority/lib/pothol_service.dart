import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_app/config.dart';
import 'package:my_app/models/pothole_model.dart';

class PotholeServices {
  Future<List<Pothole>> getPotholeByPincode(String pincode) async {
    try {
      print("calling ${Config.host}/getpothole");
      final response = await http.post(
        Uri.parse("${Config.host}/getpothole"),
        body: {
          "pincode": pincode,
        },
      );
      // print("==> ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to load data");
      }
      final jsonList = jsonDecode(response.body);
      final pothole =
          (jsonList as List).where((element) => element["imgUrl"] != null);

      return jsonList.map<Pothole>((json) => Pothole.fromJson(json)).toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future fixPothole(String id) async {
    try {
      print("calling ${Config.host}/fixpothole");
      final response = await http.post(
        Uri.parse("${Config.host}/potholefilled"),
        body: {
          "_id": id,
        },
      );
      print("==> ${response.body} id: $id");

      if (response.statusCode != 200) {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
