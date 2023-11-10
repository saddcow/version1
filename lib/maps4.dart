import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Mapp extends StatefulWidget {
  const Mapp({Key? key}) : super(key: key);
  _MappState createState() => _MappState();
}

class _MappState extends State<Mapp> {
  List<Marker> myMarker = [];
  GoogleMapController? mapController;

  String selectedValue = 'Low';
  List<String> options = ['Low', 'Medium', 'High'];

  TextEditingController barangayController = TextEditingController();
  TextEditingController streetController = TextEditingController();

  @override
  void dispose() {
    barangayController.dispose();
    streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Column(
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
            const Padding(padding: EdgeInsets.only(top: 20.0)),
            TextField(
              controller: barangayController,
              decoration: InputDecoration(
                labelText: 'Barangay',
                border: OutlineInputBorder(),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 20.0)),
            TextField(
              controller: streetController,
              decoration: InputDecoration(
                labelText: 'Street',
                border: OutlineInputBorder(),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 20.0)),
            Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                value: selectedValue,
                onChanged: (newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });
                },
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _saveMarkerDetails();
                Navigator.pop(context);
              },
              child: const Text('Save Marker'),
            ),
          ],
        ),
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
    final String barangay = barangayController.text;
    final String street = streetController.text;

    if (barangay.isEmpty || street.isEmpty) {
      print('Please enter Barangay and Street');
      return;
    }

    for (final marker in myMarker) {
      final address = marker.infoWindow.snippet ?? '';
      final position = marker.position;
      final selectedOption = selectedValue;
      _saveMarkerToFirestore(barangay, street, address, position, selectedOption);
    }
  }

  Future<void> _saveMarkerToFirestore(String barangay, String street, String address, LatLng coordinates, String selectedOption) async {
    String first = "HA";
    var rng = Random();
    var code = rng.nextInt(90000) + 10000;
    String uniqueID = first + code.toString();

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('markers').doc(uniqueID).set({
        'uniqueID': uniqueID,
        'barangay': barangay,
        'street': street,
        'address': address,
        'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
        'risk_level': selectedOption,
      });
      print('Marker details saved to Firestore');
    } catch (e) {
      print('Error saving marker details to Firestore: $e');
    }
  }
}