import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './auth_cubit/auth_cubit.dart';
import 'otp_screen.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController phoneController = new TextEditingController();

  String countryCode = "+91";
  final cubit = AuthCubit();
  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //   // transform: GradientRotation(3.14 / 2),
      //   colors: [
      //     ThemeColors.gradient2,
      //     ThemeColors.themePrimaray,
      //     // Colors.white
      //   ],
      // )),
      child: Scaffold(
        // backgroundColor: Colors.white,
        body: Stack(
          children: [
            BlocBuilder<AuthCubit, AuthState>(
              bloc: cubit,
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 1.5,
                            color: Colors.orange.withOpacity(.7),
                            child: Center(
                              child: CircleAvatar(
                                radius: 100,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 95,
                                  backgroundImage:
                                      AssetImage("assets/logo.jpeg"),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  // width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.width /
                                          1),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 15,
                                    // color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Form(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(25)),
                                            TextFormField(
                                              onChanged: cubit.updatePhone,
                                              maxLength: 10,
                                              maxLengthEnforcement:
                                                  MaxLengthEnforcement.enforced,
                                              keyboardType: TextInputType.phone,
                                              controller: phoneController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                hintText:
                                                    "Enter your mobile number",
                                              ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.all(50)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            child: FloatingActionButton(
                              child: Icon(Icons.arrow_forward),
                              onPressed: () async {
                                if (phoneController.text.length == 10) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PinCodeVerificationScreen(
                                                countryCode +
                                                    phoneController.text,
                                                cubit,
                                              )));
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Error"),
                                          content: Text(
                                              "Please enter valid phone number"),
                                          actions: [
                                            ElevatedButton(
                                              child: Text("Ok"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                }
                              },
                              // backgroundColor: ThemeColors.themePrimaray,
                            ),
                            right: 0,
                            left: 0,
                            bottom: 0,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 6,
                    ),
                    // Stack(
                    //   children: [
                    //     Container(
                    //       margin: EdgeInsets.all(15),
                    //       child: Card(
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(20),
                    //         ),
                    //         elevation: 8,
                    //         color: Colors.white,
                    //         child: Padding(
                    //           padding: const EdgeInsets.all(15.0),
                    //           child: Form(
                    //             child: Column(
                    //               mainAxisSize: MainAxisSize.min,
                    //               children: [
                    //                 AbsorbPointer(
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.spaceBetween,
                    //                     children: [
                    //                       Text(
                    //                         "${country.phoneCode} ${country.displayNameNoCountryCode}",
                    //                         style: TextStyle(
                    //                             fontWeight: FontWeight.bold),
                    //                       ),
                    //                       IconButton(
                    //                         icon: Icon(Icons.arrow_downward),
                    //                         onPressed: () {
                    //                           showCountryPicker(
                    //                             context: context,
                    //                             showPhoneCode:
                    //                                 true, // optional. Shows phone code before the country name.
                    //                             onSelect: (Country value) {
                    //                               country = value;
                    //                               setState(() {});
                    //                               print(
                    //                                   'Select country: ${value.displayName}');
                    //                             },
                    //                           );
                    //                         },
                    //                       )
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 Padding(padding: EdgeInsets.all(25)),
                    //                 TextFormField(
                    //                   maxLength: 10,
                    //                   maxLengthEnforcement:
                    //                       MaxLengthEnforcement.enforced,
                    //                   keyboardType: TextInputType.phone,
                    //                   controller: phoneController,
                    //                   decoration: InputDecoration(
                    //                     contentPadding: EdgeInsets.all(8),
                    //                     hintText: "Enter your mobile number",
                    //                   ),
                    //                 ),
                    //                 Padding(padding: EdgeInsets.all(50)),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     Positioned(
                    //       child: FloatingActionButton(
                    //         child: Icon(Icons.arrow_forward),
                    //         onPressed: () {
                    //           Navigator.of(context).pushReplacement(
                    //             MaterialPageRoute(
                    //               builder: (context) => PinCodeVerificationScreen(
                    //                   country.phoneCode + phoneController.text),
                    //             ),
                    //           );
                    //         },
                    //         backgroundColor: ThemeColors.themePrimaray,
                    //       ),
                    //       right: 0,
                    //       left: 0,
                    //       bottom: 0,
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
