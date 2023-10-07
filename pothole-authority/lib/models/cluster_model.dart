import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PotholeCluster with ClusterItem {
  final String name;
  final bool isClosed;
  final LatLng latLng;
  final int priority;

  PotholeCluster(
      {required this.name,
      required this.latLng,
      this.isClosed = false,
      this.priority = 3});

  @override
  String toString() {
    return 'Place $name (closed : $isClosed)';
  }

  @override
  LatLng get location => latLng;
}
