import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

Future<BitmapDescriptor> getCustomMarkerIcon() async {
  final ByteData data = await rootBundle.load('assets/Flood Hazard Area.png');
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
  

  String searchString = '';

  if (weatherData.containsKey('list') && weatherData['list'] is List && (weatherData['list'] as List).isNotEmpty) {
    final List<dynamic> list = weatherData['list'];

    if (list.length > 2) {
      double rain1 = (list.isNotEmpty && list[0]['rain'] != null && list[0]['rain']['3h'] != null) ? list[0]['rain']['3h'] : 0.0;
      double rain2 = (list.length > 1 && list[1]['rain'] != null && list[1]['rain']['3h'] != null) ? list[1]['rain']['3h'] : 0.0;
      double rain3 = (list.length > 2 && list[2]['rain'] != null && list[2]['rain']['3h'] != null) ? list[2]['rain']['3h'] : 0.0;

      if (rain1 >= 6.5 && rain1 <= 15.0 && rain2 >= 6.5 && rain2 <= 15.0 && rain3 >= 6.5 && rain3 <= 15.0) {
        searchString = 'Low';
      } else if (rain1 >= 15.0 && rain1 <= 30.0 && rain2 >= 15.0 && rain2 <= 30.0 && rain3 >= 15.0 && rain3 <= 30.0) {
        searchString = 'Medium';
      } else if (rain1 > 30.0 && rain2 > 30.0 && rain3 > 30.0) {
        searchString = 'High';
      }
    }
  }

  final QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('Flood_Hazard_Area').get();

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
          icon: customIcon,
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
          icon: customIcon,
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
          icon: customIcon,
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