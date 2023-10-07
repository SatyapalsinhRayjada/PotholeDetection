import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.indigo[400],
        body: SafeArea(
            child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 200),
              height: 200,
              width: double.infinity,
              child: Card(
                  elevation: 10,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("+1 (123) 456-7890",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text("⭐", style: TextStyle(fontSize: 20)),
                              Text("Points Earned",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Text("100",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                          // Column(
                          //   children: [
                          //     Text("Travelled",
                          //         style: TextStyle(
                          //             color: Colors.black,
                          //             fontSize: 20,
                          //             fontWeight: FontWeight.bold)),
                          //     Text("100",
                          //         style: TextStyle(
                          //             color: Colors.black,
                          //             fontSize: 20,
                          //             fontWeight: FontWeight.bold))
                          //   ],
                          // ),
                          // Column(
                          //   children: [
                          //     Text("Posts",
                          //         style: TextStyle(
                          //             color: Colors.black,
                          //             fontSize: 20,
                          //             fontWeight: FontWeight.bold)),
                          //     Text("100",
                          //         style: TextStyle(
                          //             color: Colors.black,
                          //             fontSize: 20,
                          //             fontWeight: FontWeight.bold))
                          //   ],
                          // ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  )),
            ),
            Positioned(
              top: 150,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Image.network(
                      "https://im.whatshot.in/img/2019/Jul/shutterstock-305912750-1564058322.jpg",
                      fit: BoxFit.cover),
                ),
              ),
            )
          ],
        )));
  }
}
