import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:try1/utils/color_utils.dart';

class RoadRiskForm extends StatefulWidget {
  const RoadRiskForm({super.key});

  @override
  State<RoadRiskForm> createState() => _RoadRiskFormState();
}

class _RoadRiskFormState extends State<RoadRiskForm> {
  List<Marker> myMarker = [];
  GoogleMapController? mapController;
  TextEditingController barangayController = TextEditingController();
  TextEditingController streetController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    barangayController.dispose();
    streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Colors.blueGrey,
        title: Text(
          'Add Road Risk Area',
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
            //google map widget
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

            Column(
              children: [
                const Padding(padding: EdgeInsets.only(left: 25.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Barangay Name'),
                  ),
                ),
                SizedBox(
                  child: Padding(padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: barangayController,
                      decoration: const InputDecoration(
                        labelText: 'Barangay',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 20.0)),

                const Padding(padding: EdgeInsets.only(left: 25.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Street Name'),
                  ),
                ),
                SizedBox(
                  child: Padding(padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: streetController,
                      decoration: const InputDecoration(
                        labelText: 'Street Name',
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
                _saveMarkerDetails();
                Navigator.pop(context);
                setState(() {});
              }, 
              child: const Text('Save Marker'),
            )
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
          )
        )
      ];
    });
  }

  // get address from latitude and longitude using a reverse geocoding api
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

  // Save marker details to Firestore
  void _saveMarkerDetails(){
    final String barangay = barangayController.text;
    final String street = streetController.text;

    if (barangay.isEmpty || street.isEmpty) {
      print('Please enter Barangay and Street');
      return;
    }
    
    for (final marker in myMarker) {
      final address = marker.infoWindow.snippet ?? '';
      final position = marker.position;
      _saveMarkerToFirestore(barangay, street, address, position);
    }
  }

  // save marker details to firestore
  Future<void> _saveMarkerToFirestore(String barangay, String street, String address, LatLng coordinates) async{
    String first = "HA";
    var rng = Random();
    var code = rng.nextInt(90000) + 10000;
    String uniqueID = first + code.toString();

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('road_markers').doc(uniqueID).set({
        'uniqueID': uniqueID,
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