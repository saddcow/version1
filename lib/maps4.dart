import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Mapp extends StatefulWidget {
  const Mapp({super.key});
  _MappState createState() => _MappState();
}

class _MappState extends State<Mapp>{
  List<Marker> myMarker = [];
  GoogleMapController? mapController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(13.6217753, 123.1948238),
                zoom: 15.0,
              ),
              markers: Set.from(myMarker),
              onTap: _addMarker,
            ),
          ),
          ElevatedButton(
            onPressed: (){
              _saveMarkerDetails();
              Navigator.pop(context);
            },
            child: const Text('Save Marker'),
          ),
        ],
      ),
    );
  }

  void _addMarker(LatLng position) async {
    final address = await _getAddressFromLatLng(position);
    setState(() {
      myMarker = [];
      myMarker.add(
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
  void _saveMarkerDetails() {
    for (final marker in myMarker) {
      final address = marker.infoWindow.snippet ?? '';
      final position = marker.position;
      _saveMarkerToFirestore(address, position);
    }
  }

  Future<void> _saveMarkerToFirestore(String address, LatLng coordinates) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('markers').add({
        'address': address,
        'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
      });
      print('Marker details saved to Firestore');
    } catch (e) {
      print('Error saving marker details to Firestore: $e');
    }
  }
}
