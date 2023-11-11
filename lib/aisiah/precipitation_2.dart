// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Precipitation2 extends StatelessWidget {
  final String apiKey = '6378430bc45061aaccd4a566a86c25df';
  final String cityName = 'Naga';
  double rainVolume = 0.0; // Variable to store rain volume

  Precipitation2({super.key});

  Future<void> getRainVolume() async {
    final apiUrl = 'https://api.openweathermap.org/data/2.5/weather';
    final response = await http.get(Uri.parse('$apiUrl?q=$cityName&appid=$apiKey'));

    if (response.statusCode == 200) {
      final weatherData = json.decode(response.body);
      final rainData = weatherData['rain'];
      rainVolume = rainData != null ? rainData['1h'].toDouble() : 0.0;
    } else {
      print('Failed to load weather data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: FutureBuilder(
            future: getRainVolume(),
            builder: (context, snapshot) {
              // Add UI components if needed
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
