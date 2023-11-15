import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:try1/markers/reports_marker_helper.dart';
import 'risk_markers_helper.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});
  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  List<Marker> combinedMarkers = [];

  @override
  void initState() {
    super.initState();
    loadMarkers();
    _loadMarkers(); // Load markers when the app starts
  }

  Future<void> _loadMarkers() async {
    List<Marker> markers = await retrieveMarkersFromFirestore();

    setState(() {
      combinedMarkers.addAll(markers);
    });
  }

  Future<void> loadMarkers() async {
    List<Marker> riskMarkers = await getRiskMarkers();

    setState(() {
      combinedMarkers.addAll(riskMarkers);
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
        markers: Set.from(combinedMarkers),
      ),
    );
  }
}
