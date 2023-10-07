class Pothole {
  String? fixed;
  late String sId;
  late double latitude;
  late double longitude;
  late String pincode;
  String? createdAt;

  Pothole(
      {this.fixed,
      required this.sId,
      required this.latitude,
      required this.longitude,
      required this.pincode,
      this.createdAt});

  Pothole.fromJson(Map<String, dynamic> json) {
    fixed = json['fixed'];
    sId = json['_id'];
    latitude = double.parse(json['latitude']);
    longitude = double.parse(json['longitude']);
    pincode = json['pincode'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fixed'] = this.fixed;
    data['_id'] = this.sId;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['pincode'] = this.pincode;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
