import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CurrentWeatherApi {
  static Future<Map<String, dynamic>> fetchCurrentWeather(
    String apiKey, String city) async {
  try {
    final String currentWeatherUrl =
    'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey';
    final response = await http.get(Uri.parse(currentWeatherUrl));

    if (response.statusCode == 200) {
      final List<dynamic> forecastData = json.decode(response.body)['list'];

      // Find the forecast data for 12 PM
      final Map<String, dynamic> currentWeatherData =
          forecastData.firstWhere((data) {
        final DateTime dateTime =
            DateTime.parse(data['dt_txt']);
        return dateTime.hour == 12 && dateTime.minute == 0;
      });

      return currentWeatherData;
    } else {
      throw Exception('Failed to load current weather data');
    }
  } catch (error) {
    throw Exception('Failed to load current weather data: $error');
  }
  }
}

class CurrentWeatherCard extends StatefulWidget {
  const CurrentWeatherCard({Key? key}) : super(key: key);

  @override
  _CurrentWeatherCardState createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard> {
  CurrentWeatherData? currentWeather;

  @override
  void initState() {
    super.initState();
    // Fetch current weather data when the widget is initialized
    fetchCurrentWeatherData();
  }

  Future<void> fetchCurrentWeatherData() async {
    try {
      final apiKey = '6378430bc45061aaccd4a566a86c25df'; 
      final city = 'Naga';
      final Map<String, dynamic> data = await 
        CurrentWeatherApi.fetchCurrentWeather(apiKey, city);
      setState(() {
        currentWeather = CurrentWeatherData.fromJson(data);
      });
    } catch (error) {
      print('Error fetching current weather data: $error');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (currentWeather != null)
          Padding(padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  currentWeather!.day,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  )
                ),
                Text(
                  '${currentWeather!.month} ${currentWeather!.date}',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Image.network(currentWeather!.iconUrl),
                Text(
                  '${currentWeather!.temperature}°C',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w300,
                    fontSize: 30,
                  ),
                ),
                Text(
                  currentWeather!.weatherDescription.toUpperCase(),
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        if (currentWeather == null)
          const Text(
            'Loading current weather...',
            style: TextStyle(fontSize: 16),
          ),
      ]
    );
  }
}

class CurrentWeatherData {
  final String date;
  final String day;
  final String month;
  final String year;
  final int temperature;
  final String weatherDescription;
  final String iconUrl;

  CurrentWeatherData({
    required this.date,
    required this.day,
    required this.month,
    required this.year,
    required this.temperature,
    required this.weatherDescription,
    required this.iconUrl,
  });

  factory CurrentWeatherData.fromJson(Map<String, dynamic> json) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      json['dt'] * 1000);
    final String date = DateFormat('dd').format(dateTime);
    final String day = DateFormat('EEEE').format(dateTime);
    final String month = DateFormat('MMMM').format(dateTime);
    final String year = DateFormat('yyyy').format(dateTime);
    final int temperature = (json['main']['temp'] - 273.15).toInt();
    final String weatherDescription = json['weather'][0]['description'];
    final String iconCode = json['weather'][0]['icon'] ?? '';
    final String iconUrl = 'https://openweathermap.org/img/w/$iconCode.png';

    return CurrentWeatherData(
      date: date,
      day: day,
      month: month,
      year: year,
      temperature: temperature,
      weatherDescription: weatherDescription,
      iconUrl: iconUrl,
    );
  }
}
