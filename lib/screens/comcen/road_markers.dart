import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

Future<BitmapDescriptor> getCustomMarkerIcon() async {
  final ByteData data = await rootBundle.load('assets/Road Accident Hazard Area 1 (1).png');
  final Uint8List bytes = data.buffer.asUint8List();
  return BitmapDescriptor.fromBytes(bytes);
}

Future<List<Marker>> getRoadMarkers() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final BitmapDescriptor customIcon = await getCustomMarkerIcon();

  final QuerySnapshot snapshot = await firestore.collection('Road_Accident_Areas').get();
  final List<Marker> markers = [];

  for (final DocumentSnapshot document in snapshot.docs) {
    final data = document.data() as Map<String, dynamic>;
    final barangay = data['barangay'] as String?;
    final landmark = data['street_landmark'] as String?;
    final coordinates = data['coordinates'] as GeoPoint?;
    final uniqeID = data['uniqueID'] as String?;

    if (barangay != null && landmark != null && coordinates != null && uniqeID != null) {
      markers.add(
        Marker(
          markerId: MarkerId(uniqeID),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          icon: customIcon,
          infoWindow: InfoWindow(
            title: 'Road Accident Prone Area',
            snippet: '$barangay, ' ' $landmark ',
          )
        )
      );
    }
  }
  return markers;
}