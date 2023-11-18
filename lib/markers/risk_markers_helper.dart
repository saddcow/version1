import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';


Future<List<Marker>> getRiskMarkers() async {
  List<Marker> markers = [];

  const String apiKey = '6378430bc45061aaccd4a566a86c25df';
  const double latitude = 13.6217753;
  const double longitude = 123.1948238;
  Map<String, dynamic> weatherData = {};

    const apiUrl =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
        weatherData = data;
    } else {
      print('Failed to load weather data. Status code: ${response.statusCode}');
    }
  

  String searchString = '';

  if (weatherData['list'][0]['rain']['3h'] >= 6.5 && weatherData['list'][0]['rain']['3h'] <= 15.0){
    if (weatherData['list'][1]['rain']['3h'] >= 6.5 && weatherData['list'][1]['rain']['3h'] <= 15.0){
      if (weatherData['list'][2]['rain']['3h'] >= 6.5 && weatherData['list'][2]['rain']['3h'] <= 15.0){
        searchString = 'Low';
      } else {searchString = '';}
    } else {
      searchString = '';
    }
  }
  else if (weatherData['list'][0]['rain']['3h'] >= 15.0 && weatherData['list'][0]['rain']['3h'] <= 30.0){
    if (weatherData['list'][1]['rain']['3h'] >= 15.0 && weatherData['list'][1]['rain']['3h'] <= 30.0){
      if (weatherData['list'][2]['rain']['3h'] >= 15.0 && weatherData['list'][2]['rain']['3h'] <= 30.0){
        searchString = 'Medium';
      } else {searchString = '';}
    } else {
      searchString = '';
    }
  }
  else if (weatherData['list'][0]['rain']['3h'] > 30.0){
    if (weatherData['list'][1]['rain']['3h'] > 30.0 ){
      if (weatherData['list'][2]['rain']['3h'] > 30){
        searchString = 'High';
      } else {searchString = '';}
    } else {
      searchString = '';
    }
  }
  else {
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
            title: ('Risk Level: $riskLevel'),
            snippet: address,
          ),
        )
      );
    }
  }

  markers = matchingMarkers;
  return markers;
}