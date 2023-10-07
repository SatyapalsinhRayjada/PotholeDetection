import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/models/cluster_model.dart';
import 'package:my_app/models/pothole_model.dart';
import 'package:my_app/pothol_service.dart';
import 'package:my_app/search_services.dart';
import 'package:searchfield/searchfield.dart';
import 'dart:async';

import 'search_page.dart';

class PotholeFixScreen extends StatefulWidget {
  const PotholeFixScreen({
    super.key,
  });

  @override
  State<PotholeFixScreen> createState() => _PotholeFixScreenState();
}

class _PotholeFixScreenState extends State<PotholeFixScreen> {
  final textController = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();
  int _mapid = 0;

  bool _isLoading = true;
  List<Pothole> potholes = [];
  static const LatLng _center = LatLng(26.80, 82.20);

  String pincode = "388345";

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _mapid = controller.mapId;
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
                onTap: () {
                  // potholes.forEach((element) {
                  //   print(element.image);
                  // });
                  // print(
                  //     "tapped ${pothole.latitude} ${pothole.longitude} ${pothole.image}");
                  // showDialog(
                  //   context: context,
                  //   builder: (context) {
                  //     return Dialog(
                  //       child: Container(
                  //         height: 200,
                  //         child: Image.network(
                  //           "${pothole.image}",
                  //           fit: BoxFit.cover,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // );
                  showConfirmFixDialog(pothole.sId, pothole.image);
                },
                position: LatLng(pothole.latitude, pothole.longitude),
                infoWindow: InfoWindow(
                  title: pothole.fixed,
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
      appBar: AppBar(
        title: const Text("Tap on pothole to fix"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            onMapCreated: _onMapCreated,
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
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.left,
        distance: 70,
        children: [
          FloatingActionButton.small(
            child: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchPage()));
            },
          ),
          FloatingActionButton.small(
            child: const Icon(Icons.search),
            onPressed: () {
              print("Sdsds");

              // return;
              showModalBottomSheet<void>(
                isScrollControlled: true,
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0)),
                ),
                builder: (BuildContext context) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Column(
                        children: [
                          Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: Container(
                                  height: 300,
                                  child: Wrap(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Autocomplete(
                                          optionsBuilder: (TextEditingValue
                                              textEditingValue) {
                                            if (textEditingValue.text == '') {
                                              return const Iterable<
                                                  String>.empty();
                                            }
                                            return SearchServices()
                                                .ahemdabadAreaToPincode
                                                .keys
                                                .where((String option) {
                                              return option
                                                  .toLowerCase()
                                                  .contains(textEditingValue
                                                      .text
                                                      .toLowerCase());
                                            });
                                          },
                                          // fieldViewBuilder: (context,
                                          //         textEditingController,
                                          //         focusNode,
                                          //         onFieldSubmitted) =>
                                          //     TextField(
                                          //   decoration: const InputDecoration(
                                          //     border: OutlineInputBorder(
                                          //         // borderRadius: BorderRadius.all(
                                          //         //   Radius.circular(50),
                                          //         // ),
                                          //         ),
                                          //     // hintText: 'Search ',
                                          //     // hintStyle: TextStyle(
                                          //     //   fontSize: 14,
                                          //     // ),
                                          //   ),
                                          //   onChanged: (value) {},
                                          //   onSubmitted: (value) {
                                          //     onFieldSubmitted();
                                          //   },
                                          // ),
                                          onSelected: (String selection) {
                                            debugPrint(
                                                'You just selected $selection');
                                            pincode = SearchServices()
                                                        .ahemdabadAreaToPincode[
                                                    selection] ??
                                                pincode;
                                            getPotholeByPincode(pincode);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.all(16.0),
                                      //   child: SearchField(
                                      //       suggestions: SearchServices()
                                      //           .getAreaToPincode("")
                                      //           .keys
                                      //           .map((e) => SearchFieldListItem(
                                      //               e,
                                      //               child: Text(e)))
                                      //           .toList(),
                                      //       controller: textController,
                                      //       searchInputDecoration:
                                      //           const InputDecoration(
                                      //         border: OutlineInputBorder(
                                      //             borderRadius:
                                      //                 BorderRadius.all(
                                      //                     Radius.circular(50))),
                                      //         hintText: 'Search ',
                                      //         hintStyle: TextStyle(
                                      //           fontSize: 14,
                                      //         ),
                                      //       )),
                                      // ),
                                    ],
                                  ))),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  showConfirmFixDialog(String id, String? imgUrl) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Fix"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imgUrl != null)
              Image.network(
                imgUrl,
                height: 200,
                width: 200,
              ),
            SizedBox(
              height: 10,
            ),
            Text("Are you sure you want to confirm fix?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              print("Confirm Fix");
              // show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text("Loading"),
                  content: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      Text("Please wait..."),
                    ],
                  ),
                ),
              );
              await PotholeServices().fixPothole(id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
