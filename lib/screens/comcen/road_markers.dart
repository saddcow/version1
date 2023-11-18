import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<List<Marker>> getRoadMarkers() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final QuerySnapshot snapshot = await firestore.collection('markers_road').get();
  final List<Marker> markers = [];

  for (final DocumentSnapshot document in snapshot.docs) {
    final data = document.data() as Map<String, dynamic>;
    final barangay = data['barangay'] as String?;
    final street = data['street'] as String?;
    final coordinates = data['coordinates'] as GeoPoint?;
    final uniqeID = data['uniqueID'] as String?;

    if (barangay != null && street != null && coordinates != null && uniqeID != null) {
      markers.add(
        Marker(
          markerId: MarkerId(uniqeID),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: InfoWindow(
            title: 'Road Risk Location:',
            snippet: '$barangay, ' ' $street ',
          )
        )
      );
    }
  }
  return markers;
}