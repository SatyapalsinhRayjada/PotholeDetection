class Pothole {
  String? fixed;
  late String sId;
  late double latitude;
  late double longitude;
  late String pincode;
  String? createdAt;
  String? image;
  int? priority;
  Pothole({
    this.fixed,
    required this.sId,
    required this.latitude,
    required this.longitude,
    required this.pincode,
    this.createdAt,
    this.image,
    this.priority,
  });

  Pothole.fromJson(Map<String, dynamic> json) {
    fixed = json['fixed'];
    sId = json['_id'];
    latitude = double.parse(json['latitude']);
    longitude = double.parse(json['longitude']);
    pincode = json['pincode'];
    createdAt = json['createdAt'];
    image = json['imgUrl'];
    priority = json['priority'];
    print(priority);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fixed'] = this.fixed;
    data['_id'] = this.sId;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['pincode'] = this.pincode;
    data['createdAt'] = this.createdAt;
    data['imgUrl'] = this.image;
    data['priority'] = this.priority;
    return data;
  }
}
