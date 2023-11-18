import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:try1/markers/reports_marker_helper.dart';
import 'package:try1/screens/comcen/road_markers.dart';

class MainMapComcen extends StatefulWidget {
  const MainMapComcen({super.key});
  @override
  _MainMapComcenState createState() => _MainMapComcenState();
}

class _MainMapComcenState extends State<MainMapComcen> {
  List<Marker> markersCombined = [];

  @override
  void initState() {
    super.initState();
    loadRoadMarkers();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    List<Marker> markers = await retrieveMarkersFromFirestore();
    setState(() {
      markersCombined.addAll(markers);
    });
  }

  Future<void> loadRoadMarkers() async {
    List<Marker> roadMarkers = await getRoadMarkers();

    setState(() {
      markersCombined.addAll(roadMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(13.6217753, 123.1948238),
          zoom: 15,
        ),
        markers: Set.from(markersCombined),
      ),
    );
  }
}