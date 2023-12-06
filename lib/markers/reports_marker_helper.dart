import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

Future<BitmapDescriptor> getCustomMarkerIcon() async {
  final ByteData data = await rootBundle.load('assets/green.png');
  final Uint8List bytes = data.buffer.asUint8List();
  return BitmapDescriptor.fromBytes(bytes);
}



Future<List<Marker>> retrieveMarkersFromFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Load the custom icon
  final BitmapDescriptor customIcon = await getCustomMarkerIcon();
  
  // Calculate start and end timestamps for current day
  DateTime now = DateTime.now();
  DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
  DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  // Retrieve reports within the current day
  final QuerySnapshot snapshot = await firestore
      .collection('Report')
      .where('Timestamp', isGreaterThanOrEqualTo: startOfDay)
      .where('Timestamp', isLessThanOrEqualTo: endOfDay)
      .get();

  final List<Marker> markers = [];

  for (final DocumentSnapshot document in snapshot.docs) {
    final data = document.data() as Map<String, dynamic>;
    final barangay = data['Barangay'] as String?;
    final street = data['Street'] as String?;
    final coordinates = data['Coordinates'] as GeoPoint?;
    final hazardStatus = data['Hazard_Status'] as String?;
    final reportID = data['Report_ID'] as String?;
    final type = data['Report_Hazard_Type'] as String;

     if (barangay != null &&
        street != null &&
        coordinates != null &&
        hazardStatus != null &&
        reportID != null &&
        type != 'Road Accident') {
      markers.add(
        Marker(
          markerId: MarkerId(reportID),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          icon: customIcon, // Set the custom icon
          infoWindow: InfoWindow(
            title: 'Report location status: $hazardStatus',
            snippet: 'Location: $barangay, ' ' $street',
          ),
        ),
      );
    }
  }

  return markers;
}
