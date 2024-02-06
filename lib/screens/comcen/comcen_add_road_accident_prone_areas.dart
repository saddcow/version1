import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:try1/utils/color_utils.dart';

class MappCom extends StatefulWidget {
  const MappCom({Key? key}) : super(key: key);
  _MappComState createState() => _MappComState();
}

class _MappComState extends State<MappCom> {
  List<Marker> myMarker = [];
  GoogleMapController? mapController;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController street_landmarkController = TextEditingController();
  String? selectedBarangay;

  @override
  void dispose() {
    street_landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'Add Road Accident Prone Area',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 25,
            color: Colors.white
          )
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                      future: _getBarangays(), // Fetch barangays from Firestore
                      builder: (context, AsyncSnapshot<List<String>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<String> barangays = snapshot.data!;
                          barangays.sort();
                          return DropdownButtonFormField<String>(
                            value: selectedBarangay,
                            isDense: true, // Reduces the vertical size of the dropdown
                            menuMaxHeight: 200, // Set the maximum height of the dropdown menu
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
                const Padding(padding: EdgeInsets.only(top: 20.0)),

                //Field for Landmark or street name
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Landmark/Street Name',
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
                      controller: street_landmarkController,
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

  void _saveMarkerDetails() {
    final String description = descriptionController.text;
    final String street_landmark = street_landmarkController.text;

    if (selectedBarangay == null || street_landmark.isEmpty) {
      print('Please select a Barangay and enter Landmark/Street');
      return;
    }

    for (final marker in myMarker) {
      final address = marker.infoWindow.snippet ?? '';
      final position = marker.position;
      _saveMarkerToFirestore(selectedBarangay!, address, description, street_landmark, position);
    }
  }

  Future<void> _saveMarkerToFirestore(
    String barangay,
    String address,
    String description,
    String landmark,
    LatLng coordinates,
  ) async {
    String first = "RA";
    var rng = Random();
    var code = rng.nextInt(90000) + 10000;
    String uniqueID = first + code.toString();

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('Road_Accident_Areas').doc(uniqueID).set({
        'uniqueID': uniqueID,
        'barangay': barangay,
        'address': address,
        'description' : description,
        'street_landmark' : landmark,
        'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Marker details saved to Firestore');
    } catch (e) {
      print('Error saving marker details to Firestore: $e');
    }
  }
}
