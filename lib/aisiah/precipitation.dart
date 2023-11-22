import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:try1/utils/color_utils.dart';

class Precipitation extends StatefulWidget {
  const Precipitation({Key? key}) : super(key: key);

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

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) { 
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          weatherData = data;
        });
      } else {
        print('Failed to load weather data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Card(
          color: hexStringToColor("#86BBD8"),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (weatherData.isNotEmpty && weatherData['city'] != null)
                  Text('City: ${weatherData['city']['name']}'),
                const SizedBox(height: 20),
                if (weatherData.isNotEmpty &&
                    weatherData['list'] != null &&
                    weatherData['list'].length >= 3) ...[
                  Text('Rain Volume [time: ${DateTime.now().hour}:${DateTime.now().minute}]: ${weatherData['list'][0]['rain']?['3h'] ?? 0} mm'),
                  const SizedBox(height: 10),
                  Text('Rain Volume [time: ${DateTime.now().hour + 1}:${DateTime.now().minute}]: ${weatherData['list'][1]['rain']?['3h'] ?? 0} mm'),
                  const SizedBox(height: 10),
                  Text('Rain Volume [time: ${DateTime.now().hour + 2}:${DateTime.now().minute}]: ${weatherData['list'][2]['rain']?['3h'] ?? 0} mm'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
