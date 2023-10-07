import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import './auth_cubit/auth_cubit.dart';

class PinCodeVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  final AuthCubit cubit;
  PinCodeVerificationScreen(
    this.phoneNumber,
    this.cubit,
  );

  @override
  _PinCodeVerificationScreenState createState() =>
      _PinCodeVerificationScreenState();
}

class _PinCodeVerificationScreenState extends State<PinCodeVerificationScreen> {
  TextEditingController textEditingController = TextEditingController();

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String? _verificationCode;
  String currentText = "";
  final formKey = GlobalKey<FormState>();
  late Timer otpTimer;
  ValueNotifier<int?> countDown = ValueNotifier(60);
  @override
  void initState() {
    widget.cubit.sendOtp().then((value) {
      otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        countDown.value = countDown.value! - 1;
        if (countDown.value == 0) {
          countDown.value = 60;
          otpTimer.cancel();
        }
      });
      errorController = StreamController<ErrorAnimationType>();
    });
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  // snackBar Widget
  // ignore: type_annotate_public_apis
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        bloc: widget.cubit,
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height / 3),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Phone Number Verification',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                  child: RichText(
                    text: TextSpan(
                        text: "Enter the code sent to number ending with ",
                        children: [
                          TextSpan(
                              text: "${widget.phoneNumber!.substring(8)}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                        style: TextStyle(color: Colors.black54, fontSize: 15)),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: formKey,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 30),
                      child: PinCodeTextField(
                        appContext: context,
                        pastedTextStyle: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        length: 6,
                        obscureText: true,
                        obscuringCharacter: '*',
                        blinkWhenObscuring: true,
                        animationType: AnimationType.fade,
                        validator: (v) {
                          if (v!.length < 3) {
                            return "";
                          } else {
                            return null;
                          }
                        },
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          borderWidth: 0,
                          selectedFillColor: Colors.white,
                        ),
                        cursorColor: Colors.black,
                        animationDuration: Duration(milliseconds: 300),
                        enableActiveFill: true,
                        errorAnimationController: errorController,
                        controller: textEditingController,
                        keyboardType: TextInputType.number,
                        boxShadows: [
                          BoxShadow(
                            offset: Offset(0, 1),
                            color: Colors.black12,
                            blurRadius: 10,
                          )
                        ],
                        onCompleted: (v) {
                          print("Completed");
                        },
                        onChanged: (value) {
                          print(value);
                          widget.cubit.updateOtp(value);
                        },
                        beforeTextPaste: (text) {
                          print("Allowing to paste ");
                          return true;
                        },
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    hasError ? "*Please fill up all the cells properly" : "",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ValueListenableBuilder(
                  valueListenable: countDown,
                  builder: (context, value, child) {
                    if (countDown.value! != 60) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Resend OTP in ",
                            style: TextStyle(fontSize: 15),
                          ),
                          TextButton(
                              onPressed: () {},
                              child: Text(
                                "${countDown.value!}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    fontSize: 16),
                              ))
                        ],
                      );
                    }
                    Container(
                      child: Text("${countDown.value!}"),
                    );

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: TextStyle(fontSize: 15),
                        ),
                        TextButton(
                            onPressed: () async {
                              otpTimer =
                                  Timer.periodic(Duration(seconds: 1), (timer) {
                                countDown.value = countDown.value! - 1;
                                if (countDown.value == 0) {
                                  countDown.value = 60;
                                  otpTimer.cancel();
                                }
                              });
                              await widget.cubit.sendOtp();

                              return snackBar("OTP resend!!");
                            },
                            child: Text(
                              "RESEND",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  fontSize: 16),
                            ))
                      ],
                    );
                  },
                ),
                SizedBox(
                  height: 14,
                ),
                state.isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 30),
                        child: ButtonTheme(
                          height: 50,
                          child: TextButton(
                            onPressed: () async {
                              try {
                                if (state.otp == null) {
                                  return snackBar("Please enter the OTP");
                                }
                                widget.cubit.verifyOtp(context,
                                    state.verificationId!, state.otp ?? "");
                              } catch (e) {}
                            },
                            child: Center(
                                child: Text(
                              "VERIFY".toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.green.shade300,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.green.shade200,
                                  offset: Offset(1, -2),
                                  blurRadius: 5),
                              BoxShadow(
                                  color: Colors.green.shade200,
                                  offset: Offset(-1, 2),
                                  blurRadius: 5)
                            ]),
                      ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
