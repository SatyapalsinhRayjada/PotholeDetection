// import 'dart:ffi';

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mvpworking/pothole_services.dart';
import 'package:mvpworking/result_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';
import 'package:geolocator/geolocator.dart';

import 'main.dart';

List<CameraDescription>? cameras;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;
  CameraImage? cameraImage;
  List? recognitionsList;
  Position? _position;
  // List<String> logs = [];
  final logs = ValueNotifier([]);
  Timer debounceTimer = Timer(const Duration(seconds: 5), () {});

  int lastRecognition = 0;

  late Timer distanceTimer;

  startLocationStream() async {
    // get location permission
    await Geolocator.requestPermission();
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _position = position;
      });
    });
  }

  initCamera() async {
    await startLocationStream();

    cameras = await availableCameras();
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      // setState(() {
      //   cameraController!.startImageStream((image) => {
      //         cameraImage = image,
      //         runModel(),
      //       });
      // });
    });
  }

  var _outputs;
  runModel() async {
    if (cameraImage == null) {
      return;
    }
    try {
      var output = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 1,
        threshold: 0.4,
      );
      setState(() {
        _outputs = output;
      });
      int currentRecognition = _outputs![0]['index'];

      print("===>${currentRecognition}");
      // if (currentRecognition == 1) {
      //   PotholeServices().addPothole(position: _position!);
      // }
      if (lastRecognition == 0 && currentRecognition == 1) {
        print("Object detected");
        print("api call");
        // logs.value = logs.value + ["pothole added"];
        // api call with debounce timer
        debounceTimer.cancel();
        debounceTimer = Timer(const Duration(seconds: 5), () {
          // PotholeServices()
          //     .addPothole(position: _position!)
          //     .then((value) => logs.value = (logs.value + [value]));
        });
      }
      lastRecognition = currentRecognition;
      print(_outputs);

      setState(() {
        cameraImage;
      });
    } catch (e) {
      print("errors");
    }
  }

  Future loadModel() async {
    Tflite.close();
    await Tflite.loadModel(
      model: "assets/pothole.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<int> pincodeFromLatLng(Position _position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(_position.latitude, _position.longitude);
    Placemark place = placemarks[0];
    final pincode = int.parse(place.postalCode ?? "-1");
    return pincode;
  }

  // Future<void> addToDatabase() async {}

  @override
  void dispose() {
    super.dispose();
    debounceTimer.cancel();
    distanceTimer.cancel();

    cameraController!.stopImageStream();
    Tflite.close();
  }

  getCameraPermission() async {
    await Permission.camera.request();
  }

  @override
  void initState() {
    super.initState();

    time = Timer(const Duration(seconds: 1), () {
      seconds++;
    });
    distanceTimer = Timer(const Duration(seconds: 2), () {
      // print("distance travelled");
      measureDistanceTravelled();
    });

    loadModel();
    initCamera();
  }

  String roadName = "";

  Future<String> getRoadName() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _position!.latitude, _position!.longitude);
    Placemark place = placemarks[0];
    roadName = place.name!;
    return roadName;
  }

  measureDistanceTravelled() async {
    // get location permission
    await Geolocator.requestPermission();
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _position = position;
      });
    });

    // get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);

    // get last known position
    Position lastPosition = (await Geolocator.getLastKnownPosition())!;
    print(lastPosition);

    // get distance between two locations
    double distanceInMeters = Geolocator.distanceBetween(position.latitude,
        position.longitude, lastPosition.latitude, lastPosition.longitude);
    print(distanceInMeters);
    distanceInKm = (distanceInMeters / 1000).toStringAsFixed(2);
    setState(() {});
  }

  int seconds = 0;
  Timer? time;

  bool isDetecting = false;
  bool isLoading = false;
  String distanceInKm = "0.0";

  // List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
  //   if (recognitionsList == null) return [];

  //   double factorX = screen.width;
  //   double factorY = screen.height;

  //   Color colorPick = Colors.pink;

  //   return recognitionsList!.map((result) {
  //     return Positioned(
  //       left: result["rect"]["x"] * factorX,
  //       top: result["rect"]["y"] * factorY,
  //       width: result["rect"]["w"] * factorX,
  //       height: result["rect"]["h"] * factorY,
  //       child: Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.all(Radius.circular(10.0)),
  //           border: Border.all(color: Colors.pink, width: 2.0),
  //         ),
  //         child: Text(
  //           "${result['detectedClass']} ${(result['confidenceInClass'] * 100).toStringAsFixed(0)}%",
  //           style: TextStyle(
  //             background: Paint()..color = colorPick,
  //             color: Colors.black,
  //             fontSize: 18.0,
  //           ),
  //         ),
  //       ),
  //     );
  //   }).toList();
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> list = [];
    if (cameraController != null) {
      list.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height - 100,
          child: Container(
            height: size.height - 100,
            child: (!cameraController!.value.isInitialized)
                ? new Container()
                : AspectRatio(
                    aspectRatio: cameraController!.value.aspectRatio,
                    child: CameraPreview(cameraController!),
                  ),
          ),
        ),
      );
    }

    // list.add(
    //   Positioned(
    //     bottom: 0,
    //     child: ValueListenableBuilder<List<dynamic>>(
    //       valueListenable: logs,
    //       builder: (context, snapshot, _) => Container(
    //         // color: Colors.white,
    //         height: 160,
    //         child: ListView.builder(
    //           itemCount: snapshot.length,
    //           itemBuilder: (context, index) => Padding(
    //             padding: const EdgeInsets.all(8.0),
    //             child: Card(
    //               child: Text(
    //                 snapshot[index],
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    // return ListView.builder(
    //   itemBuilder: ((context, index) {
    //     return Padding(
    //       padding: const EdgeInsets.all(10),
    //       child: Card(
    //           child: Text(
    //         logs.value[index],
    //       )),
    //     );
    //   }),
    // );

    //contols
    list.add(
      Positioned(
        bottom: 0,
        child: Container(
          // color: Colors.white,
          height: 150,
          width: size.width,
          margin: EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(
                    isDetecting ? Icons.pause : Icons.camera_alt,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () async {
                    if (cameraController!.value.isStreamingImages) {
                      cameraController!.stopImageStream();
                      setState(() {
                        isDetecting = false;
                        _onEndTrip();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DistanceTravelledPage(
                              distance: distanceInKm,
                              time:
                                  "${(seconds / 60 / 60).toStringAsPrecision(2)} hours",
                            ),
                          ),
                        );
                      });
                    } else {
                      setState(() {
                        cameraController!.startImageStream((image) => {
                              cameraImage = image,
                              runModel(),
                              isDetecting = true,
                            });
                      });
                    }
                  },
                ),
              ),

              // ElevatedButton(
              //   onPressed: () {
              //     if (cameraController!.value.isStreamingImages) {
              //       cameraController!.stopImageStream();
              //     } else {
              //       cameraController!.startImageStream((image) {
              //         if (!isDetecting) {
              //           isDetecting = true;
              //           // detectImage(image);
              //         }
              //       });
              //     }
              //   },
              //   // icon in circle
              //   child: Icon(
              //     cameraController!.value.isStreamingImages
              //         ? Icons.pause
              //         : Icons.play_arrow,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );

    // score box with text of kms travelled
    list.add(
      Positioned(
        top: 0,
        left: 0,
        child: Column(
          children: [
            Container(
              height: 70,
              color: Colors.black,
              width: size.width,
              child: Column(
                children: [
                  Text(
                    "Kms Travelled: ${distanceInKm}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              // height: 70,
              color: Colors.red,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${_outputs?[0]["label"] ?? 'loading'}".substring(1),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      background: Paint()..color = Colors.white,
                    ),
                  ),
                  // Container(
                  //   height: 250,
                  //   child: ValueListenableBuilder<List<dynamic>>(
                  //     valueListenable: logs,
                  //     builder: (context, snapshot, _) => Container(
                  //       // color: Colors.white,
                  //       // height: 160,

                  //       child: ListView.builder(
                  //         shrinkWrap: true,
                  //         itemCount: snapshot.length,
                  //         itemBuilder: (context, index) => Padding(
                  //           padding: const EdgeInsets.all(2.0),
                  //           child: Card(
                  //             child: Text(
                  //               snapshot[index],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  // ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // list.add(Center(
    //   child: ElevatedButton(
    //       onPressed: () {
    //         logs.value = [];
    //         setState(() {});
    //       },
    //       child: const Text("clear")),
    // ));

    if (cameraImage != null) {
      // list.addAll(displayBoxesAroundRecognizedObjects(size));
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          margin: EdgeInsets.only(top: 50),
          color: Colors.black,
          child: Stack(
            children: list,
          ),
        ),
      ),
    );
  }

  _onEndTrip() async {
    Uri uri = Uri.parse("https://pothole-detection.onrender.com/addPoints");
    var response = await http.post(uri, body: {
      "distance": double.parse(distanceInKm),
      "Phone": prefs!.getString("phone"),
    });
  }
}
