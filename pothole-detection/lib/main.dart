import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mvpworking/camera_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'auth/phone_Screen.dart';
import 'firebase_options.dart';
import 'homepage.dart' as homepage;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }
SharedPreferences? prefs;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    home: prefs!.getString("phone") != null
        ? const homepage.MyHomePage()
        : LogIn(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List? _outputs;
  File? _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pothole or plain road'),
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null ? Container() : Image.file(_image!),
                  const SizedBox(
                    height: 20,
                  ),
                  _outputs != null
                      ? Text(
                          "${_outputs![0]["label"]}".substring(1),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            background: Paint()..color = Colors.white,
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraScreen(),
                        ),
                      );
                    },
                    child: const Text('Camera Screen'),
                  ),
                ],
              ),
            ),
      // floatingActionButton: FloatingActionButton(
      //   // onPressed: pickImage,
      //   child: Icon(Icons.image),
      // ),
    );
  }

  // pickImage() async {
  //   var image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (image == null) return null;
  //   setState(() {
  //     _loading = true;
  //     _image = File(image.path);
  //   });
  //   classifyImage(_image!);
  // }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
    print(_outputs);
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/pothole.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
