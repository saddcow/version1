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
        initialCameraPosition:const  CameraPosition(
          target: LatLng(13.6217753, 123.1948238),
          zoom: 15.0,
        ),
        markers: Set.from(myMarker),
      ),
    );
  }

  Future<void> _retrieveMarkersFromFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot snapshot = await firestore.collection('Report').get();

    final List<Marker> markers = [];

    for (final DocumentSnapshot document in snapshot.docs) {
      final data = document.data() as Map<String, dynamic>;
      final Barangay = data['Barangay'] as String;
      final Street = data['Street'] as String;
      final Coordinates = data['Coordinates'] as GeoPoint;
      final Hazard_Status = data['Hazard_Status'] as String;
      final Report_ID = data['Report_ID'] as String;

      markers.add(
        Marker(
          markerId: MarkerId(Report_ID),
          position: LatLng(Coordinates.latitude, Coordinates.longitude),
          infoWindow: InfoWindow(
            title: 'Report location status: $Hazard_Status',
            snippet: 'Location:  $Barangay' ' $Street ',
          ),
          
        ),
      );
    }

    setState(() {
      myMarker = markers;
    });
  }
}