import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<List<Marker>> getRiskMarkers() async {
  List<Marker> markers = [];
  double rainVolume = 0.00;

  const String apiKey = '6378430bc45061aaccd4a566a86c25df';
  const double latitude = 13.6217753;
  const double longitude = 123.1948238;

  const apiUrl = 'https://api.openweathermap.org/data/2.5/forecast';
  final response = await http.get(Uri.parse(
      '$apiUrl?lat=$latitude&lon=$longitude&appid=$apiKey'));

  if (response.statusCode == 200) {
    final forecastData = json.decode(response.body);
    final List<dynamic> hourlyForecast = forecastData['list'];

    for (int i = 0; i < 3; i++) {
      final rainData = hourlyForecast[i]['rain'];
      if (rainData != null && rainData['3h'] != null) {
        rainVolume = rainData['3h'].toDouble();
        break;
      }
    }
  } else {
    print('Failed to load weather data. Status code: ${response.statusCode}');
  }

  String searchString = '';

  if (rainVolume > 30.00) {
    searchString = 'High';
  } else if (rainVolume >= 15 && rainVolume <= 30) {
    searchString = 'Medium';
  } else if (rainVolume >= 6.5 && rainVolume <= 15) {
    searchString = 'Low';
  } else {
    searchString = '';
  }

  final QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('markers').get();

  final List<Marker> matchingMarkers = [];

  for (final QueryDocumentSnapshot document in querySnapshot.docs) {
    final riskLevel = document['risk_level'] as String;
    final address = document['address'] as String;
    final coordinates = document['coordinates'] as GeoPoint;
    final uniqeID = document['uniqueID'] as String;

    if (searchString == 'High') {
      matchingMarkers.add(
        Marker(
          markerId: MarkerId(uniqeID),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: InfoWindow(
            title: 'Risk Level: $riskLevel',
            snippet: address,
          ),
        ),
      );
    } else if ( searchString == 'Medium' && riskLevel == 'Medium'){
      matchingMarkers.add(
        Marker(
          markerId: MarkerId(address),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: InfoWindow(
            title: 'Risk Level: $riskLevel',
            snippet: address,
          ),
        )
      );
    } else if (searchString == 'Low' && riskLevel == 'High') {
      matchingMarkers.add(
        Marker(
          markerId: MarkerId(address),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: InfoWindow(
            title: 'Risk Level: $riskLevel',
            snippet: address,
          ),
        )
      );
    }
  }

  markers = matchingMarkers;
  return markers;
}
