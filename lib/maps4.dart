import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Mapp extends StatefulWidget {
  const Mapp({super.key});
  _MappState createState() => _MappState();
}

class _MappState extends State<Mapp>{
  final Set<Marker> markers = {};
  GoogleMapController? mapController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(13.6217753, 123.1948238),
          zoom: 15.0,
        ),
      markers: markers,
      onTap: _addMarker,      
      ),
    );
  }

  void _addMarker(LatLng position) async {
    final address = await _getAddressFromLatLng(position);
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: 'Location',
            snippet: address,
          ),
        ),
      );
    });
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name'];
        return displayName;
      }
    } catch (e) {
      print(e);
    }
    return "Address not found";
  }
}
