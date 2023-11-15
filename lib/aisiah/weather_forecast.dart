import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherForecast extends StatefulWidget {
  const WeatherForecast({super.key});

  @override
  _WeatherForecastState createState() => _WeatherForecastState();
}

class _WeatherForecastState extends State<WeatherForecast> {
  final String apiKey = '6378430bc45061aaccd4a566a86c25df';
  final String city = 'Naga,PH'; 


  Future<List<Map<String, dynamic>>> fetchHourlyForecast() async {
    final response = await http.get(
      Uri.parse(
        'http://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> hourlyList = data['list'];
      return hourlyList.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load hourly forecast');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hourly Forecast'),
      ),
      body: FutureBuilder(
        future: fetchHourlyForecast(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> hourlyForecast =
                snapshot.data as List<Map<String, dynamic>>;
            return buildHourlyForecastList(hourlyForecast);
          }
        },
      ),
    );
  }

  Widget buildHourlyForecastList(List<Map<String, dynamic>> hourlyForecast) {
    return ListView.builder(
      itemCount: hourlyForecast.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> hourData = hourlyForecast[index];
        String time = hourData['dt_txt'];
        double precipitation = hourData['rain'] != null
            ? (hourData['rain']['3h'] as double? ?? 0.0)
            : 0.0;

        return ListTile(
          title: Text('Time: $time'),
          subtitle: Text('Precipitation: $precipitation mm'),
        );
      },
    );
  }
}
