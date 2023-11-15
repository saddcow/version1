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
    return Scaffold(
      body: SizedBox( 
        width: 500,
        height: 350,
      child: Card(
        color: Colors.lightBlueAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (weatherData.isNotEmpty)
              Text('City: ${weatherData['city']['name']}'),
            if (weatherData.isNotEmpty &&
                weatherData['list'] != null &&
                weatherData['list'].length >= 3) ...[
              Text('Rain Volume (1st hour): ${weatherData['list'][0]['rain']['3h'] ?? 0} mm'),
              Text('Rain Volume (2nd hour): ${weatherData['list'][1]['rain']['3h'] ?? 0} mm'),
              Text('Rain Volume (3rd hour): ${weatherData['list'][2]['rain']['3h'] ?? 0} mm'),
            ],
          ],
        ),
      ),
      ),
    );
  }
}
