import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


Future<List<Marker>> hazardMarkers() async {
  List<Marker> markers = [];

  final QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.
        collection('Flood_Hazard_Area').get();

  final List<Marker> matchingMarkers = [];

  for (final QueryDocumentSnapshot document in querySnapshot.docs) {
    final riskLevel = document['risk_level'] as String;
    final address = document['address'] as String;
    final coordinates = document['coordinates'] as GeoPoint;
    final uniqeID = document['uniqueID'] as String;
      matchingMarkers.add(
        Marker(
          markerId: MarkerId(uniqeID),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: InfoWindow(
            title: 'Risk Level: $riskLevel',
            snippet: address,
          ),
        ),
      );
  }
  markers = matchingMarkers;
  return markers;
}