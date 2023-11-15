import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherForecastWidget extends StatefulWidget {
  const WeatherForecastWidget({super.key});
  @override
  _WeatherForecastWidgetState createState() => _WeatherForecastWidgetState();
}

class _WeatherForecastWidgetState extends State<WeatherForecastWidget> {
  late Future<List<WeatherData>> weatherDataFuture;

  @override
  void initState() {
    super.initState();
    weatherDataFuture = fetchWeatherData();
  }

  Future<List<WeatherData>> fetchWeatherData() async {
    final String apiKey = '6378430bc45061aaccd4a566a86c25df';
    final String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';
    final String city = 'Naga';

    final response = await http.get(Uri.parse(
        '$baseUrl?q=$city&appid=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> forecastList = data['list'];

      // Filter data to get only one record per day (assuming daily forecasts)
      final filteredList = forecastList.where((item) {
        final DateTime dateTime = DateTime.parse(item['dt_txt']);
        // Consider only records at 12:00 PM each day
        return dateTime.hour == 12 && dateTime.minute == 0;
      }).toList();

      return filteredList.map((item) => WeatherData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WeatherData>>(
      future: weatherDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: snapshot.data!.map((weatherData) {
                return Row(
                  children: [
                    Column(
                      children: [
                        Text(weatherData.date),
                        SizedBox(height: 5),
                        Image.network(weatherData.iconUrl),
                        Text('Temperature: ${weatherData.temperature}°C'),
                        Text('Weather: ${weatherData.weatherDescription}'),
                      ],
                    ),
                    const SizedBox(width: 16),
                  ],
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}

class WeatherData {
  final String date;
  final int temperature;
  final String weatherDescription;
  final String iconUrl;

  WeatherData({
    required this.date,
    required this.temperature,
    required this.weatherDescription,
    required this.iconUrl,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final DateTime dateTime = DateTime.parse(json['dt_txt']);
    final String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    final int temperature = (json['main']['temp'] - 273.15).toInt();
    final String weatherDescription = json['weather'][0]['description'];
    final String iconCode = json['weather'][0]['icon'];
    final String iconUrl = 'https://openweathermap.org/img/w/$iconCode.png';

    return WeatherData(
      date: formattedDate,
      temperature: temperature,
      weatherDescription: weatherDescription,
      iconUrl: iconUrl,
    );
  }
}