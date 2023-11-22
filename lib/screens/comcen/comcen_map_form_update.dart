import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComcenMarkerUpdate extends StatefulWidget {
  final String myString;

  const ComcenMarkerUpdate({Key? key, required this.myString}) : super(key: key);

  @override
  State<ComcenMarkerUpdate> createState() => _ComcenMarkerUpdate();
}

class _ComcenMarkerUpdate extends State<ComcenMarkerUpdate> {
  String id = "";

  List<Marker> myMarker = [];
  TextEditingController streetController = TextEditingController();
  String? selectedBarangay;

  @override
  void initState() {
    super.initState();
    id = widget.myString;
  }

  @override
  void dispose() {
    streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Road Risk Area',
          style: GoogleFonts.roboto(
              fontWeight: FontWeight.w400,
              fontSize: 25
          )
        ),
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
              // Dropdown for Barangay Name
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Barangay Name'),
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        child: FutureBuilder(
                          future: _getBarangays(), // Fetch barangays from Firestore
                          builder: (context, AsyncSnapshot<List<String>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              List<String> barangays = snapshot.data!;
                              barangays.sort();
                              return DropdownButtonFormField<String>(
                                value: selectedBarangay,
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
                                menuMaxHeight: 200, // Set the maximum height of the dropdown menu
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 20.0)),

                  const Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Street Name'),
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
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _saveMarkerDetails(id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                  )
                ),
                child: const Text('Save Marker'),
              )
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

  void _saveMarkerDetails(String id) {
    final String street = streetController.text;

    if (selectedBarangay == null || street.isEmpty) {
      print('Please select a Barangay and enter Street');
      return;
    }

    for (final marker in myMarker) {
      final address = marker.infoWindow.snippet ?? '';
      final position = marker.position;
      _saveMarkerToFirestore(id, selectedBarangay!, street, address, position);
    }
  }

  Future<void> _saveMarkerToFirestore(
    String id,
    String barangay,
    String street,
    String address,
    LatLng coordinates,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('Road_Accident_Areas').doc(id).update({
        'uniqueID': id,
        'barangay': barangay,
        'street': street,
        'address': address,
        'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
      });
      print('Marker details saved to Firestore');
    } catch (e) {
      print('Error saving marker details to Firestore: $e');
    }
  }
}
