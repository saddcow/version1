import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getWeatherData(String city, String apiKey) async {
  const apiUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final response = await http.get(Uri.parse('$apiUrl?q=$city&appid=$apiKey'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load weather data');
  }
}

class Precipitation extends StatelessWidget {
  final String apiKey = '6378430bc45061aaccd4a566a86c25df';
  final String cityName = 'Naga';

  const Precipitation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: FutureBuilder(
            future: getWeatherData(cityName, apiKey),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final weatherData = snapshot.data;
                if (weatherData != null) {
                  final rainData = weatherData['rain'];
                  final rainVolume = rainData != null ? rainData['3h'] : 0.0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Hourly Precipitation Information'),
                      Text('City: $cityName'),
                      Text('Precipitation (last 3h): $rainVolume mm'),
                    ],
                  );
                } else {
                  return const Text('No weather data available');
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
