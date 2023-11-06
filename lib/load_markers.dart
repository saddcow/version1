import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HomeScreenMap extends StatefulWidget {
  const HomeScreenMap({super.key});
  @override
  State<HomeScreenMap> createState() => _HomeScreenMapState();
}

class _HomeScreenMapState extends State<HomeScreenMap> {
  List<Marker> myMarker = [];
  
  @override
  void initState() {
    super.initState();
    _retrieveMarkersFromFirestore(); // Load markers from Firestore when the app starts
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(13.6217753, 123.1948238),
          zoom: 15.0,
        ),
        markers: Set.from(myMarker),
      ),
    );
  }

  Future<void> _retrieveMarkersFromFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot snapshot = await firestore.collection('markers').get();

    final List<Marker> markers = [];

    for (final DocumentSnapshot document in snapshot.docs) {
      final data = document.data() as Map<String, dynamic>;
      final address = data['address'] as String;
      final coordinates = data['coordinates'] as GeoPoint;

      markers.add(
        Marker(
          markerId: MarkerId(address),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: InfoWindow(
            title: 'Location',
            snippet: address,
          ),
        ),
      );
    }

    setState(() {
      myMarker = markers;
    });
  }
}