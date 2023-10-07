import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'models/pothole_model.dart';

class PotholeServices {
  static const String _baseUrl = "https://pothole-detection.onrender.com";
  Future<List<Pothole>> getPotholeByPincode(String pincode) async {
    try {
      print("calling $_baseUrl/getpothole");
      final response = await http.post(
        Uri.parse("$_baseUrl/getpothole"),
        body: {
          "pincode": pincode,
        },
      );
      print("==> ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to load data");
      }
      final jsonList = jsonDecode(response.body);
      return jsonList.map<Pothole>((json) => Pothole.fromJson(json)).toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String> addPothole({
    required Position position,
  }) async {
    print("===> adding pothole api call with ");
    final String pincode = (await pincodeFromLatLng(position)).toString();
    final String lat = position.latitude.toString();
    final String long = position.longitude.toString();
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          "pincode": pincode,
          // "pincode": "340512",
          "latitude": lat,
          "priority": 2,

          "longitude": long,
        },
      );
      return (response.body);
    } catch (e) {
      print("===>" + e.toString());
      return "error on frontend";
    }
  }

  Future<int> pincodeFromLatLng(Position _position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(_position.latitude, _position.longitude);
    Placemark place = placemarks[0];
    final pincode = int.parse(place.postalCode ?? "-1");
    print("===> pincode $pincode ");
    return pincode;
  }
}
