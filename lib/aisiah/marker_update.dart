// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MappUpdate extends StatefulWidget {
  final String myString;

  const MappUpdate({Key? key, required this.myString}) : super(key: key);

  @override
  _MappUpdateState createState() => _MappUpdateState();
}

class _MappUpdateState extends State<MappUpdate> {
  String id = "";

  List<Marker> myMarker = [];
  GoogleMapController? mapController;
  String? selectedRiskLevel;
  TextEditingController streetLandmarkController = TextEditingController();
  String? selectedBarangay;
  List<String> barangayOptions = []; // List to store barangay options

  @override
  void initState() {
    super.initState();
    id = widget.myString;
    _getBarangayOptions(); // Fetch barangay options from Firestore
  }

  @override
  void dispose() {
    streetLandmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Flood Risk Area',
            style:
                GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 25)),
      ),
      body: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 600,
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
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
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
                      child: DropdownButtonFormField<String>(
                        value: selectedBarangay,
                        isDense:
                            true, // Reduces the vertical size of the dropdown
                        menuMaxHeight:
                            200, // Set the maximum height of the dropdown menu
                        items: barangayOptions.map((String barangay) {
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
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 20.0)),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Name of Landmark or Street',
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
                        controller: streetLandmarkController,
                        decoration: const InputDecoration(
                          labelText: 'Landmark/Street',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 20.0)),
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
                            riskLevel.sort();
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
              ElevatedButton(
                onPressed: () {
                  _saveMarkerDetails(id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text('Save Marker'),
              ),
              const Padding(padding: EdgeInsets.only(top: 50)),
            ],
          ),
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

  void _saveMarkerDetails(String id) {
    final String streetLandmark = streetLandmarkController.text;

    for (final marker in myMarker) {
      final address = marker.infoWindow.snippet ?? '';
      final position = marker.position;
      final selectedOption = selectedRiskLevel;
      _saveMarkerToFirestore(
          id, selectedBarangay!, streetLandmark, address, position, selectedOption!);
    }
  }

  // Fetch barangay options from Firestore
  Future<void> _getBarangayOptions() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Barangay').get();

      List<String> unsortedOptions =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();

      // Sort the barangayOptions alphabetically
      unsortedOptions.sort();

      setState(() {
        barangayOptions = unsortedOptions;
      });
    } catch (e) {
      print('Error fetching barangay options: $e');
    }
  }

  Future<void> _saveMarkerToFirestore(String id, String barangay, String streetLandmark,
      String address, LatLng coordinates, String selectedOption) async {
    try {
      await FirebaseFirestore.instance.collection('markers').doc(id).update({
        'uniqueID': id,
        'barangay': barangay,
        'street_landmark': streetLandmark,
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
