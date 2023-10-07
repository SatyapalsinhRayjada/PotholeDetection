import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvpworking/pothole_services.dart';
import 'package:mvpworking/profile_page.dart';
import 'dart:async';

import 'camera_screen.dart';
import 'models/cluster_model.dart';
import 'models/pothole_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final textController = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();
  int _mapid = 0;

  bool _isLoading = true;
  List<Pothole> potholes = [];
  late ClusterManager _manager;
  static const LatLng _center = LatLng(26.80, 82.20);

  String pincode = "388345";

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _mapid = controller.mapId;
    _manager.setMapId(_mapid);
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<PotholeCluster>(
      potholes.map(
        (e) => PotholeCluster(
          name: "",
          latLng: LatLng(e.latitude, e.longitude),
        ),
      ),
      (Set<Marker> newMarkers) {
        markers = newMarkers;
        setState(() {});
      },
      markerBuilder: _markerBuilder,
    );
  }

  void getPotholeByPincode(String pincode) async {
    setState(() {
      _isLoading = true;
    });

    final potholeService = PotholeServices();
    try {
      potholes = await potholeService.getPotholeByPincode(pincode);
    } catch (e) {
      print(e);
      return;
    }
    print(potholes);
    // set markers
    setState(() {
      markers = potholes
          .map((pothole) => Marker(
                markerId: MarkerId(pothole.sId),
                position: LatLng(pothole.latitude, pothole.longitude),
                infoWindow: InfoWindow(
                  title: "${pothole.latitude}, ${pothole.longitude}",
                  snippet: pothole.pincode,
                ),
              ))
          .toSet();
      _isLoading = false;
    });

    // _manager.setItems(potholes
    //     .map((e) =>
    //         PotholeCluster(name: "", latLng: LatLng(e.latitude, e.longitude)))
    //     .toList());
    _manager.setItems(potholes
        .map((e) =>
            PotholeCluster(name: "", latLng: LatLng(e.latitude, e.longitude)))
        .toList());
    //set camera position
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(potholes[0].latitude, potholes[0].longitude),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  void initState() {
    _manager = _initClusterManager();
    getPotholeByPincode(pincode);
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              onCameraMove: _manager.onCameraMove,
              onCameraIdle: _manager.updateMap,
              onMapCreated: _onMapCreated,
              // mapToolbarEnabled: false,
              markers: Set.from(markers),
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              initialCameraPosition: const CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.blueGrey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Loading...",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.up,
        distance: 70,
        children: [
          FloatingActionButton.small(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
              child: const Icon(Icons.person)),
          FloatingActionButton.small(
            child: const Icon(Icons.camera_alt),
            onPressed: () {
              // return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Marker> Function(Cluster<PotholeCluster>) get _markerBuilder =>
      (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            print('---- $cluster');
            cluster.items.forEach((p) => print(p));
          },
          icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };
  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.orange;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }
}
