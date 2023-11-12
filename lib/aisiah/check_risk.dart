// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class Warning extends StatefulWidget {
  const Warning({super.key});

  @override
  _WarningState createState() => _WarningState();
}

class _WarningState extends State<Warning> {
  final String apiKey = '6378430bc45061aaccd4a566a86c25df';
  final String cityName = 'Naga';
  double rainVolume = 0.00;
  final double latitude = 13.6217753; 
  final double longitude = 123.1948238; 

  @override
  void initState() {
    super.initState();
    getRainVolume();
  }

  Future<void> getRainVolume() async {
    final apiUrl = 'https://api.openweathermap.org/data/2.5/forecast';
    final response = await http.get(Uri.parse('$apiUrl?lat=$latitude&lon=$longitude&appid=$apiKey'));

    if (response.statusCode == 200) {
      final forecastData = json.decode(response.body);
      final List<dynamic> hourlyForecast = forecastData['list'];

      // Find the rain volume for the next 3 hours
      for (int i = 0; i < 3; i++) {
        final rainData = hourlyForecast[i]['rain'];
        if (rainData != null && rainData['3h'] != null) {
          setState(() {
            rainVolume = rainData['3h'].toDouble();
          });
          return;
        }
      }

      // If no rain data is found in the next 3 hours
      setState(() {
        rainVolume = 0.00;
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
        body: FirestoreCheck(rainVolume: rainVolume,),
      ),
    );
  }
}

class FirestoreCheck extends StatelessWidget {
  FirestoreCheck({super.key, required this.rainVolume}); 
  
  String searchString = '';
  final double rainVolume;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('markers').snapshots(),
          builder: (context, snapshot) {
            if(rainVolume > 30.00 ){
              searchString = 'High';
            } else if (rainVolume >= 15.00 && rainVolume <= 30.00){
              searchString = 'Medium';
            } else if (rainVolume >= 6.5 && rainVolume <= 15.00  ){
              searchString = 'Low';
            } else {
              searchString = 'High';
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
              List<String> matchingDocumentIds = [];

              for (QueryDocumentSnapshot document in querySnapshot.docs) {
                String fieldValue = document['risk_level'];
                String add = document['address'];

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
                  color: Colors.lightBlueAccent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (String docInfo in matchingDocumentIds)
                        ListTile(
                          subtitle: Text(docInfo),
                        ),
                    ],
                    ),
                  ),
                );
              } else {
                return const SizedBox(
                   height: 270,
                   width: 500,
                  child: Card(
                    color: Colors.lightBlueAccent,
                    child: Center(
                      child: Text('All Goods! Nothing to worry!')),
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

