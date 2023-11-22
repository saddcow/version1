// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:try1/utils/color_utils.dart';

class Warning extends StatefulWidget {
  const Warning({super.key});

  @override
  _WarningState createState() => _WarningState();
}

class _WarningState extends State<Warning> {
  final String apiKey = '6378430bc45061aaccd4a566a86c25df';
  final String cityName = 'Naga';
  double rainVolume = 0.00;
  final double latitude = 13.617; 
  final double longitude = 123.183; 
  Map<String, dynamic> weatherData = {};

  @override
  void initState() {
    super.initState();
    getWeatherData();
  }

  Future<void> getWeatherData() async {
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        weatherData = data;
      });
    } else {
      print('Failed to load weather data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FirestoreCheck(weatherData: weatherData),
      ),
    );
  }
}

class FirestoreCheck extends StatelessWidget {
    final Map<String, dynamic> weatherData;
    
  FirestoreCheck({Key? key, required this.weatherData}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  
      home: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('markers').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
              List<String> matchingDocumentIds = [];

              for (QueryDocumentSnapshot document in querySnapshot.docs) {
                String fieldValue = document['risk_level'];
                String add = document['address'];
                String searchString = getSearchString(weatherData: weatherData);

                if (searchString == 'High' ) {
                  matchingDocumentIds.add(add); 
                } else if (searchString == 'Medium' && fieldValue == 'Medium') {
                  matchingDocumentIds.add(add);
                } else if (searchString == 'Low' && fieldValue == 'High') {
                  matchingDocumentIds.add(add);
                }
              }

              if (matchingDocumentIds.isNotEmpty) {
                return SingleChildScrollView(
                  child: Card(
                  color: hexStringToColor("#86BBD8"),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (String docInfo in matchingDocumentIds)
                        ListTile(
                          subtitle: Text(docInfo),
                          title: const Divider(),
                        ),
                    ],
                    ),
                  ),
                );
              } else {
                return SizedBox(
                   height: 270,
                   width: 500,
                  child: Card(
                    color: hexStringToColor("#86BBD8"),
                    child: const Center(
                      child: Text('All Good! Nothing to worry!')),
                  )
                );
              }
            }
          },
        ),
      ),
    );
  }
}

String getSearchString({required Map<String, dynamic> weatherData}) {
  String searchString = '';

  if (weatherData.containsKey('list') && weatherData['list'] is List && (weatherData['list'] as List).isNotEmpty) {
    final List<dynamic> list = weatherData['list'];

    if (list.length > 2) {
      double rain1 = list[0]['rain']?['3h'] ?? 0.0;
      double rain2 = list[1]['rain']?['3h'] ?? 0.0;
      double rain3 = list[2]['rain']?['3h'] ?? 0.0;

      if (rain1 >= 6.5 && rain1 <= 15.0 && rain2 >= 6.5 && rain2 <= 15.0 && rain3 >= 6.5 && rain3 <= 15.0) {
        searchString = 'Low';
      } else if (rain1 >= 15.0 && rain1 <= 30.0 && rain2 >= 15.0 && rain2 <= 30.0 && rain3 >= 15.0 && rain3 <= 30.0) {
        searchString = 'Medium';
      } else if (rain1 > 30.0 && rain2 > 30.0 && rain3 > 30.0) {
        searchString = 'High';
      }
    }
  }

  return searchString;
}


