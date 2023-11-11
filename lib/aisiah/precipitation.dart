// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Precipitation extends StatefulWidget {
  const Precipitation({super.key});

  @override
  _PrecipitationState createState() => _PrecipitationState();
}

class _PrecipitationState extends State<Precipitation> {
  final String apiKey = '6378430bc45061aaccd4a566a86c25df';
  final double latitude = 13.5; 
  final double longitude = 123.2; 
  double rainVolume = 10.00;

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
        body: SizedBox(
          width: 500,
          height: 350,
          child: Card(
            color: Colors.lightBlueAccent,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Rain Volume for the Next 3 Hours: $rainVolume mm'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}