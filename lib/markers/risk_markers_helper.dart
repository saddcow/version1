// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:try1/globals.dart' as globals;

Future<BitmapDescriptor> getCustomMarkerIcon() async {
  final ByteData data = await rootBundle.load(
    'assets/Flood Hazard Area.png');
  final Uint8List bytes = data.buffer.asUint8List();
  return BitmapDescriptor.fromBytes(bytes);
}

Future<List<Marker>> getRiskMarkers() async {
  List<Marker> markers = [];
  final BitmapDescriptor customIcon = await getCustomMarkerIcon();
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
  
  final QuerySnapshot querySnapshot = await FirebaseFirestore.
    instance.collection('Flood_Hazard_Area').get();

  final List<Marker> matchingMarkers = [];

for (final QueryDocumentSnapshot document in querySnapshot.docs) {
  final riskLevel = document['risk_level'] as String;
  final address = document['address'] as String;
  final coordinates = document['coordinates'] as GeoPoint;
  final uniqeID = document['uniqueID'] as String;

  if (globals.matchingDocumentIds.contains(uniqeID)) {
    matchingMarkers.add(
      Marker(
        markerId: MarkerId(uniqeID),
        position: LatLng(coordinates.latitude, coordinates.longitude),
        icon: customIcon,
        infoWindow: InfoWindow(
          title: 'Risk Level: $riskLevel',
          snippet: address,
        ),
      ),
    );
  } 
}

  markers = matchingMarkers;
  return markers;
}