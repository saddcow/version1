import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreenMap extends StatefulWidget {
  const HomeScreenMap({Key? key}) : super(key: key);

  @override
  State<HomeScreenMap> createState() => _HomeScreenMapState();
}

class _HomeScreenMapState extends State<HomeScreenMap> {
  List<Marker> myMarkers = []; // List to hold markers on the map

  @override
  void initState() {
    super.initState();
    _retrieveMarkersFromFirestore(); // Load markers from Firestore when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(13.6217753, 123.1948238),
          zoom: 15.0,
        ),
        markers: Set.from(myMarkers),
      ),
    );
  }

  // Retrieve markers from Firestore and update the myMarkers list
  Future<void> _retrieveMarkersFromFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot snapshot = await firestore.collection('Report').get();

    final List<Marker> markers = [];

    for (final DocumentSnapshot document in snapshot.docs) {
      final data = document.data() as Map<String, dynamic>;
      final barangay = data['Barangay'] as String;
      final street = data['Street'] as String;
      final coordinates = data['Coordinates'] as GeoPoint;
      final hazardStatus = data['Hazard_Status'] as String;
      final reportId = data['Report_ID'] as String;

      markers.add(
        Marker(
          markerId: MarkerId(reportId),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: InfoWindow(
            title: 'Report location status: $hazardStatus',
            snippet: 'Location: $barangay $street',
          ),
        ),
      );
    }

    setState(() {
      myMarkers = markers;
    });
  }
}
