import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:try1/utils/color_utils.dart';
import 'package:collection/collection.dart';

class Warning extends StatefulWidget {
  const Warning({Key? key});

  @override
  _WarningState createState() => _WarningState();
}

class _WarningState extends State<Warning> {
  final String apiKey = '6378430bc45061aaccd4a566a86c25df';
  final double latitude = 13.617;
  final double longitude = 123.183;
  Map<String, dynamic> weatherData = {};
  List<Map<String, dynamic>> floodRiskLevels = [];

  @override
  void initState() {
    super.initState();
    getWeatherData();
    getFloodRiskLevels();
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

  Future<void> getFloodRiskLevels() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Flood_Risk_Level').get();

    floodRiskLevels = snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FirestoreCheck(
          weatherData: weatherData,
          floodRiskLevels: floodRiskLevels,
        ),
      ),
    );
  }
}

class FirestoreCheck extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final List<Map<String, dynamic>> floodRiskLevels;

  const FirestoreCheck({
    Key? key,
    required this.weatherData,
    required this.floodRiskLevels,
  }) : super(key: key);

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
              double minMm = 0.0;
              double maxMm = 0.0;
              int risk = 1;

              Map<String, dynamic>? floodRiskLevel = floodRiskLevels
                  .firstWhereOrNull((floodRiskLevel) =>
                      floodRiskLevel['Hazard_level'] == document['risk_level']);

              minMm = floodRiskLevel?['Min_mm'] ?? 0.0;
              maxMm = floodRiskLevel?['Max_mm'] ?? 0.0;
              risk = floodRiskLevel?['Number'] ?? 0;

              int searchString = getSearchString(
                weatherData: weatherData,
                minMm: minMm,
                maxMm: maxMm,
                risk: risk,
              );

              String add = document['address'];
              String hazard_level = document['risk_level'];
              int number = document['number'] ;

                if (searchString != 0) {
                    // Add the address to matchingDocumentIds only if it's not already present
                    if (number <= searchString) {
                      matchingDocumentIds.add('$add - $hazard_level');
                    }
                  }
            }

              if (matchingDocumentIds.isNotEmpty) {
                return SingleChildScrollView(
                  child: SizedBox(
                  height: 270,
                  width: 500,
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
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  int getSearchString({
    required Map<String, dynamic> weatherData,
    required double minMm,
    required double maxMm,
    required int risk,
  }) {
    int searchString = 0;

    if (weatherData.containsKey('list') &&
        weatherData['list'] is List &&
        (weatherData['list'] as List).isNotEmpty) {
      final List<dynamic> list = weatherData['list'];

      if (list.length > 2) {
        double rain1 = weatherData['list'][0]['rain']?['3h'] ?? 0;
        double rain2 = weatherData['list'][1]['rain']?['3h'] ?? 0;
        double rain3 = weatherData['list'][2]['rain']?['3h'] ?? 0;

        if (rain1 >= minMm && rain1 <= maxMm &&
            rain2 >= minMm && rain2 >= maxMm &&
            rain3 >= minMm && rain3 >= maxMm) {
          searchString = risk;
        }
      }
    }

    searchString = risk;
    return searchString;
  }
}