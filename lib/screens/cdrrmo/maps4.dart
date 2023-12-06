import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Mapp extends StatefulWidget {
  const Mapp({Key? key}) : super(key: key);
  _MappState createState() => _MappState();
}

class _MappState extends State<Mapp> {
  // List to store markers on the map
  List<Marker> myMarker = [];

  // Google Map controller
  GoogleMapController? mapController;

  // Dropdown menu options

  // Controllers for text fields
  TextEditingController streetController = TextEditingController();
  String? selectedBarangay;

  String? selectedRiskLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Flood Risk Area'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Google Map Widget
            SizedBox(
              height: 600,
              width: double.infinity,
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

            // Dropdown for Barangay Name
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Barangay Name',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FutureBuilder(
                      future:
                          _getBarangays(), // Fetch barangays from Firestore
                      builder:
                          (context, AsyncSnapshot<List<String>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<String> barangays = snapshot.data!;
                          barangays.sort();
                          return DropdownButtonFormField<String>(
                            value: selectedBarangay,
                            isDense:
                                true, // Reduces the vertical size of the dropdown
                            menuMaxHeight:
                                200, // Set the maximum height of the dropdown menu
                            items: barangays.map((String barangay) {
                              return DropdownMenuItem<String>(
                                value: barangay,
                                child: Text(barangay),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedBarangay = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),

                const Padding(
                    padding: EdgeInsets.only(top: 5.0)), // Adjusted padding

                // Text Field for Street Name
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Street Name',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: streetController,
                      decoration: const InputDecoration(
                        labelText: 'Street',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 20.0)),

                // Dropdown for Risk Level
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Risk Level',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FutureBuilder(
                      future:
                          _getRiskLevel(), // Fetch barangays from Firestore
                      builder:
                          (context, AsyncSnapshot<List<String>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<String> riskLevel = snapshot.data!;

                          return DropdownButtonFormField<String>(
                            value: selectedRiskLevel,
                            isDense:
                                true, // Reduces the vertical size of the dropdown
                            menuMaxHeight:
                                200, // Set the maximum height of the dropdown menu
                            items: riskLevel.map((String risklvl) {
                              return DropdownMenuItem<String>(
                                value: risklvl,
                                child: Text(risklvl),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedRiskLevel = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Button to save marker details
            ElevatedButton(
              onPressed: () {
                _saveMarkerDetails();
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Save Marker'),
            ),
            const Padding(padding: EdgeInsets.only(top: 50)),
          ],
        ),
      ),
    );
  }

  // Add marker on map at the tapped location
  void _addMarker(LatLng position) async {
    final address = await _getAddressFromLatLng(position);
    setState(() {
      myMarker = [
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: 'Location',
            snippet: address,
          ),
        ),
      ];
    });
  }

  // Get address from latitude and longitude using a reverse geocoding API
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

  // Fetch barangays from Firestore
  Future<List<String>> _getBarangays() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Barangay').get();
      return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print('Error fetching barangays: $e');
      return [];
    }
  }

  Future<List<String>> _getRiskLevel() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Flood_Risk_Level').get();
      return querySnapshot.docs
          .map((doc) => doc['Hazard_level'] as String)
          .toList();
    } catch (e) {
      print('Error fetching barangays: $e');
      return [];
    }
  }

  // Save marker details to Firestore
  void _saveMarkerDetails() {
    final String street = streetController.text;

    if (selectedBarangay == null || street.isEmpty) {
      print('Please select a Barangay and enter Street');
      return;
    }

    for (final marker in myMarker) {
      final address = marker.infoWindow.snippet ?? '';
      final position = marker.position;
      final RiskLevel = selectedRiskLevel;
      _saveMarkerToFirestore(
          selectedBarangay!, street, address, position, RiskLevel!);
    }
  }

  // Save marker details to Firestore
  Future<void> _saveMarkerToFirestore(String barangay, String street,
      String address, LatLng coordinates, String selectedRiskLevel) async {
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
        'risk_level': selectedRiskLevel,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('$uniqueID - $selectedRiskLevel');
      print('Marker details saved to Firestore');
    } catch (e) {
      print('Error saving marker details to Firestore: $e');
    }
  }
}
