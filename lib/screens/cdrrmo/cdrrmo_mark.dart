import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:try1/utils/color_utils.dart';

class AuthorityMark extends StatefulWidget {
  const AuthorityMark({Key? key}) : super(key: key);
  _AuthorityMarkState createState() => _AuthorityMarkState();
}

class _AuthorityMarkState extends State<AuthorityMark> {
  List<Marker> myMarker = [];

  // Google Map controller
  GoogleMapController? mapController;

  // Controllers for text fields
  TextEditingController streetController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? selectedBarangay;

  String? selectedRiskLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("#3c7f96"),
        title: Text(
          'Add Currently Flooding Area',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 25,
            color: Colors.white
          ),
        ),
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
                      future: _getBarangays(),
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
                            isDense: true,
                            menuMaxHeight: 200,
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
                    padding: EdgeInsets.only(top: 5.0)),

                // Text Field for Street Name
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Name of Street/Landmark',
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
                        labelText: 'Street/Landmark',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 20.0)),

                // Text Field for Description
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Description',
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
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
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
  final String description = descriptionController.text;

  if (selectedBarangay == null || street.isEmpty || selectedRiskLevel == null) {
    print('Please select a Barangay, enter Street, and select Risk Level');
    return;
  }

  // Fetch 'number' from Flood Risk Level data based on the selected risk level
  _getRiskLevelNumber(selectedRiskLevel!).then((int? riskNumber) {
    if (riskNumber != null) {
      for (final marker in myMarker) {
        final address = marker.infoWindow.snippet ?? '';
        final position = marker.position;
        _saveMarkerToFirestore(
          selectedBarangay!,
          street,
          description,
          address,
          position,
          selectedRiskLevel!,
          riskNumber,
        );
      }
    } else {
      print('Error fetching Flood Risk Level number');
    }
  });
}

// Fetch 'number' from Flood Risk Level data based on the selected risk level
Future<int?> _getRiskLevelNumber(String riskLevel) async {
  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Flood_Risk_Level')
        .where('Hazard_level', isEqualTo: riskLevel)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['Number'] as int?;
    } else {
      print('No data found for the selected risk level: $riskLevel');
      return null;
    }
  } catch (e) {
    print('Error fetching Flood Risk Level number: $e');
    return null;
  }
}

// Save marker details to Firestore
Future<void> _saveMarkerToFirestore(String barangay, String street, String description, String address,
    LatLng coordinates, String selectedRiskLevel, int riskNumber) async {
  String first = "AM";
  var rng = Random();
  var code = rng.nextInt(90000) + 10000;
  String uniqueID = first + code.toString();

  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('CDRRMO_Marker').doc(uniqueID).set({
      'type': 'Flood',
      'uniqueID': uniqueID,
      'barangay': barangay,
      'description': description,
      'street_landmark': street,
      'address': address,
      'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
      'number': riskNumber,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('$uniqueID - $selectedRiskLevel');
    print('Marker details saved to Firestore');
  } catch (e) {
    print('Error saving marker details to Firestore: $e');
  }
}
}
