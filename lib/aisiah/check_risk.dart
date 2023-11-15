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
  final double latitude = 13.6217753; 
  final double longitude = 123.1948238;
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
  String searchString = '';
  double hour1 = 0.00;
  double hour2 = 0.00;
  double hour3 = 0.00;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('markers').snapshots(),
          builder: (context, snapshot) {

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

              if (weatherData['list'][0]['rain']['3h'] >= 6.5 && weatherData['list'][0]['rain']['3h'] <= 15.0){
              if (weatherData['list'][1]['rain']['3h'] >= 6.5 && weatherData['list'][1]['rain']['3h'] <= 15.0){
                if (weatherData['list'][2]['rain']['3h'] >= 6.5 && weatherData['list'][2]['rain']['3h'] <= 15.0){
                  searchString = 'Low';
                } else {searchString = '';}
              } else {
                searchString = '';
              }
            }
            else if (weatherData['list'][0]['rain']['3h'] >= 15.0 && weatherData['list'][0]['rain']['3h'] <= 30.0){
              if (weatherData['list'][1]['rain']['3h'] >= 15.0 && weatherData['list'][1]['rain']['3h'] <= 30.0){
                if (weatherData['list'][2]['rain']['3h'] >= 15.0 && weatherData['list'][2]['rain']['3h'] <= 30.0){
                  searchString = 'Medium';
                } else {searchString = '';}
              } else {
                searchString = '';
              }
            }
            else if (weatherData['list'][0]['rain']['3h'] > 30.0){
              if (weatherData['list'][1]['rain']['3h'] > 30.0 ){
                if (weatherData['list'][2]['rain']['3h'] > 30){
                  searchString = 'High';
                } else {searchString = '';}
              } else {
                searchString = '';
              }
            }
            else {
              searchString = '';
            }

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
                          title: const Divider(),
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

