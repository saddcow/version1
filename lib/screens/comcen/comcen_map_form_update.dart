import 'package:flutter/material.dart';
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
  GoogleMapController? mapController;

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
    id = widget.myString;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Road Risk Area'),
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
                  const Padding(
                    padding: EdgeInsets.only(left: 25),
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
                  print(id);
                  _saveMarkerDetails(id);
                  Navigator.pop(context);
                },
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

  void _saveMarkerDetails(String id) {
    final String barangay = barangayController.text;
    final String street = streetController.text;

    for (final marker in myMarker) {
      final address = marker.infoWindow.snippet ?? '';
      final position = marker.position;
      _saveMarkerToFirestore(barangay, street, address, position);
    }
  }

  Future<void> updateDocument(
      String documentId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('Road_Accident_Areas') // Replace with your collection name
        .doc(documentId)
        .update(data);
  }

  Future<void> _saveMarkerToFirestore(
    
      String barangay, String street, String address, LatLng coordinates) async {
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
      print(id);
      print('Error saving marker details to Firestore: $e');
    }
  }

}