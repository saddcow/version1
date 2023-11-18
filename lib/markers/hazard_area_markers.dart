import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<List<Marker>> hazardMarkers() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final QuerySnapshot snapshot = await firestore.collection('markers').get();

  final List<Marker> markers = [];

  for (final DocumentSnapshot document in snapshot.docs) {
    print('baka');

    final data = document.data() as Map<String, dynamic>;
    final barangay = data['Barangay'] as String?;
    final street = data['Street'] as String?;
    final coordinates = data['Coordinates'] as GeoPoint?;
    final hazardStatus = data['Risk_Level'] as String?;
    final uniqueID = data['uniqueID'];

    if(barangay != null && street != null && coordinates != null && hazardStatus != null && uniqueID != null) {
      markers.add(
        Marker(
          markerId: MarkerId(uniqueID),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: InfoWindow(
            title: 'Report location status: $hazardStatus',
            snippet: 'Location:  $barangay, ' ' $street ',
          ),
        ),
      );
    }
  }

  return markers;
}
