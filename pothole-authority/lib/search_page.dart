import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:my_app/config.dart';
import 'package:my_app/search_services.dart';
import 'package:searchfield/searchfield.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  GooglePlace? googlePlace;
  List<AutocompletePrediction> predictions = [];
  Map<String, String> places = SearchServices().getAreaToPincode("");
  List<String> displayList = [];

  @override
  void initState() {
    displayList = places.keys.toList();
    String apiKey = Config.google_maps_api;
    googlePlace = GooglePlace(apiKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(right: 20, left: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SearchField(
                suggestions: places.keys
                    .map((e) => SearchFieldListItem(e, child: Text("${e}")))
                    .toList(),
                suggestionState: Suggestion.hidden,
                suggestionStyle: TextStyle(color: Colors.black),
                searchStyle: TextStyle(color: Colors.black),

                // suggestionItemDecoration: BoxDecoration(
                //   // color: Colors.white,
                //   // borderRadius: BorderRadius.circular(10),
                //   boxShadow: [
                //     // BoxShadow(
                //     //   color: Colors.grey.withOpacity(0.5),
                //     //   spreadRadius: 5,
                //     //   blurRadius: 7,
                //     //   offset: const Offset(0, 3), // changes position of shadow
                //     // ),
                //   ],
                // ),
              ),
              // TextField(
              //   decoration: InputDecoration(
              //     labelText: "Search",
              //     focusedBorder: OutlineInputBorder(
              //       borderSide: BorderSide(
              //         color: Colors.blue,
              //         width: 2.0,
              //       ),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderSide: BorderSide(
              //         color: Colors.black54,
              //         width: 2.0,
              //       ),
              //     ),
              //   ),
              //   onChanged: (value) {
              //     if (value.isNotEmpty) {
              //       autoCompleteSearch(value);
              //     } else {
              //       if (predictions.length > 0 && mounted) {
              //         setState(() {
              //           predictions = [];
              //         });
              //       }
              //     }
              //   },
              // ),
              // SizedBox(
              //   height: 10,
              // ),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: predictions.length,
              //     itemBuilder: (context, index) {
              //       return ListTile(
              //         leading: CircleAvatar(
              //           child: Icon(
              //             Icons.pin_drop,
              //             color: Colors.white,
              //           ),
              //         ),
              //         title: Text(predictions[index].description.toString()),
              //         onTap: () {
              //           debugPrint(predictions[index].placeId);
              //         },
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace!.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      print("result: ${result.predictions} status: ${result.status}");
      setState(() {
        predictions = result.predictions!;
      });
    }
  }
}
