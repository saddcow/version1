import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RiskMarkers extends StatefulWidget {
  const RiskMarkers({super.key});
  @override
  _RiskMarkersState createState() => _RiskMarkersState();
}

class _RiskMarkersState extends State<RiskMarkers> {
  List<Marker> markers = [];
  double rainVolume = 0.00;

  @override
  void initState() {
    super.initState();
    getRainVolume();
  }

  Future<void> getRainVolume() async {
    final String apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
    final double latitude = 13.6217753;
    final double longitude = 123.1948238;

    final apiUrl = 'https://api.openweathermap.org/data/2.5/forecast';
    final response = await http.get(Uri.parse(
        '$apiUrl?lat=$latitude&lon=$longitude&appid=$apiKey'));

    if (response.statusCode == 200) {
      final forecastData = json.decode(response.body);
      final List<dynamic> hourlyForecast = forecastData['list'];

      for (int i = 0; i < 3; i++) {
        final rainData = hourlyForecast[i]['rain'];
        if (rainData != null && rainData['3h'] != null) {
          setState(() {
            rainVolume = rainData['3h'].toDouble();
          });
          break;
        }
      }
    } else {
      print('Failed to load weather data. Status code: ${response.statusCode}');
    }

    loadMarkersFromFirestore();
  }

  void loadMarkersFromFirestore() async {
    String searchString = '';

    if (rainVolume > 30.00) {
      searchString = 'High';
    } else if (rainVolume >= 15 && rainVolume <= 30) {
      searchString = 'Medium';
    } else if (rainVolume >= 6.5 && rainVolume <= 15) {
      searchString = 'Low';
    } else {
      searchString = 'High';
    }

    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('markers').get();

    final List<Marker> matchingMarkers = [];

    for (final QueryDocumentSnapshot document in querySnapshot.docs) {
      final riskLevel = document['risk_level'] as String;
      final address = document['address'] as String;
      final coordinates = document['coordinates'] as GeoPoint;

      if (searchString == 'High') {
        matchingMarkers.add(
          Marker(
            markerId: MarkerId(address),
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
            )
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
            )
          )
        );
      }
    }

    setState(() {
      markers = matchingMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(13.6217753, 123.1948238),
          zoom: 15,
        ),
        markers: Set.from(markers),
      ),
    );
  }
}


