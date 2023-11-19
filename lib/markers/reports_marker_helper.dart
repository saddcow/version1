import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<List<Marker>> retrieveMarkersFromFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final QuerySnapshot snapshot = await firestore.collection('Report').get();

  final List<Marker> markers = [];

  for (final DocumentSnapshot document in snapshot.docs) {

    final data = document.data() as Map<String, dynamic>;
    final barangay = data['Barangay'] as String?;
    final street = data['Street'] as String?;
    final coordinates = data['Coordinates'] as GeoPoint?;
    final hazardStatus = data['Hazard_Status'] as String?;
    final reportID = data['Report_ID'] as String?;
    final type = data['Report_Hazard_Type'];
    if(barangay != null && street != null && coordinates != null && hazardStatus != null && reportID != null && type != 'Road') {
      markers.add(
        Marker(
          markerId: MarkerId(reportID),
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
